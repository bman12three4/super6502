#include <stdint.h>
#include <conio.h>
#include <string.h>

#include "filesystem/fat.h"
#include "filesystem/o65.h"

void exec(char* filename) {
	o65_header_t* header;
	o65_opt_t* o65_opt;
	uint8_t* seg_ptr;

	uint8_t* code_base;
	uint8_t* data_base;
	uint16_t code_len;
	uint16_t data_len;

	uint8_t (*exec)(void);
	uint8_t ret;

    fat_read(filename, fat_buf);

	header = (o65_header_t*)fat_buf;

	if (header->c64_marker == O65_NON_C64 &&
			header->magic[0] == O65_MAGIC_0 && 
			header->magic[1] == O65_MAGIC_1 && 
			header->magic[2] == O65_MAGIC_2) {

		code_base = (uint8_t*)header->tbase;
		data_base = (uint8_t*)header->dbase;
		code_len = header->tlen;
		data_len = header->dlen;


		o65_opt = (o65_opt_t*)(fat_buf + sizeof(o65_header_t));
		while (o65_opt->olen)
		{
			o65_print_option(o65_opt);
			o65_opt = (o65_opt_t*)((uint8_t*)o65_opt + o65_opt->olen);
		}

		seg_ptr = (uint8_t*)o65_opt + 1;

		memcpy((uint8_t*)code_base, seg_ptr, code_len);

		seg_ptr+=code_len;

		memcpy((uint8_t*)data_base, seg_ptr, data_len);

		exec = (uint8_t (*)(void))code_base;

		ret = 0;

		ret = (*exec)();

		cprintf("ret: %x\n", ret);


	}
}
