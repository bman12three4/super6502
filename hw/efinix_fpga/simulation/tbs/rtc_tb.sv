`timescale 1ns/1ps

module rtc_tb();

logic r_clk_cpu;

initial begin
    r_clk_cpu <= '1;
    forever begin
        #125 r_clk_cpu <= ~r_clk_cpu;
    end
end

logic reset, rwb, cs, addr, irq;
logic [7:0] i_data, o_data;

rtc u_rtc(
    .clk(r_clk_cpu),
    .reset(reset),
    .rwb(rwb),
    .cs(cs),
    .addr(addr),
    .i_data(i_data),
    .o_data(o_data),
    .irq(irq)
);

initial begin
    do_reset();
    set_increment(1);
    set_threshold(7);
    set_irq_threshold(2);
    enable_rtc(3);
    repeat (20) @(posedge r_clk_cpu);
    $finish();
end

initial begin
    $dumpfile("rtc_tb.vcd");
    $dumpvars(0,rtc_tb);
end

task do_reset();
    repeat (5) @(posedge r_clk_cpu);
    reset = 1;
    cs = 0;
    rwb = 1;
    addr = '0;
    i_data = '0;
    repeat (5) @(posedge r_clk_cpu);
    reset = 0;
    repeat (5) @(posedge r_clk_cpu);
endtask

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
    @(posedge r_clk_cpu);
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
    @(posedge r_clk_cpu);
endtask

task set_increment(input logic [31:0] _increment);
    for (int i = 0; i < 4; i++) begin
        write_reg(0, 8'h10 | i);
        write_reg(1, _increment[8*i +: 8]);
    end
endtask

task set_threshold(input logic [31:0] _threshold);
    for (int i = 0; i < 4; i++) begin
        write_reg(0, 8'h00 | i);
        write_reg(1, _threshold[8*i +: 8]);
    end
endtask

task set_irq_threshold(input logic [31:0] _increment);
    for (int i = 0; i < 4; i++) begin
        write_reg(0, 8'h20 | i);
        write_reg(1, _increment[8*i +: 8]);
    end
endtask

task enable_rtc(input logic [7:0] _ctrl);
    write_reg(0, 8'h30);
    write_reg(1, _ctrl);
endtask

task read_output(output logic [31:0] _output);
    for (int i = 0; i < 4; i++) begin
        write_reg(0, 8'h30 | i);
        read_reg(1, _output[8*i +: 8]);
    end
endtask

endmodule
