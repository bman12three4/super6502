#ifndef _FAT_H
#define _FAT_H

#include <stdint.h>

extern uint8_t fat_buf[];

#define FAT_MAX_FILE_NAME 255
#define FAT_CLUSTERS_PER_SECTOR 128

#define FAT_CLUSTERMASK 0x0fffffff
#define FAT_EOC_CLUSTERMASK 0x0ffffff8

#define FAT_LAST_LFN_MASK (1 << 6)
#define FAT_LFN_ENTRY_MASK 0x1f

typedef struct {
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t fat_count;
    uint16_t max_dir_entries;
    uint16_t total_sector_count;
    uint8_t media_descriptor;
    uint16_t sectors_per_fat;
} dos_2_bpb_t;

typedef struct {
    dos_2_bpb_t bpb2;
    uint16_t sectors_per_track;
    uint16_t head_count;
    uint32_t hidden_sector_count;
    uint32_t logical_sector_count;
    uint32_t sectors_per_fat;
    uint16_t extended_flags;
    uint16_t version;
    uint32_t root_cluster;
    uint16_t system_information;
    uint16_t backup_boot_sector;
    uint8_t reserved[12];
} dos_3_bpb_t;

typedef struct {
    dos_3_bpb_t bpb3;
    uint8_t drive_num;
    uint8_t reserved;
    uint8_t extended_signature;
    uint32_t volume_id;
    uint8_t partition_label[11];
    uint8_t filesystem_type[8];
} ebpb_t;

typedef struct {
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t fat_count;
    uint16_t max_dir_entries;
    uint16_t total_sector_count;
    uint8_t media_descriptor;
    uint16_t sectors_per_fat_16;
    uint16_t sectors_per_track;
    uint16_t head_count;
    uint32_t hidden_sector_count;
    uint32_t logical_sector_count;
    uint32_t sectors_per_fat_32;
    uint16_t extended_flags;
    uint16_t version;
    uint32_t root_cluster;
    uint16_t system_information;
    uint16_t backup_boot_sector;
    uint8_t reserved[12];
    uint8_t drive_num;
    uint8_t reserved2;
    uint8_t extended_signature;
    uint32_t volume_id;
    uint8_t partition_label[11];
    uint8_t filesystem_type[8];
} full_bpb_t;

typedef struct {
    uint32_t sig;
    uint8_t reserved[480];
    uint32_t sig2;
    uint32_t free_data_clusters;
    uint32_t last_allocated_data_cluster;
    uint32_t reserved2;
    uint32_t sig3;
} fs_info_sector_t;

typedef struct {
    uint8_t sequence_number;
    uint16_t filename0[5];
    uint8_t attributes;
    uint8_t type;
    uint8_t checksum;
    uint16_t filename1[6];
    uint16_t reserved;
    uint16_t filename2[2];
} vfat_dentry_t;

typedef struct {
    uint8_t filename[8];
    uint8_t extension[3];
    uint8_t attributes;
    uint8_t reserved;
    uint8_t create_time_10ms;
    uint32_t create_date;
    uint16_t access_date;
    uint16_t first_cluster_h;
    uint32_t modify_cluster;
    uint16_t first_cluster_l;
    uint32_t file_size;
} dos_dentry_t;

void fat_print_pbp_info(full_bpb_t* bpb);
void fat_init();
void fat_read(char* filename, void* buf);

uint16_t fat_parse_path_to_cluster(char* filename);

#endif
