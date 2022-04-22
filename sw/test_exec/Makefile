CC=../cc65/bin/cl65
CFLAGS=-T -t super6502 -I. --cpu "65C02"
test: CFLAGS=-T -t sim65c02 -I.
LDFLAGS=-C link.ld -m $(NAME).map
SIM=sim65
SIMARGS=-v -c -x 1000000

NAME=test

BIN=$(NAME).o65
HEX=$(NAME).hex

LISTS=lists

SRCS=$(wildcard *.s) $(wildcard *.c)
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

all: $(BIN)

$(HEX): $(BIN)
	objcopy --input-target=binary --output-target=ihex $(BIN) $(HEX)
	

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@
	cp $(BIN) ../fsdir

%.o: %.c $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

%.o: %.s $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

$(LISTS):
	mkdir -p $(addprefix $(LISTS)/,$(sort $(dir $(SRCS))))

.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX) $(LISTS) $(NAME).map
	rm -rf $(TEST_OBJS) $(TEST_BIN)

