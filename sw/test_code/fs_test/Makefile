CC=../../cc65/bin/cl65
LD=../../cc65/bin/cl65
SIM=../../cc65/bin/sim65 
CFLAGS=-T -t sim65c02 -I. -I $(REPO_TOP)/sw/kernel
LDFLAGS=-m $(NAME).map

NAME=fs_test

SIMARGS=

BIN=$(NAME).bin

FS=$(REPO_TOP)/sw/script/fs.fat

LISTS=lists

EXT_SRCS=$(REPO_TOP)/sw/kernel/filesystems/fat32.s $(REPO_TOP)/sw/kernel/filesystems/fat32_c.c

SRCS=$(wildcard *.s) $(wildcard *.c)
SRCS+=$(wildcard **/*.s) $(wildcard **/*.c)
SRCS+=$(EXT_SRCS)
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

run: all
	$(SIM) $(SIMARGS) $(BIN)

all: fs.fat $(BIN)

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

%.o: %.s $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

fs.fat: $(FS)
	cp $^ .


$(LISTS):
	mkdir -p $(addprefix $(LISTS)/,$(sort $(dir $(SRCS))))

.PHONY: clean
clean:
	rm -rf $(OBJS) $(BIN) $(HEX) $(LISTS) $(NAME).map

