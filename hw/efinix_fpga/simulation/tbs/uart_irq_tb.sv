`timescale 1ns/1ps

module uart_irq_tb();

sim_top u_sim_top();

initial begin
    u_sim_top.u_sim_uart.tx_en = 1;
    @(posedge u_sim_top.r_clk_cpu);
    u_sim_top.u_sim_uart.tx_data = 8'hAA;
    repeat (100) @(posedge u_sim_top.r_clk_cpu);
    $finish();
end

endmodule