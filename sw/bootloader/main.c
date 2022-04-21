#include <stdint.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

#include "devices/board_io.h"
#include "devices/uart.h"
#include "devices/mapper.h"
#include "devices/sd_card.h"
#include "filesystem/fat.h"
#include "exec.h"

#define KERNEL_LOAD_ADDR 0xD000

uint8_t buf[512];

int main() {
	int i;
	uint16_t rca;

	clrscr();
	cprintf("boot\n");

	for (i = 0; i < 16; i++){
		//cprintf("Mapping %1xxxx to %2xxxx\n", i, i);
		mapper_write(i, i);
	}

	cprintf("Enabling Mapper\n");
	mapper_enable(1);

	mapper_write(0x10, 0xd);		//how to make these not hard coded?
	mapper_write(0x11, 0xe);
	mapper_write(0x12, 0xf);

	sd_init();

	rca = sd_get_rca();
	cprintf("rca: %x\n", rca);

	sd_select_card(rca);

	fat_init();

	exec("/kernel.o65");

	cprintf("Done!\n");

	cprintf("Reset vector: %x\n", *((uint16_t*)0xfffc));

	return 0;
}
