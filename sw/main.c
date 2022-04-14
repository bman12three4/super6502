#include <stdint.h>
#include <conio.h>

#include "board_io.h"
#include "uart.h"
#include "mapper.h"
#include "sd_card.h"
#include "fat.h"

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
		if (i % 16 == 0)
			cprintf("\n %2x: ", i);
		cprintf("%2x ", buf[i]);
	}

	cprintf("\n");
}

int main() {
	int i;
	uint8_t sw;
	uint32_t resp;
	ebpb_t* epbp;
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

	epbp = (ebpb_t*)&buf[11];

	cprintf("Bytes per sector: %d\n", epbp->bpb3.bpb2.bytes_per_sector);
	cprintf("Sectors per cluster: %d\n", epbp->bpb3.bpb2.sectors_per_cluster);
	cprintf("Reserved Sectors: %d\n", epbp->bpb3.bpb2.reserved_sectors);
	cprintf("Fat Count: %d\n", epbp->bpb3.bpb2.fat_count);
	cprintf("Max Dir Entries: %d\n", epbp->bpb3.bpb2.max_dir_entries);
	cprintf("Total Sector Count: %d\n", epbp->bpb3.bpb2.total_sector_count);
	cprintf("Media Descriptor: 0x%x\n", epbp->bpb3.bpb2.media_descriptor);
	cprintf("Sectors per Fat: %d\n", epbp->bpb3.bpb2.sectors_per_fat);
	cprintf("\n");

	cprintf("Sectors per track: %d\n", epbp->bpb3.sectors_per_track);
	cprintf("Head Count: %d\n", epbp->bpb3.head_count);
	cprintf("Hidden Sector Count: %d\n", epbp->bpb3.hidden_sector_count);
	cprintf("Logical Sector Count: %d\n", epbp->bpb3.logical_sector_count);
	cprintf("Sectors per Fat: %d\n", epbp->bpb3.sectors_per_fat);
	cprintf("Extended Flags: 0x%x\n", epbp->bpb3.extended_flags);
	cprintf("Version: %d\n", epbp->bpb3.version);
	cprintf("Root Cluster: 0x%x\n", epbp->bpb3.root_cluster);
	cprintf("System Information: 0x%x\n", epbp->bpb3.system_information);
	cprintf("Backup Boot Sector: 0x%x\n", epbp->bpb3.backup_boot_sector);
	cprintf("\n");

	cprintf("Drive Number: %d\n", epbp->drive_num);
	cprintf("Extended Signature: 0x%x\n", epbp->extended_signature);
	cprintf("Volume ID: 0x%lx\n", epbp->volume_id);
	cprintf("Partition Label: %.11s\n", &epbp->partition_label);
	cprintf("Partition Label: %.8s\n", &epbp->filesystem_type);
	cprintf("\n");

	cprintf("Boot Signature: %x %x\n", buf[510], buf[511]);

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
