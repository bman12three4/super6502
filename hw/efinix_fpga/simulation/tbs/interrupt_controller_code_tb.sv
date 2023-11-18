`timescale 1ns/1ps

module interrupt_controller_code_tb();

sim_top u_sim_top();

always begin
    if (
        u_sim_top.w_cpu_addr == 16'h0 &&
        u_sim_top.w_cpu_we == '1
    ) begin
        if (u_sim_top.w_cpu_data_from_cpu == 8'h6d) begin
            $display("Good finish!");
            $finish();
        end else begin
            $display("Bad finish!");
            $finish_and_return(-1);
        end
    end
    # 1;
end

initial begin
    u_sim_top.u_dut.int_in = 0;
    repeat (2400) @(posedge u_sim_top.r_clk_cpu);
    for (int i = 0; i < 256; i++) begin
        repeat (100) @(posedge u_sim_top.r_clk_cpu);
        u_sim_top.u_dut.int_in = 1 << i;
        $display("Activiating interrupt %d", i);
    end
end

initial begin
    repeat (40000) @(posedge u_sim_top.r_clk_cpu);
    $display("Timed out");
    $finish_and_return(-1);
end

endmodule