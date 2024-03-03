all: hw

.PHONY: hw
hw:
	$(MAKE) -C hw

.PHONY: clean
clean:
	$(MAKE) -C hw $@