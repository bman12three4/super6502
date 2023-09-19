PROJECT=super6502
BITSTREAM=outflow/$(PROJECT).bit

SRCS=$(shell find src/ -type f -name "*.sv")

all: $(BITSTREAM)

$(BITSTREAM): $(PROJECT).peri.xml $(SRCS)
	efx_run.py $(PROJECT).xml

install: $(BITSTREAM)
	efx_run.py $(PROJECT).xml --flow program --pgm_opts mode=jtag

install_spi: $(BITSTREAM)
	efx_run.py $(PROJECT).xml --flow program --pgm_opts

clean:
	rm -rf work_pnr
	rm -rf work_syn
	rm -rf work_pt
	rm -rf outflow
