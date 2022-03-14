module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk_50, clk, rst, cs;
logic [1:0] addr;
logic [7:0] data_in, data_out;
logic rw;
logic RXD, TXD;

logic [7:0] status;

uart dut(.*);

always #1 clk_50 = clk_50 === 1'b0;
always #100 clk = clk === 1'b0;

task write(logic [7:0] data);
    @(negedge clk);
    cs <= '1;
    addr <= '0;
    data_in <= data;
    rw <= '0;

    @(negedge clk);
    cs <= '0;
    addr <= '0;
    data_in <= 8'hxx;
    rw <= '1;

    do begin
        @(negedge clk);
        cs <= '1;
        addr <= 1'b1;
        rw <= '1;
        @(negedge clk);
    end while (data_out != 8'h0);
endtask

task puts(string s, int n);
    for (int i = 0; i < n; i++)
        write(s[i]);
endtask

initial begin
    rst <= '1;
    repeat(5) @(posedge clk);
    rst <= '0;
    rw <= '1;
    cs <= '0;
    status <= '0;

    puts("Hello, world!\n", 14);

    $finish();
end

endmodule
