module leds
(
    input clk,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,

    output logic [7:0] o_leds
);

logic [7:0] _data;

assign o_leds = ~_data;

assign o_data = _data;

always @(negedge clk) begin
    if (~rwb & cs) begin
        _data <= i_data;
    end
end

endmodule