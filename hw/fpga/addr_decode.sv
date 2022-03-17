module addr_decode(
    input logic [15:0] addr,
    output logic ram_cs,
    output logic sdram_cs,
    output logic rom_cs,
    output logic hex_cs,
    output logic uart_cs,
    output logic irq_cs
);

assign rom_cs = addr >= 16'h8000;
assign ram_cs = addr < 16'h4000;
assign sdram_cs = addr >= 16'h4000 && addr < 16'h7ff0;
assign hex_cs = addr >= 16'h7ff0 && addr < 16'h7ff4;
assign uart_cs = addr >= 16'h7ff4 && addr < 16'h7ff6;
assign irq_cs  = addr == 16'h7fff;

endmodule
