#include <stdio.h>
#include <filesystems/fat32.h>

void fat32_init(void);

int main(void) {
    struct fat32_directory_entry dentry;
    fat32_init();
    fat32_get_cluster_by_name("TEST    TXT", &dentry);
    return 0;
}