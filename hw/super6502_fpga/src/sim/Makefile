FPGA_SRCS_LIST=../../sources.list
SIM_SRCS_LIST=sources.list
BAD_SOURCES_LIST=stubs.list

SUPER6502_FPGA_SOURCES=$(shell rtl-manifest $(FPGA_SRCS_LIST))
BAD_SOURCES=$(shell rtl-manifest $(BAD_SOURCES_LIST))
GOOD_FPGA_SOURCES=$(filter-out $(BAD_SOURCES), $(SUPER6502_FPGA_SOURCES))
SIM_SOURCES=$(shell cat $(SIM_SRCS_LIST))

INCLUDE=include/sdram_controller_define.vh

TB_NAME=./obj_dir/Vsim_top

COPY_FILES=addr_map.mem init_hex.mem
SD_IMAGE=sd_image.bin

FLAGS=-DSIM -DRTL_SIM -DVERILATOR -DSDIO_AXI

# IVERILOG=$(REPO_TOP)/../iverilog/local/bin/iverilog -v
IVERILOG=iverilog

all: waves

waves: $(TB_NAME)
#	./$(TB_NAME) -fst
	./obj_dir/Vsim_top

$(TB_NAME): $(SUPER6502_FPGA_SOURCES) $(SIM_SOURCES) $(COPY_FILES) $(SD_IMAGE)
# $(IVERILOG) -g2005-sv $(FLAGS) -s $@ -o $@ $(INCLUDE) $(SUPER6502_FPGA_SOURCES) $(SIM_SOURCES) -I ../../
	verilator --binary $(FLAGS) $(INCLUDE) $(GOOD_FPGA_SOURCES) $(SIM_SOURCES) +incdir+../../ -Wno-BLKANDNBLK -Wno-fatal -j 16 --top sim_top --trace-fst -Wno-ASSIGNDLY


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
	rm -rf obj_dir
