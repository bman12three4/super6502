#include <stdio.h>
#include <filesystems/fat32.h>
#include <conio.h>

void fat32_init(void);

char data [256];

int main(void) {
    int8_t fd;
    size_t i;
    size_t nbytes;
    fat32_init();

    cprintf("log2 sectors per cluster: %x\n", log2_sectors_per_cluster);

    /* This is what is going to be part of open */
    fd = fat32_file_open("VERYLA~1TXT");
    cprintf("fd: %x\n", fd);

    nbytes = fat32_file_read(fd, data, 123);
    for (i = 0; i < nbytes; i++) {
        cprintf("%c", data[i]);
    }

    while ((nbytes = fat32_file_read(fd, data, 256))){
        for (i = 0; i < nbytes; i++) {
            cprintf("%c", data[i]);
        }
    }
}