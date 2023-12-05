#include "fat32.h"

#include <devices/sd_card.h>
#include <conio.h>
#include <stdint.h>
#include <string.h>

int8_t fat32_read_cluster(uint32_t cluster, void* buf) {
    uint8_t error;
    uint32_t addr = (cluster - 2) + data_start_sector;
    SD_readSingleBlock(addr, buf, &error);
    return error;
}

uint32_t fat32_next_cluster(uint32_t cluster) {
    uint8_t error;
    uint32_t addr = fat_start_sector;
    uint32_t cluster_val;
    SD_readSingleBlock(addr, sd_buf, &error);
    cluster_val = ((uint32_t*)sd_buf)[cluster];
    return cluster_val;
}

int8_t fat32_get_cluster_by_name(char* name, struct fat32_directory_entry* dentry) {
    struct fat32_directory_entry* local_entry;
    int i = 0;

    uint32_t cluster;

    cluster = fat32_next_cluster(root_cluster);

    cprintf("Sectors per cluster: %hhx\n", sectors_per_cluster);

    fat32_read_cluster(root_cluster, sd_buf);
    for (i = 0; i < 16; i++){
        local_entry = sd_buf + i*32;
        if (local_entry->attr1 == 0xf || local_entry->attr1 & 0x8 || !local_entry->attr1) {
            continue;
        }
        cprintf("Name: %.11s\n", local_entry->file_name, local_entry->file_ext);
        if (!strncmp(local_entry->file_name, name, 11)) {
            i = -1;
            break;
        }
    }
    if (i != -1) {
        cprintf("Failed to find file.\n");
        return -1;
    }

    cprintf("Found file!\n");
    memcpy(dentry, local_entry, 32);
    return 0;
}
