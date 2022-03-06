CC=cl65
CFLAGS=-t none
LDFLAGS=-C link.ld

NAME=bootrom

BIN=$(NAME).bin
HEX=$(NAME).hex

SRCS=$(wildcard *.S) $(wildcard *.c)
OBJS+=$(patsubst %.S,%.o,$(filter %S,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

all: $(BIN)
	objcopy --input-target=binary --output-target=ihex $(BIN) $(HEX)
	

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX)

