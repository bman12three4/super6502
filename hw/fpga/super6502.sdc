#**************************************************************
# Create Clock (where ‘clk’ is the user-defined system clock name)
#**************************************************************
create_clock -name {clk} -period 20ns -waveform {0.000 5.000} [get_ports {clk}]
# Constrain the input I/O path
set_input_delay -clock {clk} -max 3 [all_inputs]
set_input_delay -clock {clk} -min 2 [all_inputs]
# Constrain the output I/O path
set_output_delay -clock {clk} 2 [all_outputs]

derive_clock_uncertainty
