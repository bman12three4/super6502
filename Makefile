ROM_TARGET=test_code/sd_controller_test

INIT_HEX=hw/super6502_fpga/init_hex.mem
HEX=sw/$(ROM_TARGET)/$(notdir $(ROM_TARGET)).bin


all: fpga_image

# FPGA
.PHONY: fpga_image
fpga_image: $(INIT_HEX)
	$(MAKE) -C hw/super6502_fpga

sim: $(INIT_HEX)
	$(MAKE) -C hw/super6502_fpga/src/sim

waves: sim
	gtkwave hw/super6502_fpga/src/sim/sim_top.vcd

# SW
.PHONY: toolchain
toolchain:
	$(MAKE) -C sw/toolchain/cc65 -j $(shell nproc)

$(INIT_HEX): toolchain script/generate_rom_image.py $(HEX)
	python script/generate_rom_image.py -i $(HEX) -o $@

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
