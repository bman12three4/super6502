CC=../cc65/bin/cl65
CFLAGS=-T -t none -I. --cpu "65C02"
LDFLAGS=-C link.ld -m $(NAME).map

NAME=bios

BIN=$(NAME).bin
HEX=$(NAME).hex

LISTS=lists
TESTS=tests

SRCS=$(wildcard *.s) $(wildcard *.c)
SRCS+=$(filter-out $(wildcard tests/*), $(wildcard **/*.s)) $(filter-out $(wildcard tests/*) $(wildcard filesystem/*), $(wildcard **/*.c))
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

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

