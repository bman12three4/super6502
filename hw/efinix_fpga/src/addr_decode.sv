module addr_decode
(
    input [24:0] i_addr,

    input config_reg_sel,

    output o_rom_cs,
    output o_leds_cs,
    output o_timer_cs,
    output o_multiplier_cs,
    output o_divider_cs,
    output o_uart_cs,
    output o_spi_cs,
    output o_sdram_cs
);

assign o_rom_cs = (i_addr >= 25'hf000 && i_addr <= 25'hffff) && ~config_reg_sel;
assign o_timer_cs = (i_addr >= 25'heff8 && i_addr <= 25'heffb) && ~config_reg_sel;
assign o_multiplier_cs = (i_addr >= 25'heff0 && i_addr <= 25'heff7) && ~config_reg_sel;
assign o_divider_cs = (i_addr >= 25'hefe8 && i_addr <= 25'hefef) && ~config_reg_sel;
assign o_uart_cs = (i_addr >= 25'hefe6 && i_addr <= 25'hefe7) && ~config_reg_sel;
assign o_spi_cs = (i_addr >= 25'hefd8 && i_addr <= 25'hefdb) && ~config_reg_sel;
assign o_leds_cs = (i_addr == 25'hefff) && ~config_reg_sel;
assign o_sdram_cs = (i_addr < 25'he000 || i_addr >= 25'h10000) && ~config_reg_sel;

endmodule