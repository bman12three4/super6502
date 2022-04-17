#include <stdint.h>
#include <conio.h>
#include <string.h>

#include "board_io.h"
#include "uart.h"
#include "mapper.h"
#include "sd_card.h"
#include "filesystem/fat.h"
#include "exec.h"

uint8_t buf[512];

int main() {
	int i;
	uint16_t rca;

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
	exec("/test.o65");

	cprintf("Done!\n");

	return 0;
}
