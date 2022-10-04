module board_io(
    input clk,
    input rst,
    
    input rw,

    input [7:0] data_in,
    input cs,
    input [1:0] addr,
    
    output logic [7:0] data_out,

    output logic [7:0] led,
    input [7:0] sw
);

assign data_out = sw;


always_ff @(posedge clk) begin
    if (rst)
        led = '0;
    if (~rw & cs)
        led <= data_in;
end

endmodule
