module addr_decode(
    input logic [15:0] addr,
    output logic ram_cs,
    output logic rom_cs,
    output logic hex_cs
);

assign rom_cs = addr[15];
assign ram_cs = ~addr[15] && addr < 16'h7ff0;
assign hex_cs = addr >= 16'h7ff0 && addr < 16'h7ff4;

endmodule
