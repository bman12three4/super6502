#include <stdint.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

#include "devices/board_io.h"
#include "devices/uart.h"
#include "devices/mapper.h"
#include "devices/sd_card.h"
#include "filesystem/fat.h"

#define KERNEL_LOAD_ADDR 0xD000

uint8_t buf[512];

int main() {
	int i;
	uint16_t rca;
	char* filename;
	uint32_t cluster;
	uint8_t* kernel_load;

	clrscr();
	cprintf("boot\n");

	for (i = 0; i < 16; i++){
		//cprintf("Mapping %1xxxx to %2xxxx\n", i, i);
		mapper_write(i, i);
	}

	cprintf("Enabling Mapper\n");
	mapper_enable(1);

	mapper_write(0x10, 0xd);
	mapper_write(0x11, 0xe);
	mapper_write(0x12, 0xf);

	sd_init();

	rca = sd_get_rca();
	cprintf("rca: %x\n", rca);

	sd_select_card(rca);

	fat_init();

	filename = (char*)malloc(FAT_MAX_FILE_NAME);

	cluster = fat_parse_path_to_cluster("/kernel.bin");
	for (kernel_load = (uint8_t*)KERNEL_LOAD_ADDR; cluster < FAT_CLUSTERMASK; kernel_load+=(8*512)) {
		cprintf("cluster: %lx\n", cluster);
		cprintf("Writing to %p\n", kernel_load);
		fat_read_cluster(cluster, kernel_load);
		cluster = fat_get_chain_value(cluster);
	}

	cprintf("Done!\n");

	cprintf("Reset vector: %x\n", *((uint16_t*)0xfffc));

	return 0;
}
