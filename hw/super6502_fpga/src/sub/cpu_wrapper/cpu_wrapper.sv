module cpu_wrapper #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    /* Clocks and Reset */
    input logic i_clk_cpu,
    input logic i_clk_100,
    input logic i_rst,

    /* CPU Control Signals */
    output logic o_cpu_rst,
    output logic o_cpu_rdy,
    output logic o_cpu_be,
    output logic o_cpu_irqb,
    output logic o_cpu_nmib,
    output logic o_cpu_sob,

    /* CPU Status Signals */
    input logic i_cpu_rwb,
    input logic i_cpu_sync,
    input logic i_cpu_vpb,
    input logic i_cpu_mlb,

    /* CPU Address and Data */
    input logic [15:0] i_cpu_addr,
    input logic [7:0] i_cpu_data,
    output logic [7:0] o_cpu_data,

    /* AXI4-Lite signals */
    output logic o_AWVALID,
    input logic i_AWREADY,
    output logic [ADDR_WIDTH-1:0] o_AWADDR,
    output logic [2:0] o_AWPROT,

    output logic o_WVALID,
    input logic i_WREADY,
    output logic [DATA_WIDTH-1:0] o_WDATA,
    output logic [DATA_WIDTH/8-1:0] o_WSTRB,

    input logic i_BVALID,
    output logic o_BREADY,
    input logic [1:0] i_BRESP,

    output logic o_ARVALID,
    input logic i_ARREADY,
    output logic [ADDR_WIDTH-1:0] o_ARADDR,
    output logic [2:0] o_ARPROT,

    input logic i_RVALID,
    output logic o_RREADY,
    input logic [DATA_WIDTH-1:0] i_RDATA,
    input logic [1:0] i_RRESP,

    /* interrupt signals */
    input logic i_irq,
    input logic i_nmi
);

typedef enum logic [3:0] {
    RESET,
    IDLE,
    ADDR_CONTROL,
    READ_VALID,
    READ_DATA,
    WRITE_VALID,
    GET_WRITE_DATA,
    WRITE_DATA,
    STALL
} state_t;

state_t state, state_next;

logic w_status_empty;
logic w_status_r_en;

logic r_rwb, r_sync, r_vpb, r_mlb;
logic r_rwb_next, r_sync_next, r_vpb_next, r_mlb_next;

logic [15:0] r_addr, r_addr_next;

logic w_write_data_en;
logic [7:0] r_write_data, r_write_data_next;
logic w_write_data_empty;

logic [2:0] counter;
logic w_reset;

always @(posedge i_clk_cpu) begin
    if (i_rst) begin
        counter <= '1;
    end else if (counter) begin
        counter <= counter - 3'd1;
    end
end

assign w_reset = |counter;

ff_cdc #(
    .RESET_VAL(0)
) u_cpu_rst_cdc (
    .rst(i_rst),
    .clk(i_clk_cpu),
    .data_a(~w_reset),
    .data_b(o_cpu_rst)
);

ff_cdc u_cpu_irq_cdc (
    .rst(i_rst),
    .clk(i_clk_cpu),
    .data_a(~i_irq),
    .data_b(o_cpu_irqb)
);

ff_cdc u_cpu_nmi_cdc (
    .rst(i_rst),
    .clk(i_clk_cpu),
    .data_a(~i_nmi),
    .data_b(o_cpu_nmib)
);

// This fifo says it has a bug with back to back writes, but maybe that
// is only for fast -> slow? this is slow -> fast.
// async_fifo #(
//     .WIDTH(20),
//     .A_SIZE(3)
// ) u_status_addr_fifo (
//     .i_rst_a(o_cpu_rst),
//     .i_clk_a(i_clk_cpu),
//     .i_rst_b(i_rst),
//     .i_clk_b(i_clk_100),
//     .w_en('1),  // investigate this
//     .i_data({i_cpu_rwb, i_cpu_sync, i_cpu_vpb, i_cpu_mlb, i_cpu_addr}),
//     .o_full(),
//     .r_en(w_status_r_en),
//     .o_data({r_rwb_next, r_sync_next, r_vpb_next, r_mlb_next, r_addr_next}),
//     .o_empty(w_status_empty)
// );


logic [1:0] flag;

assign w_status_empty = ~flag[0];

assign r_rwb_next = i_cpu_rwb;
assign r_sync_next = i_cpu_sync;
assign r_vpb_next = i_cpu_vpb;
assign r_mlb_next = i_cpu_mlb;
assign r_addr_next = i_cpu_addr;

always @(posedge i_clk_100 or posedge i_rst) begin
    if (i_rst) begin
        flag <= '0;
    end else begin
        if (i_clk_cpu) begin
            if (flag == '0) begin
                flag <= 2'h1;
            end else if (flag == 2'h1) begin
                flag <= 2'h2;
            end
        end else begin
            flag <= '0;
        end
    end 
end

// // This uses inverted clock, remember in sdc?
// async_fifo #(
//     .WIDTH(8),
//     .A_SIZE(3)
// ) u_write_data_fifo (
//     .i_rst_a(o_cpu_rst),
//     .i_clk_a(~i_clk_cpu),
//     .i_rst_b(i_rst),
//     .i_clk_b(i_clk_100),
//     .w_en('1),
//     .i_data(i_cpu_data),
//     .o_full(),
//     .r_en(w_write_data_en),
//     .o_data(r_write_data_next),
//     .o_empty(w_write_data_empty)
// );


// Really bad double flop bus
always @(negedge i_clk_cpu) begin
    r_write_data_next <= i_cpu_data;
end


logic [1:0] flag2;

assign w_write_data_empty = ~flag2[0];

always @(posedge i_clk_100 or posedge i_rst) begin
    if (i_rst) begin
        flag2 <= '0;
    end else begin
        if (~i_clk_cpu) begin
            if (flag2 == '0) begin
                flag2 <= 2'h1;
            end else if (flag2 == 2'h1) begin
                flag2 <= 2'h2;
            end
        end else begin
            flag2 <= '0;
        end
    end 
end

localparam MAX_DELAY = 4;

logic [7:0] cycle_counter;
logic too_late;

logic [2:0] rdy_dly;
logic potential_rdy;
logic did_delay, did_delay_next;

assign potential_rdy = |rdy_dly;

assign too_late = cycle_counter > MAX_DELAY ? 1 : 0;

always_ff @(posedge i_clk_100 or posedge i_rst) begin
    if (i_rst) begin
        cycle_counter <= '0;
        rdy_dly <= '0;
    end else begin
        if (i_clk_cpu) begin
            cycle_counter <= cycle_counter + 1;
        end else begin
            cycle_counter <= '0;
        end

        rdy_dly <= {rdy_dly[1:0], too_late};
    end
end

logic [7:0] read_data, read_data_next;
assign o_cpu_data = read_data;

always_comb begin
    state_next = state;

    // Set defaults
    o_AWVALID = '0;
    o_AWADDR = '0;
    o_AWPROT = '0;  
    o_WVALID = '0;
    o_WDATA = '0;
    o_WSTRB = '0;   
    o_BREADY = '0;  
    o_ARVALID = '0;
    o_ARADDR = '0;
    o_ARPROT = '0;
    o_RREADY = '0;

    o_cpu_rdy = '1;

    read_data_next = read_data;
    did_delay_next = did_delay;

    case (state)
    RESET: begin
        // Is this a CDC violation?
        if (i_cpu_addr == 16'hFFFC) begin
            state_next = IDLE;
        end
    end

    IDLE: begin
        if (~w_status_empty) begin
            state_next = ADDR_CONTROL;
        end

        did_delay_next = '0;
    end

    ADDR_CONTROL: begin
        if (r_rwb) begin
            state_next = READ_VALID;
        end else begin
            state_next = WRITE_VALID;
        end
    end

    READ_VALID: begin
        o_ARVALID = '1;
        // $display("%x %x %x", o_ARVALID, i_ARREADY, o_ARVALID & i_ARREADY);

        if (o_ARVALID & i_ARREADY) begin
            // $display("AHHHHHH");
            state_next = READ_DATA;
            // $display("next state: %x", state_next);
        end

        o_ARADDR = {r_addr[15:2], 2'b0};
    end

    READ_DATA: begin
        if (potential_rdy) begin
            state_next = READ_DATA;
            o_cpu_rdy = ~potential_rdy;
            did_delay_next = '1;
        end

        if (i_RVALID) begin
            if (did_delay || potential_rdy) begin
                state_next = STALL;
            end else begin
                state_next = IDLE;
            end
            read_data_next = i_RDATA[8*r_addr[1:0] +: 8];
        end

        o_RREADY = '1;
    end

    WRITE_VALID: begin
        if (~w_write_data_empty) begin
            state_next = WRITE_DATA;
        end
    end

    GET_WRITE_DATA: begin
        $error("GET_WRITE_DATA not implemented");
        state_next = IDLE;
    end

    WRITE_DATA: begin
        o_AWVALID = '1;
        o_AWADDR = {r_addr[15:2], 2'b0};
        o_WVALID = '1;
        o_WSTRB = 4'b1 << r_addr[1:0];
        o_WDATA = r_write_data << 8*r_addr[1:0];

        o_BREADY = '1;
        if (i_BVALID) begin
            state_next = IDLE;
        end
    end

    STALL: begin
        // kind of dumb
        if (cycle_counter == 1) begin
            state_next = IDLE;
        end

        o_cpu_rdy = ~potential_rdy;
    end

    default: begin
        // $error("Invalid state");
        state_next = IDLE;
    end

    endcase
end

always_ff @(posedge i_clk_100 or posedge i_rst) begin
    if (i_rst) begin
        r_rwb <= '1;    // start as 1 to indicate read.
        r_sync <= '0;
        r_vpb <= '0;
        r_mlb <= '0;
        r_addr <= '0;
        read_data <= '0;
        r_write_data <= '0;
        did_delay <= '0;

        state <= RESET;
    end else begin
        if (~w_status_empty) begin
            w_status_r_en <= '1;
            r_rwb <= r_rwb_next;
            r_sync <= r_sync_next;
            r_vpb <= r_vpb_next;
            r_mlb <= r_mlb_next;
            r_addr <= r_addr_next;
        end else begin
            w_status_r_en <= '0;
        end

        read_data <= read_data_next;
        state <= state_next;
        did_delay <= did_delay_next;

        r_write_data <= r_write_data_next;
    end
end

endmodule