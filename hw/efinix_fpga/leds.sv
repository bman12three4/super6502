module leds
(
    input clk,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,

    output logic [7:0] o_leds
);

logic re, we;
assign re = rwb & cs;
assign we = ~rwb & cs;

logic [7:0] _data;

assign o_leds = ~_data;

always @(negedge clk) begin
    if (re) begin
        o_data <= _data;
    end 
    else if (we) begin
        _data <= i_data;
    end
end

endmodule