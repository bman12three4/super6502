module addr_decode
(
    input [15:0] i_addr,

    output o_rom_cs,
    output o_leds_cs,
    output o_timer_cs,
    output o_multiplier_cs,
    output o_divider_cs,
    output o_uart_cs,
    output o_spi_cs,
    output o_mapper_cs,
    output o_sdram_cs
);

assign o_rom_cs = i_addr >= 16'hf000 && i_addr <= 16'hffff;
assign o_timer_cs = i_addr >= 16'heff8 && i_addr <= 16'heffb;
assign o_multiplier_cs = i_addr >= 16'heff0 && i_addr <= 16'heff7;
assign o_divider_cs = i_addr >= 16'hefe8 && i_addr <= 16'hefef;
assign o_uart_cs = i_addr >= 16'hefe6 && i_addr <= 16'hefe7;
assign o_spi_cs = i_addr >= 16'hefd8 && i_addr <= 16'hefdb;
assign o_mapper_cs = i_addr >= 16'hefb7 && i_addr <= 16'hefd7;
assign o_leds_cs = i_addr == 16'hefff;
assign o_sdram_cs = i_addr < 16'he000;

endmodule