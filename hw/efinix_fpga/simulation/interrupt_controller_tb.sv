module sim();

timeunit 10ns;
timeprecision 1ns;

logic clk;
logic reset;
logic [2:0] addr;
logic [7:0] i_data;
logic [7:0] o_data;
logic cs;
logic rwb;

logic irqb_master;
logic irqb0, irqb1, irqb2, irqb3, irqb4, irqb5, irqb6, irqb7;

interrupt_controller dut(
    .*);

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
    $dumpfile("interrupt_controller.vcd");
    $dumpvars(0,sim);
end

initial begin
    reset <= '1;
    irqb0 <= '1;
    irqb1 <= '1;
    irqb2 <= '1;
    irqb3 <= '1;
    irqb4 <= '1;
    irqb5 <= '1;
    irqb6 <= '1;
    irqb7 <= '1;
    repeat(5) @(posedge clk);
    reset <= '0;

    repeat(5) @(posedge clk);

    irqb0 <= '0;

    repeat(5) @(posedge clk);

    $finish();
end

endmodule
