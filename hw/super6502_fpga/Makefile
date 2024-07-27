SUPER6502_FPGA_SOURCES=$(shell cat sources.list)

SUPER6502_FPGA_BITSTREAM=outflow/super6502_fpga.hex

SUPER6502_FPGA_PROJECT=super6502_fpga.xml

all: $(SUPER6502_FPGA_BITSTREAM)

$(SUPER6502_FPGA_BITSTREAM): $(SUPER6502_FPGA_SOURCES) $(SUPER6502_FPGA_PROJECT)
	efx_run.py $(SUPER6502_FPGA_PROJECT)

pgm:
	efx_run.py $(SUPER6502_FPGA_PROJECT) --flow program --pgm_opts mode=jtag

.PHONY: clean
clean:
	rm -rf work_*
	rm -rf outflow
	rm -rf init_hex.mem
