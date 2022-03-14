
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
    output  logic           UART_TXD
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
logic [7:0] uart_data_out;

logic ram_cs;
logic rom_cs;
logic hex_cs;
logic uart_cs;

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
assign cpu_irqb = button_1;

addr_decode decode(
    .addr(cpu_addr),
    .ram_cs(ram_cs),
    .rom_cs(rom_cs),
    .hex_cs(hex_cs),
    .uart_cs(uart_cs)
);


always_comb begin
    if (ram_cs)
        cpu_data_out = ram_data_out;
    else if (rom_cs)
        cpu_data_out = rom_data_out;
    else if (uart_cs)
        cpu_data_out = uart_data_out;
    else
        cpu_data_out = 'x;
end




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
    .data_out(uart_data_out)
);
 
endmodule
 