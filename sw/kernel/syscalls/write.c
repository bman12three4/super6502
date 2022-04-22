#include <conio.h>

void write() {
    cprintf("Write syscall.\n");
    asm("rti");
}