module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk_50, clk, rst, cs;
logic [1:0] addr;
logic [7:0] data_in, data_out;
logic rw;
logic RXD, TXD;

uart dut(.*);

always #1 clk_50 = clk_50 === 1'b0;

initial begin
    rst <= '1;
    repeat(5) @(posedge clk_50);
    rst <= '0;
    @(posedge clk_50);
end

endmodule
