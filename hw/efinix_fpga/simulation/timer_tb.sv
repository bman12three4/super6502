module sim();

timeunit 10ns;
timeprecision 1ns;

logic clk;
logic rwb;
logic clk_50;
logic reset;

logic [2:0] addr;
logic [7:0] i_data;
logic [7:0] o_data;
logic cs;
logic irq;

timer dut(
    .*);

always #1 clk_50 = clk_50 === 1'b0;
always #100 clk = clk === 1'b0;

task write_reg(input logic [2:0] _addr, input logic [7:0] _data);
    @(negedge clk);
    cs <= '1;
    addr <= _addr;
    rwb <= '0;
    i_data <= '1;
    @(posedge clk);
    i_data <= _data;
    @(negedge clk);
    cs <= '0;
    rwb <= '1;
endtask

task read_reg(input logic [2:0] _addr, output logic [7:0] _data);
    @(negedge clk);
    cs <= '1;
    addr <= _addr;
    rwb <= '1;
    i_data <= '1;
    @(posedge clk);
    _data <= o_data;
    @(negedge clk);
    cs <= '0;
    rwb <= '1;
endtask

initial
begin
    $dumpfile("timer.vcd");
    $dumpvars(0,sim);
end

logic [7:0] read_data;

initial begin
    reset <= '1;
    repeat(5) @(posedge clk);
    reset <= '0;

    write_reg(5, 16);

    repeat(1024) @(posedge clk);

    repeat(10) begin
        read_reg(0, read_data);
        $display("Read: %d", read_data);
        repeat(1024) @(posedge clk);
    end
    $finish();

end

endmodule
