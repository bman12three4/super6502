#include <conio.h>

#ifndef TEST

void write() {
    cprintf("Write syscall.\n");
    asm("rti");
}

#endif