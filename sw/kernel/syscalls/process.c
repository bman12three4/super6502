#include <stdint.h>
#include <conio.h>
#include <string.h>

#include "filesystem/fat.h"
#include "filesystem/o65.h"
#include "syscalls/process.h"

void exec(char* filename) {
	o65_header_t* header;
	o65_opt_t* o65_opt;
	uint8_t* seg_ptr;
	uint16_t cluster;
	uint16_t offs;
	uint8_t reloc_data;
	uint16_t num_undef_ref;

	int i;


	uint8_t* code_base;
	uint8_t* data_base;
	uint16_t code_len;
	uint16_t data_len;

	uint8_t (*exec)(void);
	uint8_t ret;


	cluster = fat_parse_path_to_cluster(filename);
	fat_read_sector(cluster, 0, fat_buf);

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

		offs = (uint16_t)seg_ptr-(uint16_t)fat_buf;

		fat_read_bytes(code_base, cluster, offs, code_len);

		offs += code_len;
		fat_read_bytes(data_base, cluster, offs, data_len);

		offs += data_len;
		fat_read_bytes((uint8_t*)&num_undef_ref, cluster, offs, 2);

		if (num_undef_ref) {
			cprintf("Error!\n");
			for(;;);
		}


		cprintf("\n\n");
		// so we assume that there are no undefined references and keep moving on
		offs += 2;

		//text and data reloc
		for (i = 0; i < 2; i++){
			while(1) {
				//cprintf(".");
				// now we need to zoom past the relocation table.
				// The first byte(s) is the offset
				fat_read_bytes(&reloc_data, cluster, offs++, 1);
				if (reloc_data == 0xff) {
					continue;
				} else if (reloc_data == 0) {
					cprintf("Found the end!\n");
					break;
				} else {
					//cprintf("Reloc offs: %x\n", reloc_data);
				}
				fat_read_bytes(&reloc_data, cluster, offs++, 1);
				//cprintf("Type + Segment: %x\n", reloc_data);

				//cprintf("Type: %x\n", reloc_data >> 4);
				switch (reloc_data >> 4) {
					case O65_RELOC_TYPE_HIGH:
						offs++;
					case O65_RELOC_TYPE_LOW:
					case O65_RELOC_TYPE_WORD:
						break;
					default:
						cprintf("Unhandled type\n");
						for (;;);
				}
			}
		}

		fat_read_bytes((uint8_t*)&num_undef_ref, cluster, offs, 2);
		//cprintf("Number of exported globals: %d\n", num_undef_ref);

		offs += 2;
		i = 1;
		while ((int8_t)i) {
			fat_read_bytes((uint8_t*)&i, cluster, offs++, 1);
			cprintf("%c", (uint8_t)i);
		}

		fat_read_bytes((uint8_t*)&i, cluster, offs++, 1);
		cprintf("\nSegment: %x\n", (uint8_t)i);

		fat_read_bytes((uint8_t*)&exec, cluster, offs, 2);
		cprintf("Address: %p\n", exec);

		ret = 0;

		ret = (*exec)();

		cprintf("ret: %x\n", ret);


	}
}
