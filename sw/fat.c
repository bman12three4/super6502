#include <conio.h>
#include <string.h>

#include "fat.h"
#include "sd_card.h"

uint8_t fat_buf[512];

static full_bpb_t bpb;

static uint32_t data_region_start;

void fat_print_pbp_info(ebpb_t* epbp){
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

void fat_init(){
    sd_readblock(0, fat_buf);

    memcpy(&bpb, &fat_buf[11], sizeof(ebpb_t));

	sd_readblock(1, fat_buf);
	sd_readblock(32, fat_buf);

	data_region_start = bpb.reserved_sectors + bpb.fat_count*bpb.sectors_per_fat_32;
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
