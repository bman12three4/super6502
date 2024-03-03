all:
	$(MAKE) -C hw

.PHONY: clean
clean:
	$(MAKE) -C hw $@