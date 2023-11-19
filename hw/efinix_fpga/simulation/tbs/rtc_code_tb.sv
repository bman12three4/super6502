`timescale 1ns/1ps

module rtc_code_tb();

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

localparam increment = 3;

logic [7:0] prev;
initial prev = '0;

always @(u_sim_top.w_cpu_addr) begin
    if (
        u_sim_top.w_cpu_addr == 16'h1 &&
        u_sim_top.w_cpu_we == '1
    ) begin
        if (u_sim_top.w_cpu_data_from_cpu <= prev) begin
            $display("Value didn't increment!");
            $display("Bad finish!");
            $finish_and_return(-1);
        end
        prev = u_sim_top.w_cpu_data_from_cpu;
        $display("print1: %x", u_sim_top.w_cpu_data_from_cpu);
    end
end

initial begin
    repeat (5000) @(posedge u_sim_top.r_clk_cpu);
    $display("Timed out");
    $finish_and_return(-1);
end

endmodule