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
    .int_out(int_out)
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

/* Test Level triggered IRQ by triggering IRQ0
 * and then clearing it, 
 */
 // TODO this needs to test that it does not trigger after we clear the irq.
task test_edge_irq();
    $display("Testing Edge IRQ");
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
    write_reg(0, 8'h10);    // Enable register
    write_reg(1, 8'hff);    // 0-7 all enabled
    write_reg(0, 8'h20);    // Type register
    write_reg(1, 8'h00);    // 0-7 all level triggered?
    repeat (5) @(posedge r_clk_cpu);
    int_in = 1;
    @(posedge r_clk_cpu)
    assert (int_out == 1) else begin
        errors = errors + 1;
        $error("Interrupt should be high!");
    end
    repeat (5) @(posedge r_clk_cpu);
    write_reg(0, 8'hff);
    write_reg(1, 8'h01);
    @(posedge r_clk_cpu);
    assert (int_out == 0) else begin
        errors = errors + 1;
        $error("Interrupt should be low!");
    end
    int_in = 0;
    repeat (5) @(posedge r_clk_cpu);
    write_reg(0, 8'hff);
    write_reg(1, 8'h01);
    assert (int_out == 0) else begin
        errors = errors + 1;
        $error("Interrupt should be low!");
    end
endtask

task test_level_irq();
    $display("Testing level IRQ");
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
    write_reg(0, 8'h10);    // Enable register
    write_reg(1, 8'hff);    // 0-7 all enabled
    write_reg(0, 8'h20);    // Type register
    write_reg(1, 8'hff);    // 0-7 all level triggered?
    repeat (5) @(posedge r_clk_cpu);
    int_in = 1;
    @(posedge r_clk_cpu)
    assert (int_out == 1) else begin
        errors = errors + 1;
        $error("Interrupt should be high!");
    end
    repeat (5) @(posedge r_clk_cpu);
    write_reg(0, 8'hff);
    write_reg(1, 8'h01);
    @(posedge r_clk_cpu);
    assert (int_out == 1) else begin
        errors = errors + 1;
        $error("Interrupt should be high!");
    end
    int_in = 0;
    repeat (5) @(posedge r_clk_cpu);
    write_reg(0, 8'hff);
    write_reg(1, 8'h01);
    @(posedge r_clk_cpu);
    repeat (5) @(posedge r_clk_cpu)
    assert (int_out == 0) else begin
        errors = errors + 1;
        $error("Interrupt should be low!");
    end
endtask

int errors;

initial begin
    errors = 0;
    test_edge_irq();
    test_level_irq();
    if (errors > 0)
        $finish_and_return(-1);
    else
        $finish();
end

initial
begin
    $dumpfile("interrupt_controller_tb.vcd");
    $dumpvars(0,interrupt_controller_tb);
end

endmodule
