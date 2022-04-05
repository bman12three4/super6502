module addr_decode(
    input logic [15:0] addr,
    output logic sdram_cs,
    output logic rom_cs,
    output logic hex_cs,
    output logic uart_cs,
    output logic irq_cs,
    output logic board_io_cs,
	output logic mm_cs1,
	output logic mm_cs2
);

assign rom_cs = addr >= 16'h8000;
assign sdram_cs = addr < 16'h7ff0;
assign hex_cs = addr >= 16'h7ff0 && addr < 16'h7ff4;
assign uart_cs = addr >= 16'h7ff4 && addr < 16'h7ff6;
assign board_io_cs = addr == 16'h7ff6;
assign mm_cs2 = addr == 16'h7ff7;
assign mm_cs1 = addr >= 16'h7ff8 && addr < 16'h7ffc;
assign irq_cs  = addr == 16'h7fff;

endmodule
