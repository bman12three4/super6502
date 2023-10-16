CC=../cc65/bin/cl65
CFLAGS=-T -t none -I. --cpu "65C02" -DRTL_SIM
LDFLAGS=-C link.ld -m $(NAME).map

NAME=bios

BIN=$(NAME).bin
HEX=$(NAME).hex

FPGA_IMG=$(REPO_TOP)/hw/efinix_fpga/init_hex.mem
EFX_RUN=/home/byron/Software/efinity/2023.1/scripts/efx_run.py
EFX_PRJ=/home/byron/Projects/super6502/hw/efinix_fpga/super6502.xml

LISTS=lists
TESTS=tests

SRCS=$(wildcard *.s) $(wildcard *.c)
SRCS+=$(filter-out $(wildcard tests/*), $(wildcard **/*.s)) $(filter-out $(wildcard tests/*), $(wildcard **/*.c))
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

all: $(HEX)

$(HEX): $(BIN)
	objcopy --input-target=binary --output-target=verilog $(BIN) $(HEX)
	cp boot2.bin ../fsdir
	cmp $(HEX) $(FPGA_IMG); \
	RETVAL=$$?; \
    if [ $$RETVAL -eq 0 ]; then \
            echo "SAME"; \
    else \
            echo "NOT SAME"; \
			cp bios.hex ../../hw/efinix_fpga/init_hex.mem; \
			echo "Update ROM or rebuild FPGA image!"; \
    fi

	

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

%.o: %.s $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

$(LISTS):
	mkdir -p $(addprefix $(LISTS)/,$(sort $(dir $(SRCS))))

.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX) $(LISTS) $(NAME).map

