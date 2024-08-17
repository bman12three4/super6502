ROM_TARGET=test_code/ntw_test

INIT_HEX=hw/super6502_fpga/init_hex.mem
HEX=sw/$(ROM_TARGET)/$(notdir $(ROM_TARGET)).bin

CC65=sw/toolchain/cc65/bin

all: fpga_image

# FPGA
.PHONY: fpga_image
fpga_image: $(INIT_HEX)
	$(MAKE) -C hw/super6502_fpga

sim: $(INIT_HEX)
	$(MAKE) -C hw/super6502_fpga/src/sim

pgm:
	$(MAKE) -C hw/super6502_fpga pgm

waves: sim
	gtkwave hw/super6502_fpga/src/sim/sim_top.vcd

# SW
$(CC65):
	$(MAKE) -C sw/toolchain/cc65 -j $(shell nproc)

$(INIT_HEX): $(CC65) script/generate_rom_image.py $(HEX)
	python script/generate_rom_image.py -i $(HEX) -o $@

# This should get dependencies of rom, not be phony
.PHONY: $(HEX)
$(HEX):
	$(MAKE) -C sw/$(ROM_TARGET) $(notdir $@)

.PHONY: clean
clean:
	$(MAKE) -C hw/super6502_fpga $@
	$(MAKE) -C sw/$(ROM_TARGET) clean
	$(MAKE) -C hw/super6502_fpga/src/sim clean

.PHONY: distclean
distclean: clean
	$(MAKE) -C sw/toolchain/cc65 clean
