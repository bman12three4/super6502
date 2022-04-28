#include <conio.h>

#ifndef TEST

void read() {
    cprintf("Read syscall.\n");
    asm("rti");
}

#endif TEST