`timescale 1ns/1ps

module interrupt_controller_tb();

logic r_clk_cpu;

// clk_cpu
initial begin
    r_clk_cpu <= '1;
    forever begin
        #125 r_clk_cpu <= ~r_clk_cpu;
    end
end

logic reset;
logic addr;
logic [7:0] i_data;
logic [7:0] o_data;
logic cs;
logic rwb;

logic [255:0] int_in;
logic int_out;

interrupt_controller u_interrupt_controller(
    .clk(r_clk_cpu),
    .reset(reset),
    .i_data(i_data),
    .o_data(o_data),
    .addr(addr),
    .cs(cs),
    .rwb(rwb),
    .int_in(int_in),
    .int_out(int_out2)
);

/* These should be shared */
task write_reg(input logic [4:0] _addr, input logic [7:0] _data);
    @(negedge r_clk_cpu);
    cs <= '1;
    addr <= _addr;
    rwb <= '0;
    i_data <= '1;
    @(posedge r_clk_cpu);
    i_data <= _data;
    @(negedge r_clk_cpu);
    cs <= '0;
    rwb <= '1;
endtask

task read_reg(input logic [2:0] _addr, output logic [7:0] _data);
    @(negedge r_clk_cpu);
    cs <= '1;
    addr <= _addr;
    rwb <= '1;
    i_data <= '1;
    @(posedge r_clk_cpu);
    _data <= o_data;
    @(negedge r_clk_cpu);
    cs <= '0;
    rwb <= '1;
endtask

initial begin
    repeat (5) @(posedge r_clk_cpu);
    reset = 1;
    cs = 0;
    rwb = 1;
    addr = '0;
    i_data = '0;
    int_in = '0;
    repeat (5) @(posedge r_clk_cpu);
    reset = 0;
    repeat (5) @(posedge r_clk_cpu);
    write_reg(0, 8'h10);
    write_reg(1, 8'hff);
    write_reg(0, 8'h20);
    write_reg(1, 8'hff);
    repeat (5) @(posedge r_clk_cpu);
    int_in = 1;
    @(posedge r_clk_cpu)
    int_in = 0;
    repeat (5) @(posedge r_clk_cpu);
    $finish();
end

initial
begin
    $dumpfile("interrupt_controller_tb.vcd");
    $dumpvars(0,interrupt_controller_tb);
end

endmodule
