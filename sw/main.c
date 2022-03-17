#include <stdint.h>
#include <conio.h>

#include "board_io.h"
#include "uart.h"

int main() {
    int i;
    uint8_t sw;
    char s[16];
    s[15] = 0;

    clrscr();
    cprintf("Hello, world!\n");

    while (1) {

        sw = sw_read();
        led_set(sw);

        cscanf("%15s", s);
        cprintf("\n");
        for (i = 0; i < 16; i++)
            cprintf("s[%d]=%c ", i, s[i]);
        cprintf("\n");
        cprintf("Read string: %s\n", s);
    }

    return 0;
}
