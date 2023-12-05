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

int8_t fat32_get_cluster_by_name(char* name, struct fat32_directory_entry* dentry) {
    struct fat32_directory_entry* local_entry;
    int i = 0;

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

    cprintf("attr1: %x\n", local_entry->attr1);
    cprintf("cluster: %x %x\n", local_entry->cluster_high, local_entry->cluster_low);
    cprintf("File Size: %lx\n", local_entry->file_size);
}
