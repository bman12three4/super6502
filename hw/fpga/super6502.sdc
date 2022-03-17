#**************************************************************
# Create Clock (where ‘clk’ is the user-defined system clock name)
#**************************************************************
create_clock -name {clk_50} -period 20ns -waveform {0.000 5.000} [get_ports {clk_50}]

create_generated_clock -source [get_pins {sdram|u0|sdram_pll|sd1|pll7|clk[1] }] \
                      -name clk_dram_ext [get_ports {DRAM_CLK}]

derive_pll_clocks

# Constrain the input I/O path
# set_input_delay -clock {clk} -max 3 [all_inputs]
# set_input_delay -clock {clk} -min 2 [all_inputs]
# Constrain the output I/O path
#set_output_delay -clock {clk} 2 [all_outputs]

derive_clock_uncertainty

set_input_delay -max -clock clk_dram_ext 5.9 [get_ports DRAM_DQ*]
set_input_delay -min -clock clk_dram_ext 3.0 [get_ports DRAM_DQ*]


set_multicycle_path -from [get_clocks {clk_dram_ext}] \
                    -to [get_clocks {sdram|u0|sdram_pll|sd1|pll7|clk[0] }] \
                        -setup 2

set_output_delay -max -clock clk_dram_ext 1.6   [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -min -clock clk_dram_ext -0.9   [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -max -clock clk_dram_ext 1.6   [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
set_output_delay -min -clock clk_dram_ext -0.9   [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]