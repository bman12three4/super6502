.PHONY: all install bios bootloader kernel clean

all: bios bootloader kernel

install: all
	sh script/format_disk.sh
	sh script/copy_files.sh

bios:
	@$(MAKE) -C bios

bootloader:
	@$(MAKE) -C bootloader

kernel:
	@$(MAKE) -C kernel


clean:
	@$(MAKE) -C bios  --no-print-directory $@
	@$(MAKE) -C bootloader  --no-print-directory $@
	@$(MAKE) -C kernel  --no-print-directory $@