create_clock -period 5.00 i_sdrclk
create_clock -period 5.00 i_tACclk
create_clock -period 10.00 i_sysclk

create_generated_clock -source i_sysclk -divide_by 50 clk_cpu
