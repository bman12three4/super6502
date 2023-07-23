CC=../cc65/bin/cl65
CFLAGS=-T -t none -I. --cpu "65C02"
test: CFLAGS=-T -t sim65c02 -I.
LDFLAGS=-C link.ld -m $(NAME).map
SIM=sim65
SIMARGS=-v -c -x 1000000

NAME=bootloader

TEST_BIN=test.bin
BIN=$(NAME).bin
HEX=$(NAME).hex

LISTS=lists
TESTS=tests

SRCS=$(wildcard *.s) $(wildcard *.c)
SRCS+=$(filter-out $(wildcard tests/*), $(wildcard **/*.s)) $(filter-out $(wildcard tests/*) $(wildcard filesystem/*) devices/sd_print.c, $(wildcard **/*.c))
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

TEST_SRCS=$(wildcard $(TESTS)/*.s) $(wildcard $(TESTS)/*.c)
TEST_OBJS+=$(patsubst %.s,%.o,$(filter %s,$(TEST_SRCS)))
TEST_OBJS+=$(patsubst %.c,%.o,$(filter %c,$(TEST_SRCS)))
TEST_OBJS+=$(filter-out boot.o,$(filter-out main.o,$(filter-out vectors.o,$(OBJS))))

all: $(HEX)

test: $(TEST_BIN)
	$(SIM) $(SIMARGS) $(TEST_BIN)

$(TEST_BIN): $(OBJS) $(TEST_OBJS)
	$(CC) $(CFLAGS) $(TEST_OBJS) -o $@	

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
	mkdir $(LISTS)/$(sort $(dir $(TEST_SRCS)))

.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX) $(LISTS) $(NAME).map
	rm -rf $(TEST_OBJS) $(TEST_BIN)

