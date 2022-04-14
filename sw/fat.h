#ifndef _FAT_H
#define _FAT_H

#include <stdint.h>

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

#endif