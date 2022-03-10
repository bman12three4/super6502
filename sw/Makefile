CC=cl65
CFLAGS=-t none -I. --cpu "65C02"
LDFLAGS=-C link.ld

NAME=bootrom

BIN=$(NAME).bin
HEX=$(NAME).hex

SRCS=$(wildcard *.s) $(wildcard *.c)
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

all: $(HEX)

$(HEX): $(BIN)
	objcopy --input-target=binary --output-target=ihex $(BIN) $(HEX)
	

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@


.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX)

