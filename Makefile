ROM_TARGET=test_code/loop_test

INIT_HEX=hw/super6502_fpga/init_hex.mem
HEX=sw/$(ROM_TARGET)/$(notdir $(ROM_TARGET)).bin


all: fpga_image

# FPGA
.PHONY: fpga_image
fpga_image: $(INIT_HEX)
	$(MAKE) -C hw/super6502_fpga


# SW
.PHONY: toolchain
toolchain:
	$(MAKE) -C sw/toolchain/cc65 -j $(shell nproc)

$(INIT_HEX): toolchain script/generate_rom_image.py $(HEX)
	python script/generate_rom_image.py -i $(HEX) -o $@

$(HEX):
	$(MAKE) -C sw/$(ROM) $(notdir $@)

.PHONY: clean
clean:
	$(MAKE) -C hw/super6502_fpga $@

.PHONY: distclean
distclean: clean
	$(MAKE) -C sw/toolchain/cc65 clean