#include <stdint.h>
#include <conio.h>

#include "sd_card.h"

void sd_init() {
	uint32_t resp;
	sd_card_command(0, 0);

	sd_card_command(0x000001aa, 8);
	sd_card_resp(&resp);
	//cprintf("CMD8: %lx\n", resp);

	sd_card_command(0, 55);
	sd_card_command(0x40180000, 41);
	sd_card_resp(&resp);
	//cprintf("CMD41: %lx\n", resp);

	sd_card_command(0, 55);
	sd_card_command(0x40180000, 41);
	sd_card_resp(&resp);
	//cprintf("CMD41: %lx\n", resp);

	sd_card_command(0, 2);
	sd_card_resp(&resp);
	//cprintf("CMD2: %lx\n", resp);
}

uint16_t sd_get_rca() {
	uint32_t resp;

	sd_card_command(0, 3);
	resp = 0;
	sd_card_resp(&resp);

	//cprintf("CMD3: %lx\n", resp);

	return resp >> 16;
}

uint16_t sd_select_card(uint16_t rca) {
	uint32_t resp;

	sd_card_command((uint32_t)rca << 16, 7);
	sd_card_resp(&resp);

	return (uint16_t) resp;
}

uint16_t sd_get_status(uint16_t rca) {
	uint32_t resp;

	sd_card_command((uint32_t)rca << 16, 13);
	sd_card_resp(&resp);

	return (uint16_t) resp;
}

void sd_readblock(uint32_t addr, void* buf) {
	uint32_t resp;
	int i;

	sd_card_command(addr, 17);
	sd_card_resp(&resp);
	//cprintf("CMD17: %lx\n", resp);

	sd_card_wait_for_data();

	//cprintf("Read data: \n");
	for (i = 0; i < 512; i++){
		((uint8_t*)buf)[i] = sd_card_read_byte();
	}

	//cprintf("\n");
}
