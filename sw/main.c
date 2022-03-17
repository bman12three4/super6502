#include <stdint.h>
#include <conio.h>

#include "sevenseg.h"
#include "uart.h"

int main() {
    int i;
    char s[16];
    s[15] = 0;

    clrscr();
    cprintf("Hello, world!\n");

    while (1) {
        cscanf("%15s", s);
        cprintf("\n");
        for (i = 0; i < 16; i++)
            cprintf("s[%d]=%c ", i, s[i]);
        cprintf("\n");
        cprintf("Read string: %s\n", s);
    }

    return 0;
}
