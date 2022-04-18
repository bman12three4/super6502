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

uint8_t buf[512];

int main() {
	int i;
	uint16_t rca;
	char* filename;

	clrscr();
	cprintf("Hello, world!\n");

	for (i = 0; i < 16; i++){
		//cprintf("Mapping %1xxxx to %2xxxx\n", i, i);
		mapper_write(i, i);
	}

	cprintf("Enabling Mapper\n");
	mapper_enable(1);

	sd_init();

	rca = sd_get_rca();
	cprintf("rca: %x\n", rca);

	sd_select_card(rca);

	fat_init();

	filename = (char*)malloc(FAT_MAX_FILE_NAME);

	for(;;) {
		cprintf("Filename: ");
		cscanf("%s", filename);
		cprintf("\n");
		fat_parse_path_to_cluster(filename);
	}

	//exec("/test.o65");

	cprintf("Done!\n");

	return 0;
}
