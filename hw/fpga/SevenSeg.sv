module SevenSeg(
    input clk,
    input rst,
    
    input rw,

    input [7:0] data,
    input cs,
    input addr,
    
    output logic [6:0] HEX0, HEX1, HEX2, HEX3
);

logic [7:0] _data [2];

always_ff @(posedge clk) begin
    if (rst)
        _data = '{default:'0};
    if (~rw)
        _data[addr] <= data;
end


logic [3:0] hex_4[3:0];

assign {hex_4[3], hex_4[2]} = _data[1];
assign {hex_4[1], hex_4[0]} = _data[0];

HexDriver hex_drivers[3:0] (hex_4, {HEX3, HEX2, HEX1, HEX0});


endmodule
