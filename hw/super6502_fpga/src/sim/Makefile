FPGA_SRCS_LIST=../../sources.list
SIM_SRCS_LIST=sources.list

SUPER6502_FPGA_SOURCES=$(foreach file, $(shell cat $(FPGA_SRCS_LIST)), ../../$(file))
SIM_SOURCES=$(shell cat $(SIM_SRCS_LIST))

INCLUDE=include/sdram_controller_define.vh

TB_NAME=sim_top

COPY_FILES=addr_map.mem init_hex.mem
SD_IMAGE=sd_image.bin

FLAGS=-DSIM -DRTL_SIM -DVERILATOR -DSDIO_AXI

all: waves

waves: $(TB_NAME)
	./$(TB_NAME) -fst

$(TB_NAME): $(SUPER6502_FPGA_SOURCES) $(SIM_SOURCES) $(COPY_FILES) $(SD_IMAGE)
	iverilog -g2005-sv $(FLAGS) -s $@ -o $@ $(INCLUDE) $(SUPER6502_FPGA_SOURCES) $(SIM_SOURCES) -I ../../

$(SD_IMAGE):
	dd if=/dev/urandom bs=1 count=65536 of=$(SD_IMAGE)

# I feel like this should also realize that the outside files are newer...
.PHONY: $(COPY_FILES)
$(COPY_FILES): ../../$@
	cp ../../$@ .

.PHONY: clean
clean:
	rm -rf $(COPY_FILES)
	rm -rf $(TB_NAME)
	rm -rf sim_top.vcd
