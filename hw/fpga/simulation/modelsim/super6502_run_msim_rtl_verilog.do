transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/ram.v}
vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/rom.v}
vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/cpu_clk.v}
vlog -vlog01compat -work work +incdir+/home/byron/Projects/super6502/hw/fpga/db {/home/byron/Projects/super6502/hw/fpga/db/cpu_clk_altpll.v}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/uart.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/addr_decode.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/super6502.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/HexDriver.sv}
vlog -sv -work work +incdir+/home/byron/Projects/super6502/hw/fpga {/home/byron/Projects/super6502/hw/fpga/SevenSeg.sv}

