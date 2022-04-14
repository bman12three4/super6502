#include <stdint.h>
#include <conio.h>

#include "board_io.h"
#include "uart.h"
#include "mapper.h"
#include "sd_card.h"
#include "fat.h"

uint8_t buf[512];

void sd_readblock(uint32_t addr) {
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

	/*
	for (i = 0; i < 512; i++){
		if (i % 16 == 0)
			cprintf("\n %2x: ", i);
		cprintf("%2x ", buf[i]);
	}
	*/

	cprintf("\n");
}

void print_pbp_info(ebpb_t* epbp){
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
	cprintf("Hidden Sector Count: %ld\n", epbp->bpb3.hidden_sector_count);
	cprintf("Logical Sector Count: %ld\n", epbp->bpb3.logical_sector_count);
	cprintf("Sectors per Fat: %ld\n", epbp->bpb3.sectors_per_fat);
	cprintf("Extended Flags: 0x%x\n", epbp->bpb3.extended_flags);
	cprintf("Version: %d\n", epbp->bpb3.version);
	cprintf("Root Cluster: 0x%lx\n", epbp->bpb3.root_cluster);
	cprintf("System Information: 0x%x\n", epbp->bpb3.system_information);
	cprintf("Backup Boot Sector: 0x%x\n", epbp->bpb3.backup_boot_sector);
	cprintf("\n");

	cprintf("Drive Number: %d\n", epbp->drive_num);
	cprintf("Extended Signature: 0x%x\n", epbp->extended_signature);
	cprintf("Volume ID: 0x%lx\n", epbp->volume_id);
	cprintf("Partition Label: %.11s\n", &epbp->partition_label);
	cprintf("Partition Label: %.8s\n", &epbp->filesystem_type);
	cprintf("\n");
}

int main() {
	int i;
	uint8_t sw;
	uint32_t resp;
	ebpb_t* epbp;
	fs_info_sector_t* fsis;
	vfat_dentry_t* vfat_dentry;
	dos_dentry_t* dos_dentry;
	uint32_t cluster;


	uint16_t reserved_count;
	uint32_t sectors_per_fat;
	uint8_t fat_count;

	uint32_t data_region_start;

	char s[16];
	s[15] = 0;

	clrscr();
	cprintf("Hello, world!\n");

	for (i = 0; i < 16; i++){
		//cprintf("Mapping %1xxxx to %2xxxx\n", i, i);
		mapper_write(i, i);
	}

	cprintf("Enabling Mapper\n");
	mapper_enable(1);


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

	print_pbp_info(epbp);

	cprintf("Boot Signature: %x %x\n", buf[510], buf[511]);

	reserved_count = epbp->bpb3.bpb2.reserved_sectors;
	fat_count = epbp->bpb3.bpb2.fat_count;
	sectors_per_fat = epbp->bpb3.sectors_per_fat;

	sd_readblock(1);

	fsis = (fs_info_sector_t*)&buf[0];

	cprintf("Free Data clusters: %ld\n", fsis->free_data_clusters);
	cprintf("Last allocated data cluster: %ld\n", fsis->last_allocated_data_cluster);

	cprintf("32 reserved sectors, reading from sector 32...\n");
	sd_readblock(32);
	cprintf("CLUST_0: %08lx\n", *(uint32_t*)&buf[0]);
	cprintf("CLUST_1: %08lx\n", *(uint32_t*)&buf[1*4]);

	cprintf("Root cluster: %08lx\n", *(uint32_t*)&buf[2*4]);

	data_region_start = reserved_count + fat_count*sectors_per_fat;
	cprintf("Data Region starting sector: %lx\n", data_region_start);
	cprintf("Reading root directory entry...\n");

	cprintf("%ld\n", data_region_start*512);

	sd_readblock(data_region_start);

	vfat_dentry = (vfat_dentry_t*)buf;
	while(vfat_dentry->sequence_number == 0xe5)
		vfat_dentry++;


	cprintf("Sequence: %x\n", vfat_dentry->sequence_number);
	cprintf("Name: ");
	for (i = 0;; i++) {						// this will not work for proper vfat names
		if (i < 5) {
			if (!vfat_dentry->filename0[i])
				break;
			cprintf("%c", vfat_dentry->filename0[i]);
		} else if (i < 11) {
			if (!vfat_dentry->filename0[i])
				break;
			cprintf("%c", vfat_dentry->filename1[i-5]);
		} else {
			break;
		}
	}
	cprintf("\n");
	dos_dentry = (dos_dentry_t*)(vfat_dentry + 1);

	cprintf("DOS name: %.8s.%.3s\n", &dos_dentry->filename, &dos_dentry->extension);
	
	cluster = (dos_dentry->first_cluster_h << 16) + dos_dentry->first_cluster_l;
	cprintf("Cluster: %ld\n", cluster);

	cprintf("File location: %lx\n", data_region_start + (cluster - 2) * 8);

	sd_readblock(data_region_start + (cluster - 2) * 8);

	cprintf("File contents: %s\n", buf);

	cprintf("Done!\n");



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
