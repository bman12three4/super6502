create_clock -period 5.00 i_sdrclk
create_clock -period 5.00 i_tACclk
create_clock -period 10.00 i_sysclk

create_clock -period 40.00 mii_rx_clk
create_clock -period 40.00 mii_tx_clk

set_clock_groups -exclusive -group {i_sysclk i_sdrclk i_tACclk} -group {mii_tx_clk} -group {mii_rx_clk}

create_generated_clock -source i_sysclk -divide_by 50 clk_cpu
