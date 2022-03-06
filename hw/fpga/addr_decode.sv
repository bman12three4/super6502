module addr_decode(
    input logic [15:0] addr,
    output logic ram_cs,
    output logic rom_cs
);

assign rom_cs = addr[15];
assign ram_cs = ~addr[15];

endmodule
