CC=cl65
CFLAGS=-t none -I. --cpu "65C02"
LDFLAGS=-C link.ld -m $(NAME).map

NAME=bootrom

BIN=$(NAME).bin
HEX=$(NAME).hex

LISTS=lists

SRCS=$(wildcard *.s) $(wildcard *.c)
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
	mkdir $(LISTS)

.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX) $(LISTS)

