TARGETS=stacktest runram timer timer_irq multiplier divider
SRC=$(wildcard *.s)
DIR=../ip/bram

all: $(TARGETS)

$(TARGETS): $(SRC)
	cl65 --cpu 65c02 -C link.ld -l $@.list $@.s
	xxd -ps $@ | fold -w 2 > $@.hex

install:
	cp $(TARGET).hex $(DIR)/init_hex.mem
	cd $(DIR);python3 efx_mem_init_script.py hex init_hex.mem


clean:
	rm -f $(TARGETS)
	rm *.hex
	rm *.list
