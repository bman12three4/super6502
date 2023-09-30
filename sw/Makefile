.PHONY: all install bios kernel clean

all: toolchain bios kernel

install: all
	sh script/format_disk.sh
	sh script/copy_files.sh

toolchain:
	@$(MAKE) -j4 -C cc65

bios:
	@$(MAKE) -C bios

kernel:
	@$(MAKE) -C kernel


clean:
	@$(MAKE) -C bootloader  --no-print-directory $@
	@$(MAKE) -C kernel  --no-print-directory $@
	@$(MAKE) -C cc65  --no-print-directory $@