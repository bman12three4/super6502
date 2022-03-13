module SevenSeg(
    input clk,
    input rst,
    
    input rw,

    input [7:0] data,
    input cs,
    input [1:0] addr,
    
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

logic [7:0] _data [3:0];

always_ff @(posedge clk) begin
    if (rst)
        _data = '{default:'0};
    if (~rw & cs)
        _data[addr] <= data;
end


logic [3:0] hex_4[5:0];

assign {hex_4[5], hex_4[4]} = _data[2];
assign {hex_4[3], hex_4[2]} = _data[1];
assign {hex_4[1], hex_4[0]} = _data[0];

HexDriver hex_drivers[5:0] (hex_4, {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0});


endmodule
