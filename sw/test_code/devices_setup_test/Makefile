CC=../../cc65/bin/cl65
LD=../../cc65/bin/cl65
CFLAGS=-T -t none -I. --cpu "65C02"
LDFLAGS=-C link.ld -m $(NAME).map

NAME=devices_setup_test

DEVICES=../../kernel/devices

BIN=$(NAME).bin
HEX=$(NAME).hex

LISTS=lists

KERNEL_SRCS=rtc.s interrupt_controller.s
KERNEL_OBJS=$(patsubst %.s,%.o,$(filter %s,$(KERNEL_SRCS)))

SRCS=$(wildcard *.s) $(wildcard *.c) 
SRCS+=$(wildcard **/*.s) $(wildcard **/*.c)
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

# Make sure the kernel linked to correct address, no relocation!
all: $(KERNEL_SRCS) $(HEX)
	rm rtc.s
	rm interrupt_controller.s

$(HEX): $(BIN)
	objcopy --input-target=binary --output-target=verilog $(BIN) $(HEX)

$(BIN): $(OBJS) $(KERNEL_OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

%.o: %.s $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

$(LISTS):
	mkdir -p $(addprefix $(LISTS)/,$(sort $(dir $(SRCS))))

rtc.s: $(DEVICES)/rtc.s
	cp $(DEVICES)/rtc.s .

interrupt_controller.s: $(DEVICES)/interrupt_controller.s
	cp $(DEVICES)/interrupt_controller.s .

.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX) $(LISTS) $(NAME).map
	rm -rf $(KERNEL_SRCS)
	rm -rf $(KERNEL_OBJS)

