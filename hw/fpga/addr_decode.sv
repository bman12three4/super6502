module addr_decode(
    input logic [23:0] addr,
    output logic sdram_cs,
    output logic rom_cs,
    output logic hex_cs,
    output logic uart_cs,
    output logic irq_cs,
    output logic board_io_cs,
    output logic mm_cs1,
    output logic mm_cs2,
    output logic sd_cs
);

assign rom_cs = addr >= 24'h008000 && addr < 24'h010000;
assign sdram_cs = addr < 24'h007fe0 || addr >= 24'h010000;
assign mm_cs1 = addr >= 24'h007fe0 && addr < 24'h007ff0;
assign hex_cs = addr >= 24'h007ff0 && addr < 24'h007ff4;
assign uart_cs = addr >= 24'h007ff4 && addr < 24'h007ff6;
assign board_io_cs = addr == 24'h007ff6;
assign mm_cs2 = addr == 24'h007ff7;
assign sd_cs = addr >= 24'h007ff8 && addr < 24'h007ffd;
assign irq_cs  = addr == 24'h007fff;

endmodule
