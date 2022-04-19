.PHONY: all install bootloader kernel clean

all: bootloader kernel

install: all
	sh script/format_disk.sh
	sh script/copy_files.sh

bootloader:
	@$(MAKE) -C bootloader

kernel:
	@$(MAKE) -C kernel


clean:
	@$(MAKE) -C bootloader  --no-print-directory $@
	@$(MAKE) -C kernel  --no-print-directory $@