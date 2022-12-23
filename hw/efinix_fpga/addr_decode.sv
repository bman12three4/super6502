module addr_decode
(
    input [15:0] i_addr,

    output o_rom_cs,
    output o_leds_cs,
    output o_sdram_cs
);

assign o_rom_cs = i_addr >= 16'hf000 && i_addr <= 16'hffff;
assign o_leds_cs = i_addr == 16'hefff;
assign o_sdram_cs = i_addr < 16'h8000;

endmodule