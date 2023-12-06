#include <stdio.h>
#include <filesystems/fat32.h>
#include <conio.h>

void fat32_init(void);

char data [256];

int main(void) {
    int8_t fd;
    size_t i;
    fat32_init();

    /* This is what is going to be part of open */
    fd = fat32_file_open("VERYLA~1TXT");
    cprintf("fd: %x\n", fd);

    while (fat32_file_read(fd, data, 256)){
        for (i = 0; i < 256; i++) {
            cprintf("%c", data[i]);
        }
    }
}