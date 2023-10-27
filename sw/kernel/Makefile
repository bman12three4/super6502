CC=../cc65/bin/cl65
LD=../cc65/bin/cl65
CFLAGS=-T -t none -I. --cpu "65C02"
LDFLAGS=-C link.ld -m $(NAME).map

NAME=kernel

O65 = $(NAME).o65

FSDIR=$(REPO_TOP)/sw/fsdir

LISTS=lists

SRCS=$(wildcard *.s) $(wildcard *.c)
SRCS+=$(wildcard **/*.s) $(wildcard **/*.c)
OBJS+=$(patsubst %.s,%.o,$(filter %s,$(SRCS)))
OBJS+=$(patsubst %.c,%.o,$(filter %c,$(SRCS)))

# Make sure the kernel linked to correct address, no relocation!
all: $(O65) $(FSDIR)
	cp $(O65) $(FSDIR)

$(FSDIR):
	mkdir $(FSDIR)

$(O65): $(OBJS)
	$(LD) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

%.o: %.s $(LISTS)
	$(CC) $(CFLAGS) -l $(LISTS)/$<.list -c $< -o $@

$(LISTS):
	mkdir -p $(addprefix $(LISTS)/,$(sort $(dir $(SRCS))))

.PHONY: clean
clean:
	rm -rf $(OBJS) $(O65) $(LISTS) $(NAME).map