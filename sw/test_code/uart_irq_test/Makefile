CC=../../cc65/bin/cl65
LD=../../cc65/bin/cl65
CFLAGS=-T -t none -I. --cpu "65C02"
LDFLAGS=-C link.ld -m $(NAME).map

NAME=uart_irq_test

DEVICES=$(REPO_TOP)/sw/kernel/devices

BIN=$(NAME).bin
HEX=$(NAME).hex

LISTS=lists

SRCS=$(wildcard *.s) $(wildcard *.c)
SRCS+=$(DEVICES)/interrupt_controller.s
SRCS+=$(wildcard **/*.s) $(wildcard **/*.c)
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

# Make sure the kernel linked to correct address, no relocation!
all: $(HEX)

$(HEX): $(BIN)
	objcopy --input-target=binary --output-target=verilog $(BIN) $(HEX)

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

