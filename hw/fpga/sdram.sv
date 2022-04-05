module sdram(
    input rst,
    input clk_50,
    input cpu_clk,
    input [23:0] addr,
    input sdram_cs,
    input rwb,
    input [7:0] data_in,
    output [7:0] data_out,

    ///////// SDRAM /////////
    output wire             DRAM_CLK,
    output wire             DRAM_CKE,
    output wire   [12: 0]   DRAM_ADDR,
    output wire   [ 1: 0]   DRAM_BA,
    inout  wire   [15: 0]   DRAM_DQ,
    output wire             DRAM_LDQM,
    output wire             DRAM_UDQM,
    output wire             DRAM_CS_N,
    output wire             DRAM_WE_N,
    output wire             DRAM_CAS_N,
    output wire             DRAM_RAS_N
);

enum logic {ACCESS, WAIT } state, next_state;
logic ack;
logic _sdram_cs;

always @(posedge clk_50) begin
    if (rst)
        state <= ACCESS;
    else
        state <= next_state;
end

always_comb begin
    next_state = state;

    case (state)
        ACCESS: begin
            if (sdram_cs & ~rwb & ack)
                next_state = WAIT;
        end
        WAIT: begin
            if (~cpu_clk)
                next_state = ACCESS;
        end
    endcase
end

always_comb begin
    _sdram_cs = '0;

    case (state)
        ACCESS: begin
            _sdram_cs = sdram_cs & cpu_clk;
        end
        WAIT: begin
            _sdram_cs = '0;
        end
    endcase
end

sdram_platform u0 (
    .clk_clk             (clk_50),                      //        clk.clk
    .reset_reset_n       (1'b1),                        //      reset.reset_n
    .ext_bus_address     (addr),                    //    ext_bus.address
    .ext_bus_byte_enable (1'b1),                        //           .byte_enable
    .ext_bus_read        (_sdram_cs & rwb),         //           .read
    .ext_bus_write       (_sdram_cs & ~rwb),        //           .write
    .ext_bus_write_data  (data_in),                 //           .write_data
    .ext_bus_acknowledge (ack),                         //           .acknowledge
    .ext_bus_read_data   (data_out),              //           .read_data
    //SDRAM
    .sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
    .sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
    .sdram_wire_ba(DRAM_BA),                             //.ba
    .sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
    .sdram_wire_cke(DRAM_CKE),                           //.cke
    .sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
    .sdram_wire_dq(DRAM_DQ),                             //.dq
    .sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
    .sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
    .sdram_wire_we_n(DRAM_WE_N)                          //.we_n
);

endmodule
