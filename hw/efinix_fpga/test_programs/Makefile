TARGETS=stacktest runram

all: $(TARGETS)

$(TARGETS):
	cl65 --cpu 65c02 -C link.ld -l $@.list $@.s
	xxd -ps $@ | fold -w 2 > $@.hex

clean:
	rm $(TARGETS)
	rm *.hex
	rm *.list
