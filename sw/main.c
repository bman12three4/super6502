#include <stdint.h>

#include "sevenseg.h"
#include "uart.h"

void puts(const char* s)
{
    while (*s) {
        uart_txb_block(*s);
        if (*s == '\n')
            uart_txb_block('\r');

        s++;
    }
}

int main() {
    hex_enable(0x3f);
    hex_set_24(0xabcdef);

    puts("Hello, World!\n");
    while(1);
    return 0;
}
