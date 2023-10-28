.PHONY: all install bios kernel clean distclean

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

distclean: clean
	@$(MAKE) -C cc65  --no-print-directory $@

clean:
	@$(MAKE) -C bios  --no-print-directory $@
	@$(MAKE) -C kernel  --no-print-directory $@
