#ifndef _FAT32_H
#define _FAT32_H

#include <stdint.h>

void fat32_init();

extern uint32_t root_cluster;
extern uint16_t fat_start_sector;
extern uint32_t data_start_sector;
extern uint32_t fat_size;
extern uint8_t* sd_buf;
extern uint8_t sectors_per_cluster;

struct fat32_directory_entry {
    char file_name[8];
    char file_ext[3];
    uint8_t attr1;
    uint8_t attr2;
    uint8_t create_time_10ms;
    uint16_t create_time;
    uint16_t create_date;
    uint16_t access_date;
    uint16_t cluster_high;
    uint16_t modified_time;
    uint16_t modified_date;
    uint16_t cluster_low;
    uint32_t file_size;
};

struct lfn_entry {
    uint8_t sequence_number;
    uint16_t name_0[5];
    uint8_t attributes;
    uint8_t type;
    uint8_t checksum;
    uint16_t name_1[6];
    uint16_t cluster_low;
    uint16_t name_2[2];
};

int8_t fat32_get_cluster_by_name(char* name, struct fat32_directory_entry* dentry);
int8_t fat32_read_cluster(uint32_t cluster, void* buf);
uint32_t fat32_next_cluster(uint32_t cluster);

#endif
