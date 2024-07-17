FPGA_SRCS_LIST=../../sources.list
SIM_SRCS_LIST=sources.list

SUPER6502_FPGA_SOURCES=$(foreach file, $(shell cat $(FPGA_SRCS_LIST)), ../../$(file))
SIM_SOURCES=$(shell cat $(SIM_SRCS_LIST))

INCLUDE=include/sdram_controller_define.vh

TB_NAME=sim_top

COPY_FILES=addr_map.mem init_hex.mem

FLAGS=-DSIM -DRTL_SIM -DVERILATOR -DSDIO_AXI

all: waves

waves: $(TB_NAME)
	./$(TB_NAME) -fst

$(TB_NAME): $(SUPER6502_FPGA_SOURCES) $(SIM_SOURCES) $(COPY_FILES)
	iverilog -g2005-sv $(FLAGS) -s $@ -o $@ $(INCLUDE) $(SUPER6502_FPGA_SOURCES) $(SIM_SOURCES) -I ../../

$(COPY_FILES): ../../$@
	cp ../../$@ .

.PHONY: clean
clean:
	rm -rf $(COPY_FILES)
	rm -rf $(TB_NAME)
	rm -rf sim_top.vcd
