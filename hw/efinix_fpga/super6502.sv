
module super6502(
    input                   clk_50,
    input                   pll_inst1_CLKOUT0,
    input   logic           rst_n,
    input   logic           button_1,

    input   logic [15:0]    cpu_addr,
    inout   logic [7:0]     cpu_data,

    input   logic           cpu_vpb,
    input   logic           cpu_mlb,
    input   logic           cpu_rwb,
    input   logic           cpu_sync,

    output  logic           cpu_led,
    output  logic           cpu_resb,
    output  logic           cpu_rdy,
    output  logic           cpu_sob,
    output  logic           cpu_irqb,
    output  logic           cpu_phi2,
    output  logic           cpu_be,
    output  logic           cpu_nmib,

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

    input   logic           UART_RXD,
    output  logic           UART_TXD,

    input                   [7:0] SW,
    output  logic           [7:0] LED,

    inout   logic [15: 2]   ARDUINO_IO,

    ///////// SDRAM /////////
    output             DRAM_CLK,
    output             DRAM_CKE,
    output   [12: 0]   DRAM_ADDR,
    output   [ 1: 0]   DRAM_BA,
    inout    [15: 0]   DRAM_DQ,
    output             DRAM_LDQM,
    output             DRAM_UDQM,
    output             DRAM_CS_N,
    output             DRAM_WE_N,
    output             DRAM_CAS_N,
    output             DRAM_RAS_N
  );

logic rst;
assign rst = ~rst_n;

logic clk;

logic [7:0] cpu_data_in;
assign cpu_data_in = cpu_data;

logic [7:0] cpu_data_out;
assign cpu_data = cpu_rwb ? cpu_data_out : 'z;

logic o_sd_cmd, i_sd_cmd;
logic o_sd_data, i_sd_data;

assign ARDUINO_IO[11] = o_sd_cmd ? 1'bz : 1'b0;
assign ARDUINO_IO[12] = o_sd_data ? 1'bz : 1'b0;
assign ARDUINO_IO[13] = cpu_phi2;
assign ARDUINO_IO[6] = 1'b1;

assign i_sd_cmd = ARDUINO_IO[11];
assign i_sd_data = ARDUINO_IO[12];

logic [7:0] rom_data_out;
logic [7:0] sdram_data_out;
logic [7:0] uart_data_out;
logic [7:0] irq_data_out;
logic [7:0] board_io_data_out;
logic [7:0] mm_data_out;
logic [7:0] sd_data_out;

logic sdram_cs;
logic rom_cs;
logic hex_cs;
logic uart_cs;
logic irq_cs;
logic board_io_cs;
logic mm_cs1;
logic mm_cs2;
logic sd_cs;

assign clk = pll_inst1_CLKOUT0;

always @(posedge clk) begin
    cpu_phi2 <= ~cpu_phi2;
end

assign cpu_rdy = '1;
assign cpu_sob = '0;
assign cpu_resb = rst_n;
assign cpu_be = '1;
assign cpu_nmib = '1;
assign cpu_irqb = irq_data_out == 0;

logic [11:0] mm_MO;

logic [23:0] mm_addr;
assign mm_addr = {mm_MO, cpu_addr[11:0]};

memory_mapper memory_mapper(
    .clk(clk),
    .rst(rst),
    .rw(cpu_rwb),
    .cs(mm_cs1),
    .MM_cs(mm_cs2),
    .RS(cpu_addr[3:0]),
    .MA(cpu_addr[15:12]),
    .data_in(cpu_data_in),
    .data_out(mm_data_out),
    .MO(mm_MO)
);

addr_decode decode(
    .addr(mm_addr),
    .sdram_cs(sdram_cs),
    .rom_cs(rom_cs),
    .hex_cs(hex_cs),
    .uart_cs(uart_cs),
    .irq_cs(irq_cs),
    .board_io_cs(board_io_cs),
    .mm_cs1(mm_cs1),
    .mm_cs2(mm_cs2),
    .sd_cs(sd_cs)
);


always_comb begin
    if (sdram_cs)
        cpu_data_out = sdram_data_out;
    else if (rom_cs)
        cpu_data_out = rom_data_out;
    else if (uart_cs)
        cpu_data_out = uart_data_out;
    else if (irq_cs)
        cpu_data_out = irq_data_out;
    else if (board_io_cs)
        cpu_data_out = board_io_data_out;
    else if (mm_cs1)
        cpu_data_out = mm_data_out;
    else if (sd_cs)
        cpu_data_out = sd_data_out;
    else
        cpu_data_out = 'x;
end


sdram_adapter u_sdram_adapter(
    .rst(rst),
    .clk_50(clk_50),
    .cpu_clk(cpu_phi2),
    .addr(mm_addr),
    .sdram_cs(sdram_cs),
    .rwb(cpu_rwb),
    .data_in(cpu_data_in),
    .data_out(sdram_data_out),

    //SDRAM
    .DRAM_CLK(DRAM_CLK),                           //clk_sdram.clk
    .DRAM_ADDR(DRAM_ADDR),                         //sdram_wire.addr
    .DRAM_BA(DRAM_BA),                             //.ba
    .DRAM_CAS_N(DRAM_CAS_N),                       //.cas_n
    .DRAM_CKE(DRAM_CKE),                           //.cke
    .DRAM_CS_N(DRAM_CS_N),                         //.cs_n
    .DRAM_DQ(DRAM_DQ),                             //.dq
    .DRAM_UDQM(DRAM_UDQM),                         //.dqm
    .DRAM_LDQM(DRAM_LDQM),
    .DRAM_RAS_N(DRAM_RAS_N),                       //.ras_n
    .DRAM_WE_N(DRAM_WE_N)                          //.we_n
);


rom boot_rom(
    .address(cpu_addr[14:0]),
    .clock(clk),
    .q(rom_data_out)
);

SevenSeg segs(
    .clk(clk),
    .rst(rst),
    .rw(cpu_rwb),
    .data(cpu_data_in),
    .cs(hex_cs),
    .addr(cpu_addr[1:0]),
    .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5)
);

board_io board_io(
    .clk(clk),
    .rst(rst),
    .rw(cpu_rwb),
    .data_in(cpu_data_in),
    .data_out(board_io_data_out),
    .cs(board_io_cs),
    .led(LED),
    .sw(SW)
);

logic uart_irq;

uart uart(
    .clk_50(clk_50),
    .clk(clk),
    .rst(rst),
    .rw(cpu_rwb),
    .data_in(cpu_data_in),
    .cs(uart_cs),
    .addr(cpu_addr[1:0]),
    .RXD(UART_RXD),
    .TXD(UART_TXD),
    .irq(uart_irq),
    .data_out(uart_data_out)
);

sd_controller sd_controller(
    .clk(clk),
    .sd_clk(cpu_phi2),
    .rst(rst),
    .addr(cpu_addr[2:0]),
    .data(cpu_data_in),
    .cs(sd_cs),
    .rw(cpu_rwb),

    .i_sd_cmd(i_sd_cmd),
    .o_sd_cmd(o_sd_cmd),

    .i_sd_data(i_sd_data),
    .o_sd_data(o_sd_data),

    .data_out(sd_data_out)
);

always_ff @(posedge clk_50) begin
    if (rst)
        irq_data_out <= '0;
    else if (irq_cs && ~cpu_rwb)
        irq_data_out <= irq_data_out & cpu_data_in;

    else begin
        if (~button_1)
            irq_data_out[0] <= '1;
        if (uart_irq)
            irq_data_out[1] <= '1;
    end

end

endmodule

