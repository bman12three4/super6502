#include <stdint.h>
#include <conio.h>

#include "sevenseg.h"
#include "uart.h"

int main() {
    uint8_t* test;
    uint8_t i;

    test = (uint8_t*)0x5000;

    clrscr();

    for (test = (uint8_t*)0x4000; test < (uint8_t*)0x5000; test++) {
        for (i = 0; i < 64; i++) {
            *test = i;
            if (*test != i)
                cprintf("Failed to read/write %x to %x\n", i, test);
        }
    }

    cprintf("Done! no SDRAM errors!\n");

    return 0;
}
