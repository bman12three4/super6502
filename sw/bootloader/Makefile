CC=cl65
CFLAGS=-T -t none -I. --cpu "65C02"
test: CFLAGS=-T -t sim65c02 -I.
LDFLAGS=-C link.ld -m $(NAME).map
SIM=sim65
SIMARGS=-v -c -x 1000000

NAME=bootloader

BIN=$(NAME).bin
HEX=$(NAME).hex

LISTS=lists

SRCS=$(wildcard *.s) $(wildcard *.c)
SRCS+=$(filter-out $(wildcard tests/*), $(wildcard **/*.s)) $(filter-out $(wildcard tests/*), $(wildcard **/*.c))
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

all: $(HEX)

$(HEX): $(BIN)
	objcopy --input-target=binary --output-target=ihex $(BIN) $(HEX)
	

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

