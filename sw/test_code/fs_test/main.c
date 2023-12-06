#include <stdio.h>
#include <filesystems/fat32.h>
#include <conio.h>

void fat32_init(void);

int main(void) {
    int8_t fd;
    fat32_init();

    /* This is what is going to be part of open */
    fd = fat32_file_open("VERYLA~1TXT");

    cprintf("fd: %x\n", fd);
}