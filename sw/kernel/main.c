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
	uint16_t rca;
	char* filename;

	clrscr();
	cprintf("Hello, world! Modified\n");

	rca = sd_init();
	cprintf("rca: %x\n", rca);

	sd_select_card(rca);

	fat_init();

	exec("/test.o65");

	cprintf("Done!\n");

	return 0;
}
