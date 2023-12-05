#include "fat32.h"
#include <devices/sd_card.h>
#include <conio.h>

#include <stdint.h>

uint8_t fat32_read_cluster(uint32_t cluster, void* buf) {
    uint8_t error;
    uint32_t addr = (cluster - 2) + data_start_sector;
    SD_readSingleBlock(addr, buf, &error);
    return error;
}

uint8_t fat32_get_cluster_by_name(char* name, struct fat32_directory_entry* dentry) {
    struct fat32_directory_entry* local_entry;
    int i = 0;
    fat32_read_cluster(root_cluster, sd_buf);
    for (i = 0; i < 16; i++){
        local_entry = sd_buf + i*32;
        if (local_entry->attr1 == 0xf || local_entry->attr1 & 0x8 || !local_entry->attr1) {
            continue;
        }
        cprintf("Name: %.11s\n", local_entry->file_name, local_entry->file_ext);
        cprintf("attr1: %x\n", local_entry->attr1);
    }
}
