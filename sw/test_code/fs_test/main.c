#include <stdio.h>
#include <filesystems/fat32.h>
#include <conio.h>

void fat32_init(void);

int main(void) {
    struct fat32_directory_entry dentry;
    int i;
    uint32_t offset = 0;
    uint32_t cluster;
    fat32_init();

    /* This is what is going to be part of open */
    fat32_get_cluster_by_name("TEST    TXT", &dentry);
    cprintf("attr1: %x\n", dentry.attr1);
    cprintf("cluster: %x%x\n", dentry.cluster_high, dentry.cluster_low);
    cprintf("File Size: %lx\n", dentry.file_size);


    /* This will become part of read */
    cluster = (dentry.cluster_high << 16) | dentry.cluster_low;
    fat32_read_cluster(cluster + offset/512, sd_buf);

    for (i = 0; i < dentry.file_size; i++) {
        cprintf("%c", sd_buf[i]);
    }

    return 0;
}