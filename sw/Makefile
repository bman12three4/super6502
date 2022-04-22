.PHONY: all install bootloader kernel clean test_exec

all: toolchain bootloader kernel test_exec

install: all
	sh script/format_disk.sh
	sh script/copy_files.sh

toolchain:
	@$(MAKE) -j4 -C cc65

bootloader:
	@$(MAKE) -C bootloader

kernel:
	@$(MAKE) -C kernel

test_exec:
	@$(MAKE) -C test_exec


clean:
	@$(MAKE) -C bootloader  --no-print-directory $@
	@$(MAKE) -C kernel  --no-print-directory $@
	@$(MAKE) -C cc65  --no-print-directory $@