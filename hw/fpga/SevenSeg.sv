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

logic [6:0] _HEX0, _HEX1, _HEX2, _HEX3, _HEX4, _HEX5;

HexDriver hex_drivers[5:0] (hex_4, {_HEX5, _HEX4, _HEX3, _HEX2, _HEX1, _HEX0});

assign HEX0 = _HEX0 | {7{~_data[3][0]}};
assign HEX1 = _HEX1 | {7{~_data[3][1]}};
assign HEX2 = _HEX2 | {7{~_data[3][2]}};
assign HEX3 = _HEX3 | {7{~_data[3][3]}};
assign HEX4 = _HEX4 | {7{~_data[3][4]}};
assign HEX5 = _HEX5 | {7{~_data[3][5]}};


endmodule
