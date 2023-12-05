#include <stdio.h>
#include <filesystems/fat32.h>
#include <conio.h>

void fat32_init(void);

int main(void) {
    struct fat32_directory_entry dentry;
    int i;
    uint32_t offset = 0;
    uint32_t cluster;
    uint8_t cluster_count;
    fat32_init();

    /* This is what is going to be part of open */
    fat32_get_cluster_by_name("VERYLA~1TXT", &dentry);
    cprintf("attr1: %x\n", dentry.attr1);
    cprintf("cluster: %x%x\n", dentry.cluster_high, dentry.cluster_low);
    cprintf("File Size: %lx\n", dentry.file_size);


    /* This will become part of read */
    cluster = (dentry.cluster_high << 16) | dentry.cluster_low;
    cluster++;
    fat32_read_cluster(cluster + offset/512, sd_buf);

    cluster_count = (dentry.file_size/512)/sectors_per_cluster;
    cprintf("Cluster count: %x\n", cluster_count);

    while (cluster < 0xffffff0) {
        for (i = 0; i < dentry.file_size && i < 512; i++) {
            cprintf("%c", sd_buf[i]);
        }
        cluster = fat32_next_cluster(cluster);
        fat32_read_cluster(cluster + offset/512, sd_buf);
    }

    return 0;
}