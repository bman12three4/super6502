#include <stdint.h>
#include <conio.h>

#include "board_io.h"
#include "uart.h"
#include "mapper.h"
#include "sd_card.h"

uint8_t buf[512];

void sd_readblock(uint8_t addr) {
	uint32_t resp;
	int i;

	sd_card_command(addr, 17);
	sd_card_resp(&resp);
	cprintf("CMD17: %lx\n", resp);

	sd_card_wait_for_data();

	cprintf("Read data: \n");
	for (i = 0; i < 512; i++){
		buf[i] = sd_card_read_byte();
	}

	for (i = 0; i < 512; i++){
		cprintf("%c", buf[i]);
	}
}

int main() {
	int i;
	uint8_t sw;
	uint32_t resp;
	char s[16];
	s[15] = 0;

	clrscr();
	cprintf("Hello, world!\n");

	for (i = 0; i < 16; i++){
		cprintf("Mapping %1xxxx to %2xxxx\n", i, i);
		mapper_write(i, i);
	}

	cprintf("Enabling Mapper\n");
	mapper_enable(1);

	cprintf("Writing 0xcccc to 0x4000\n");
	*(unsigned int*)(0x4000) = 0xcccc;

	cprintf("Writing 0xdddd to 0x5000\n");
	*(unsigned int*)(0x5000) = 0xdddd;

	cprintf("Mapping %1xxxx to %2xxxx\n", 4, 16);
	mapper_write(16, 4);

	cprintf("Mapping %1xxxx to %2xxxx\n", 5, 16);
	mapper_write(16, 5);

	cprintf("Writing 0xa5a5 to 0x4000\n");
	*(unsigned int*)(0x4000) = 0xa5a5;

	cprintf("Reading from 0x5000: %x\n", *(unsigned int*)(0x5000));

	cprintf("Resetting map\n");
	mapper_write(4, 4);
	mapper_write(5, 5);

	cprintf("Reading from 0x4000: %x\n", *(unsigned int*)(0x4000));
	cprintf("Reading from 0x5000: %x\n", *(unsigned int*)(0x5000));

	// This will read a 512 block from the sd card.
	// The RCA is hard coded for the one that I have on hand as responses
	// are not implemented yet.
	sd_card_command(0, 0);

	sd_card_command(0x000001aa, 8);
	sd_card_resp(&resp);
	cprintf("CMD8: %lx\n", resp);

	sd_card_command(0, 55);
	sd_card_command(0x40180000, 41);
	sd_card_resp(&resp);
	cprintf("CMD41: %lx\n", resp);

	sd_card_command(0, 55);
	sd_card_command(0x40180000, 41);
	sd_card_resp(&resp);
	cprintf("CMD41: %lx\n", resp);

	sd_card_command(0, 2);
	sd_card_resp(&resp);
	cprintf("CMD2: %lx\n", resp);

	sd_card_command(0, 3);
	sd_card_resp(&resp);
	cprintf("CMD3: %lx\n", resp);

	sd_card_command(0x59b40000, 7);
	sd_card_resp(&resp);
	cprintf("CMD7: %lx\n", resp);

	sd_card_command(0x59b41000, 13);
	sd_card_resp(&resp);
	cprintf("CMD13: %lx\n", resp);

	sd_readblock(0);
	sd_readblock(1);
	sd_readblock(2);
	sd_readblock(3);


	while (1) {

		sw = sw_read();
		led_set(sw);

		cscanf("%15s", s);
		cprintf("\n");
		for (i = 0; i < 16; i++)
			cprintf("s[%d]=%c ", i, s[i]);
		cprintf("\n");
		cprintf("Read string: %s\n", s);
	}

	return 0;
}
