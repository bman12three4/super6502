#include <conio.h>

void read() {
    cprintf("Read syscall.\n");
    asm("rti");
}