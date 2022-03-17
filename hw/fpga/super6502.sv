
module super6502(
    input                   clk_50,
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


logic [7:0] rom_data_out;
logic [7:0] ram_data_out;
logic [7:0] sdram_data_out;
logic [7:0] uart_data_out;
logic [7:0] irq_data_out;

logic ram_cs;
logic sdram_cs;
logic rom_cs;
logic hex_cs;
logic uart_cs;
logic irq_cs;

cpu_clk cpu_clk(
	.inclk0(clk_50),
	.c0(clk)
);

always @(posedge clk) begin
    cpu_phi2 <= ~cpu_phi2;
end

assign cpu_rdy = '1;
assign cpu_sob = '0;
assign cpu_resb = rst_n;
assign cpu_be = '1;
assign cpu_nmib = '1;
assign cpu_irqb = irq_data_out == 0;

addr_decode decode(
    .addr(cpu_addr),
    .ram_cs(ram_cs),
    .sdram_cs(sdram_cs),
    .rom_cs(rom_cs),
    .hex_cs(hex_cs),
    .uart_cs(uart_cs),
    .irq_cs(irq_cs)
);


always_comb begin
    if (ram_cs)
        cpu_data_out = ram_data_out;
    else if (sdram_cs)
        cpu_data_out = sdram_data_out;
    else if (rom_cs)
        cpu_data_out = rom_data_out;
    else if (uart_cs)
        cpu_data_out = uart_data_out;
    else if (irq_cs)
        cpu_data_out = irq_data_out;
    else
        cpu_data_out = 'x;
end


sdram sdram(
    .rst(rst),
    .clk_50(clk_50),
    .cpu_clk(cpu_phi2),
    .addr(cpu_addr),
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

ram main_memory(
    .address(cpu_addr[14:0]),
    .clock(clk),
    .data(cpu_data_in),
    .wren(~cpu_rwb & ram_cs),
    .q(ram_data_out)
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
 