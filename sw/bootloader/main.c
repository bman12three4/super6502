#include <stdint.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

#include "devices/board_io.h"
#include "devices/uart.h"
#include "devices/sd_card.h"
#include "filesystem/fat.h"

#define KERNEL_LOAD_ADDR 0xD000

uint8_t buf[512];

int main() {
	uint16_t rca;
	clrscr();
	cputs("Starting sd_init\n");
	cprintf("And testing cprintf\n");

	sd_init();

	cprintf("finish sd_init\n");

	rca = sd_get_rca();
	cprintf("rca: %x\n", rca);

	sd_select_card(rca);

	/*
	fat_init();

	filename = (char*)malloc(FAT_MAX_FILE_NAME);

	cluster = fat_parse_path_to_cluster("/kernel.bin");
	for (kernel_load = (uint8_t*)KERNEL_LOAD_ADDR; cluster < FAT_CLUSTERMASK; kernel_load+=(8*512)) {
		cprintf("cluster: %lx\n", cluster);
		cprintf("Writing to %p\n", kernel_load);
		fat_read_cluster(cluster, kernel_load);
		cluster = fat_get_chain_value(cluster);
	}

	*/

	cprintf("Done!\n");

	for(;;);

	cprintf("Reset vector: %x\n", *((uint16_t*)0xfffc));

	return 0;
}
