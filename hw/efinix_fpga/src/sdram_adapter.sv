module sdram_adapter(
    input logic i_cpuclk,
    input logic i_arst,       // Async Reset
    input logic i_sysclk,       // Controller Clock (100MHz)
    input logic i_sdrclk,       // t_su and t_wd clock (200MHz)
    input logic i_tACclk,       // t_ac clock (200MHz)

    input logic i_cs,           // Chip select
    input logic i_rwb,          // Read/Write. Write is low
    input logic [24:0] i_addr,  // Input address. Byte addressed

    input logic [7:0]  i_data,  // Input Data
    output logic [7:0] o_data,  // Output data

    output o_sdr_init_done,
    
    output o_wait,

    output o_sdr_CKE,
    output o_sdr_n_CS,
    output o_sdr_n_RAS,
    output o_sdr_n_CAS,
    output o_sdr_n_WE,
    output [1:0] o_sdr_BA,
    output [12:0] o_sdr_ADDR,
    output [15:0] o_sdr_DATA,
    output [15:0] o_sdr_DATA_oe,
    input  [15:0] i_sdr_DATA,
    output [1:0] o_sdr_DQM
);

logic [1:0] w_sdr_CKE;
logic [1:0] w_sdr_n_CS;
logic [1:0] w_sdr_n_RAS;
logic [1:0] w_sdr_n_CAS;
logic [1:0] w_sdr_n_WE;
logic [3:0] w_sdr_BA;
logic [25:0] w_sdr_ADDR;
logic [31:0] w_sdr_DATA;
logic [31:0] w_sdr_DATA_oe;
logic [3:0] w_sdr_DQM;

assign o_sdr_CKE = w_sdr_CKE[0];    //Using SOFT ddio, ignore second cycle
assign o_sdr_n_CS = w_sdr_n_CS[0];
assign o_sdr_n_RAS = w_sdr_n_RAS[0];
assign o_sdr_n_CAS = w_sdr_n_CAS[0];
assign o_sdr_n_WE = w_sdr_n_WE[0];
assign o_sdr_BA = w_sdr_BA[0+:2];
assign o_sdr_ADDR = w_sdr_ADDR[0+:13];
assign o_sdr_DATA = w_sdr_DATA[0+:16];
assign o_sdr_DATA_oe = w_sdr_DATA_oe[0+:16];
assign o_sdr_DQM = w_sdr_DQM[0+:2];

// What should happen when the cpu writes something?
// 1. Address should already be calculated from the memory mapper, don't need to worry about it
// 2. Data byte position needs to be determined. Each write is 32 bits, so the dm bits need to 
//    be set and the byte shifted to the correct position
// 3. write enable and last should be set high. Only ever do bursts of 1.
// 4. Sample wr_ack and when it goes high, release write_enable and last

// What should happen when the cpu reads something?
// 1. Address should already be calculated from the memory mapper, don't need to worry about it
// 2. read_enable and last should be set high. Only ever to bursts of 1.
// 3. Sample rd_ack and when it goes high, release read_enable and last
// 4. Sample read_valid signal. When it is high, grab the data on the on the bus.
//    The returned data will be 16 bit, so you need to extract the correct byte. (or will it be 32?)

// when writing, the write data is only valid on a falling edge.
// Really all of this should be done on falling edges.
// But basically if we are in access, and cpuclk goes low, go back to wait.
// If something actually happened, we would be in one of the read/write states.

enum bit [2:0] {ACCESS, PRE_READ, READ_WAIT, PRE_WRITE, WRITE_WAIT, WAIT} state, next_state;

logic w_read, w_write, w_last;
logic [23:0] w_addr, r_addr;
logic [31:0] w_data_i, w_data_o;
logic [3:0] w_dm, r_dm;

logic w_wr_ack, w_rd_ack, w_rd_valid;

logic [7:0] data, _data;
logic w_data_valid;

logic [31:0] r_write_data;

logic [1:0] counter, next_counter;

logic [7:0] o_data_next;

logic r_wait;
logic _r_wait;
assign o_wait = r_wait & i_cs;

// we need to assert rdy low until a falling edge if a reset happens

always @(posedge i_sysclk or posedge i_arst) begin
    if (i_arst == '1) begin
        r_wait <= '0;
        _r_wait <= '0;
    end else begin
        if (o_dbg_ref_req) begin
            r_wait <= '1;
        end else if (i_cpuclk == '1) begin
            _r_wait <= '1;
        end

        if (i_cpuclk == '0) begin
            if (_r_wait) begin
                _r_wait <= '0;
                r_wait <= '0;
            end
        end
    end

    if (i_arst) begin
        state <= WAIT;
        counter <= '0;
    end else begin
        state <= next_state;
        counter <= next_counter;
        r_write_data <= w_data_i;
        r_addr <= w_addr;
        r_dm <= w_dm;
    end

    o_data <= o_data_next;
end

//because of timing issues, We really need to trigger
//the write on the falling edge of phi2. There is a 2ns
//delay between the rising edge of phi2 and data valid
//Since the address is valid on the previous falling edge,
//Reads can occur on the rising edge I guess.


//so basically cpu clock goes high when cs goes high we go into a priming state
//where we wait until cs goes low. when cpu clock is low, do the actual write.

//in terms of the existing state, the access state needs to only do something
//if selected AND cpu_clock is low. If cpu clock is high, we should be in wait,
//and after the read/write is complete we should also go back to wait.

//actually that may only apply to writes, since reads should occur at the rising
//edge of i_cpuclk

//Starts out in state 0 with cpuclk low and cs high.
//Then, cpuclk goes high. This is now a valid time to read
//After this, cpuclk goes low again, this is now a valid time to write.
//so basically if cpuclk goes low when cs is low, go to wait state

//what I am thinking is basically 2 states like before. wait and access.
//we go to access when cpuclk is high and cs is high.
//we can read as soon as we want if rwn is high.
//BUT if rwb is low then we have to wait untl cpuclk goes low again.


always_comb begin
    next_state = state;
    next_counter = counter;
    
    w_addr = '0;
    w_dm = '0;
    w_read = '0;
    w_write = '0;
    w_last = '0;
    w_data_i = '0;
    w_data_valid = '0;
    _data = 0;

    if (w_data_valid) begin
        o_data_next = _data;
    end else begin
        o_data_next = o_data;
    end
    
    unique case (state)
    WAIT: begin
        if (i_cs & i_cpuclk)
            next_state = ACCESS;
    end
    
    ACCESS: begin
        // only do something if selected
        if (i_cs) begin
            w_addr = {{i_addr[24:2]}, {1'b0}};  // divide by 2, set last bit to 0
            
            if (i_rwb) begin    //read
                next_state = PRE_READ;
            end else begin      //write
                w_data_i = i_data << (8*i_addr[1:0]);
                w_dm = ~(4'b1 << i_addr[1:0]);
                next_state = PRE_WRITE;
            end
        end 
    end

    PRE_WRITE: begin
        w_data_i = r_write_data;
        w_dm = r_dm;
        //w_data_i = {4{i_data}}; //does anything get through?
        if (~i_cpuclk) begin
            w_write = '1;
            w_last = '1;
            next_state = WRITE_WAIT;
        end
    end

    WRITE_WAIT: begin                
        // stay in this state until write is acknowledged.
        w_write = '1;
        w_last = '1;
        w_data_i = r_write_data;
        w_dm = r_dm;
        w_addr = r_addr;
        if (w_wr_ack) next_state = WAIT;
    end

    PRE_READ: begin
        w_read = '1;
        w_last = '1;
        // dm is not needed for reads?
        if (w_rd_ack) next_state = READ_WAIT;
    end
    
    READ_WAIT: begin
        if (w_rd_valid) begin
            w_data_valid = '1;
            _data = w_data_o[8*i_addr[1:0]+:8];
        end

        // you must wait until the next cycle!
        if (~i_cpuclk) begin
            next_state = WAIT;
        end
    end
    
    endcase
end

//this seems scuffed
logic [23:0] addr_mux_out;
always_comb begin
    if (state == ACCESS) begin
        addr_mux_out = w_addr;
    end else begin
        addr_mux_out = r_addr;
    end
end

logic o_dbg_tRTW_done;
logic o_dbg_ref_req;
logic o_dbg_wr_ack;
logic o_dbg_rd_ack;
logic [1:0] o_dbg_n_CS;
logic [1:0] o_dbg_n_RAS;
logic [1:0] o_dbg_n_CAS;
logic [1:0] o_dbg_n_WE;
logic [3:0] o_dbg_BA;
logic [25:0] o_dbg_ADDR;
logic [31:0] o_dbg_DATA_out;
logic [31:0] o_dbg_DATA_in;
logic sdr_init_done;
logic [3:0] o_sdr_state;

assign o_ref_req = o_dbg_ref_req;
assign o_sdr_init_done = sdr_init_done;


sdram_controller u_sdram_controller(
    .i_arst(i_arst),      //Positive Controller Reset
    .i_sysclk(i_sysclk),    //Controller Clock (100MHz)
    .i_sdrclk(i_sdrclk),    //t_su and t_ac clock. Double sysclk (200MHz)
    .i_tACclk(i_tACclk),    //t_ac clock. Also double sysclk, but different pll for tuning
    .i_pll_locked(1'b1),    //There exists a pll locked output from the pll, not sure why they don't use it.
    
    .i_we(w_write),         //Write enable. Can only be de-asserted if i_last is asserted and o_wr_ack is sampled high.
    .i_re(w_read),          //Read enable. Can only be de-asserted if i_last is asserted and o_rd_ack is sampled high.
    .i_last(w_last),        //Set to high to indicate the last transfer of a burst write or read.
    .i_addr(addr_mux_out),        //SDRAM physical address B R C. For half rate, only even addresses.
    .i_din(r_write_data),   //Data to write to SDRAM. Twice normal width when running at half speed (hence the even addresses)
    .i_dm(r_dm),              //dm (r_dm)
    .o_dout(w_data_o),      //Data read from SDRAM, doubled as above.
    .o_sdr_init_done(sdr_init_done),     //Indicates that the SDRAM initialization is done.
    .o_wr_ack(w_wr_ack),    //Write acknowledge, handshake with we
    .o_rd_ack(w_rd_ack),    //Read acknowledge, handshake with re
    .o_rd_valid(w_rd_valid),//Read valid. The data on o_dout is valid
    
    .o_sdr_CKE(w_sdr_CKE),
    .o_sdr_n_CS(w_sdr_n_CS),
    .o_sdr_n_RAS(w_sdr_n_RAS),
    .o_sdr_n_CAS(w_sdr_n_CAS),
    .o_sdr_n_WE(w_sdr_n_WE),
    .o_sdr_BA(w_sdr_BA),
    .o_sdr_ADDR(w_sdr_ADDR),
    .o_sdr_DATA(w_sdr_DATA),
    .o_sdr_DATA_oe(w_sdr_DATA_oe),
    .i_sdr_DATA({{16'b0}, {i_sdr_DATA}}),
    .o_sdr_DQM(w_sdr_DQM),
    
    //Does include debug signals.
    
    .o_sdr_state(o_sdr_state),
    
    .o_dbg_tRTW_done ( o_dbg_tRTW_done ),
    .o_dbg_ref_req ( o_dbg_ref_req ),
    .o_dbg_wr_ack ( o_dbg_wr_ack ),
    .o_dbg_rd_ack ( o_dbg_rd_ack ),
    .o_dbg_n_CS ( o_dbg_n_CS ),
    .o_dbg_n_RAS ( o_dbg_n_RAS ),
    .o_dbg_n_CAS ( o_dbg_n_CAS ),
    .o_dbg_n_WE ( o_dbg_n_WE ),
    .o_dbg_BA ( o_dbg_BA ),
    .o_dbg_ADDR ( o_dbg_ADDR ),
    .o_dbg_DATA_out ( o_dbg_DATA_out ),
    .o_dbg_DATA_in ( o_dbg_DATA_in )
);

endmodule
