transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work  {../../hvl/irq_testbench.sv}
vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/ram.v}
vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/rom.v}
vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/cpu_clk.v}
vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga/db {/home/byron/Projects/super6502/hw/fpga/db/cpu_clk_altpll.v}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/uart.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/addr_decode.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/super6502.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/HexDriver.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/SevenSeg.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixv_ver -L stratixv_hssi_ver -L stratixv_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave -group {dut} -radix hexadecimal sim:/testbench/dut/*

onfinish stop
run -all
