#include <conio.h>
#include <string.h>
#include <stdlib.h>

#include "fat.h"
#include "devices/sd_card.h"

uint8_t fat_buf[512];

static uint32_t fat_end_of_chain;

static full_bpb_t bpb;

static uint32_t data_region_start;

void fat_print_pbp_info(full_bpb_t* bpb){
	cprintf("Bytes per sector: %d\n", bpb->bytes_per_sector);
	cprintf("Sectors per cluster: %d\n", bpb->sectors_per_cluster);
	cprintf("Reserved Sectors: %d\n", bpb->reserved_sectors);
	cprintf("Fat Count: %d\n", bpb->fat_count);
	cprintf("Max Dir Entries: %d\n", bpb->max_dir_entries);
	cprintf("Total Sector Count: %d\n", bpb->total_sector_count);
	cprintf("Media Descriptor: 0x%x\n", bpb->media_descriptor);
	cprintf("Sectors per Fat: %d\n", bpb->sectors_per_fat_16);
	cprintf("\n");

	cprintf("Sectors per track: %d\n", bpb->sectors_per_track);
	cprintf("Head Count: %d\n", bpb->head_count);
	cprintf("Hidden Sector Count: %ld\n", bpb->hidden_sector_count);
	cprintf("Logical Sector Count: %ld\n", bpb->logical_sector_count);
	cprintf("Sectors per Fat: %ld\n", bpb->sectors_per_fat_32);
	cprintf("Extended Flags: 0x%x\n", bpb->extended_flags);
	cprintf("Version: %d\n", bpb->version);
	cprintf("Root Cluster: 0x%lx\n", bpb->root_cluster);
	cprintf("System Information: 0x%x\n", bpb->system_information);
	cprintf("Backup Boot Sector: 0x%x\n", bpb->backup_boot_sector);
	cprintf("\n");

	cprintf("Drive Number: %d\n", bpb->drive_num);
	cprintf("Extended Signature: 0x%x\n", bpb->extended_signature);
	cprintf("Volume ID: 0x%lx\n", bpb->volume_id);
	cprintf("Partition Label: %.11s\n", &bpb->partition_label);
	cprintf("Partition Label: %.8s\n", &bpb->filesystem_type);
	cprintf("\n");
}

void fat_init(){
    sd_readblock(0, fat_buf);

    memcpy(&bpb, &fat_buf[11], sizeof(full_bpb_t));

	sd_readblock(1, fat_buf);
	sd_readblock(32, fat_buf);

	fat_print_pbp_info(&bpb);

	data_region_start = bpb.reserved_sectors + bpb.fat_count*bpb.sectors_per_fat_32;

	sd_readblock(bpb.reserved_sectors, fat_buf);

	fat_end_of_chain = ((uint32_t*)fat_buf)[1] & FAT_EOC_CLUSTERMASK;
	cprintf("End of chain indicator: %lx\n", fat_end_of_chain);
}

void fat_read(char* filename, void* buf) {
	vfat_dentry_t* vfat_dentry;
	dos_dentry_t* dos_dentry;
	uint32_t cluster;

	(void)filename;	//just ignore filename

    sd_readblock(data_region_start, buf);

	vfat_dentry = (vfat_dentry_t*)buf;
	while(vfat_dentry->sequence_number == 0xe5)
		vfat_dentry++;

	dos_dentry = (dos_dentry_t*)(vfat_dentry + 1);

	cluster = ((uint32_t)dos_dentry->first_cluster_h << 16) + dos_dentry->first_cluster_l;

	sd_readblock(data_region_start + (cluster - 2) * 8, buf);
}

//the dentry is a double pointer because we need to increment it.
void fat_parse_vfat_filenamename(vfat_dentry_t** vfat_dentry, char* name) {
	uint8_t i;
	uint8_t done;
	char* shift_name;
	uint8_t sequence_number = (*vfat_dentry)->sequence_number;

	// so basically we want to add 13*(sequence number-1) to name

	for (;;){
		shift_name = name + 13*((sequence_number & FAT_LFN_ENTRY_MASK) - 1);

		done = 0;
		for(i = 0; i < 5; i++) {
			shift_name[i] = (*vfat_dentry)->filename0[i];
			if (!shift_name[i]) {
				done = 1;
				break;
			}
		}

		if (!done) {
			for(i = 0; i < 6; i++) {
				shift_name[i+5] = (*vfat_dentry)->filename1[i];
				if (!shift_name[i+5]) {
					done = 1;
					break;
				}
			}
		}

		if (!done) {
			for(i = 0; i < 2; i++) {
				shift_name[i+11] = (*vfat_dentry)->filename2[i];
				if (!shift_name[i+11]) {
					done = 1;
					break;
				}
			}
		}

		if ((sequence_number & FAT_LFN_ENTRY_MASK) == 1) {
			break;
		} else {
			(*vfat_dentry)++;
			while((*vfat_dentry)->sequence_number == 0xe5)
				(*vfat_dentry)++;
			sequence_number = (*vfat_dentry)->sequence_number;
		}
	}

}

uint32_t fat_find_cluster_num(char* name, uint32_t cluster) {
	vfat_dentry_t* vfat_dentry;
	dos_dentry_t* dos_dentry;
	char* vfat_name;

	cprintf("Looking for file %s\n", name);

	sd_readblock(data_region_start + (cluster - 2) * 8, fat_buf);
	vfat_dentry = (vfat_dentry_t*)fat_buf;

	vfat_name = (char*)malloc(FAT_MAX_FILE_NAME);

	while(vfat_dentry->sequence_number == 0xe5)
		vfat_dentry++;

	vfat_name[0] = '\0';

	while(vfat_dentry->sequence_number) {
		fat_parse_vfat_filenamename(&vfat_dentry, vfat_name);
		cprintf("Parsed filename: %s\n", vfat_name);

		if (!strcmp(vfat_name, name)) {				//TODO this is probably unsafe, use strncmp
			cprintf("Found file %s\n", vfat_name);
			break;
		} else {
			vfat_dentry += 2;
			while(vfat_dentry->sequence_number == 0xe5)
				vfat_dentry++;
		}
	}

	free(vfat_name);

	if (!vfat_dentry->sequence_number) {
		cprintf("File not found.\n");
		return -1;
	}

	dos_dentry = (dos_dentry_t*) vfat_dentry + 1;	//dos entry follows last vfat entry

	cluster = ((uint32_t)dos_dentry->first_cluster_h << 16) + dos_dentry->first_cluster_l;
	cprintf("Cluster: %ld\n", cluster);

	return cluster;
}

uint16_t fat_parse_path_to_cluster(char* filename) {
	//basically start at the root folder and search through it
	int i;
	int len;

	char* spaced_filename;

	uint32_t cluster = 2;	//root chain is chain 2

	if (filename[0] != '/') {
		cprintf("Filename does not begin with '/'\n");
		return 0;
	}

	filename++;
	len = strlen(filename);
	spaced_filename = (char*)malloc(len+1);	//need to account for null byte

	for (i = 0; i <= len; i++) {
		if (filename[i] == '/') {
			spaced_filename[i] = '\0';
		} else {
			spaced_filename[i] = filename[i];
		}
	}

	cprintf("Fragment: %s\n", spaced_filename);

	fat_find_cluster_num(spaced_filename, cluster);

	free(spaced_filename);
}
