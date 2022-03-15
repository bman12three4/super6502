#include <stdint.h>
#include <conio.h>

#include "sevenseg.h"
#include "uart.h"

int main() {
    char s[16];

    clrscr();
    cprintf("Hello, world!\n");

    while (1) {
        cscanf("%15s", s);
        cprintf("Read string: %s\n", s);
    }


    return 0;
}
