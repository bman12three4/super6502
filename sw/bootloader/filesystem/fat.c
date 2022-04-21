#include <conio.h>
#include <string.h>
#include <stdlib.h>

#include "fat.h"
#include "devices/sd_card.h"

uint8_t fat_buf[512];

static uint32_t fat_end_of_chain;

full_bpb_t fat_bpb;

static uint32_t data_region_start;
static uint16_t bytes_per_cluster;

static uint16_t rb_last_cluster_offs;
static uint16_t rb_last_sector;

void fat_init(){
	//int i;

    sd_readblock(0, fat_buf);

    memcpy(&fat_bpb, &fat_buf[11], sizeof(full_bpb_t));

	sd_readblock(1, fat_buf);
	sd_readblock(32, fat_buf);

	data_region_start = fat_bpb.reserved_sectors + fat_bpb.fat_count*fat_bpb.sectors_per_fat_32;

	sd_readblock(fat_bpb.reserved_sectors, fat_buf);

	//uncomment to view start of FAT

	/*
	for (i = 0; i < FAT_CLUSTERS_PER_SECTOR; i++) {
		cprintf("%lx ", ((uint32_t*)fat_buf)[i]);
	}
	cprintf("\n\n");
	*/

	rb_last_sector = -1;
	rb_last_cluster_offs = -1;

	fat_end_of_chain = ((uint32_t*)fat_buf)[1] & FAT_EOC_CLUSTERMASK;
	bytes_per_cluster = fat_bpb.bytes_per_sector * fat_bpb.sectors_per_cluster;
	cprintf("End of chain indicator: %lx\n", fat_end_of_chain);
}


// make sure you have enough space.
void fat_read_cluster(uint16_t cluster, uint8_t* buf) {
	uint8_t i;

	for (i = 0; i < fat_bpb.sectors_per_cluster; i++) {
		sd_readblock(data_region_start + i + (cluster - 2) * 8, buf+i*fat_bpb.bytes_per_sector);
	}
}

void fat_read_sector(uint16_t cluster, uint8_t sector, uint8_t* buf) {
	sd_readblock(data_region_start + sector + (cluster - 2) * 8, buf);
}

void fat_read_bytes(uint8_t* dest, uint16_t cluster, uint16_t offs, uint16_t len) {
	// first we need to find the cluster that the actual data is stored in
	// to do this we need to loop through the clusters until we reach the one that
	// the offset is in.

	int i;
	uint16_t cluster_offs = offs / bytes_per_cluster;
	uint16_t sector = (offs % bytes_per_cluster) / fat_bpb.bytes_per_sector;
	uint16_t byte_offs = (offs % bytes_per_cluster) % fat_bpb.bytes_per_sector;

	uint16_t bytes_read = 0;

	//cprintf("Dest: %p\n", dest);
	//cprintf("len: %d\n", len);

	//Find the first cluster:
	if (cluster_offs != rb_last_cluster_offs || sector != rb_last_sector || byte_offs + len > 512) {
		rb_last_cluster_offs = cluster_offs;
		rb_last_sector = sector;
	} else {
		//cprintf("Using cached data!\n");
		memcpy(dest, &fat_buf[byte_offs], len);
		return;
	}

	for (i = 0; i < cluster_offs; i++) {
		cluster = fat_get_chain_value(cluster);
	}
	//cprintf("Cluster: %x\n", cluster);
	//cprintf("Sector: %x\n", sector);


	if (len > fat_bpb.bytes_per_sector-byte_offs) {
		cprintf("Copying %d bytes starting at %d\n", fat_bpb.bytes_per_sector-byte_offs, byte_offs);
		fat_read_sector(cluster, sector, fat_buf);
		memcpy(dest, &fat_buf[byte_offs], fat_bpb.bytes_per_sector-byte_offs);
		bytes_read += fat_bpb.bytes_per_sector-byte_offs;
	} else {
		cprintf("Copying %d bytes starting at %x\n", len, byte_offs);
		fat_read_sector(cluster, sector, fat_buf);

		/*
		for (i = 0; i < 512; i++) {
			if (!(i % 16)) cprintf("\n%02x: ", i);
			cprintf("%02x ", fat_buf[i]);
		}
		*/

		memcpy(dest, &fat_buf[byte_offs], len);
		bytes_read += len;
		return;
	}

	cprintf("Read %d total\n", bytes_read);

	// get the aligned sectors

	while (len-bytes_read > fat_bpb.bytes_per_sector) {
		sector++;
		if (sector == 8) {
			//cprintf("Need go to to next cluster!\n");
			sector = 0;
			cluster = fat_get_chain_value(cluster);
		}
		//cprintf("Cluster: %d\n", cluster);
		//cprintf("Sector: %d\n", sector);

		fat_read_sector(cluster, sector, fat_buf);
		memcpy(dest + bytes_read, fat_buf, fat_bpb.bytes_per_sector);
		bytes_read += fat_bpb.bytes_per_sector;

		cprintf("Read %d total\n", bytes_read);
	}

	// get the last unaligned sector

	sector++;
	if (sector == 8) {
		cprintf("Need go to to next cluster!\n");
		sector = 0;
		cluster = fat_get_chain_value(cluster);
	}
	fat_read_sector(cluster, sector, fat_buf);
	cprintf("Writing to %p\n", dest + bytes_read);
	memcpy(dest + bytes_read, fat_buf, len-bytes_read);
	bytes_read += len-bytes_read;

	cprintf("Read %d total\n", bytes_read);

}

uint32_t fat_get_chain_value(uint16_t cluster) {
	sd_readblock(fat_bpb.reserved_sectors, fat_buf);
	return ((uint32_t*)fat_buf)[cluster];
}

//the dentry is a double pointer because we need to increment it.
void fat_parse_vfat_filenamename(vfat_dentry_t** vfat_dentry, char* name, uint32_t cluster) {
	uint8_t i;
	uint8_t overflows;
	uint8_t done;
	char* shift_name;
	uint8_t sequence_number = (*vfat_dentry)->sequence_number;
	overflows = 0;

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
			do {
				(*vfat_dentry)++;
				if ((uint8_t*)*vfat_dentry >= fat_buf + sizeof(fat_buf)) {
					overflows++;
					if (overflows == fat_bpb.sectors_per_cluster) {
						cprintf("Too many overflows, go back to fat!\n");		//TODO this
						return;
					}
					sd_readblock(data_region_start + (cluster - 2) * 8 + overflows, fat_buf);
					*vfat_dentry = (vfat_dentry_t*)fat_buf;
				}
			} while((*vfat_dentry)->sequence_number == 0xe5);
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
		fat_parse_vfat_filenamename(&vfat_dentry, vfat_name, cluster);
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
	uint8_t dirs = 0;

	char* spaced_filename;
	char* fragment;

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
			dirs++;
		} else {
			spaced_filename[i] = filename[i];
		}
	}

	fragment = spaced_filename;

	cprintf("Dirs: %d\n", dirs);

	for (i = 0; i <= dirs; i++) {
		cprintf("Fragment: %s\n", fragment);
		cluster = fat_find_cluster_num(fragment, cluster);
		fragment = spaced_filename + strlen(fragment) + 1;
	}

	free(spaced_filename);

	return cluster;
}
