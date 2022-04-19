#include <stdint.h>

#include "bios_calls.h"
#include "uart.h"

//Should probably do this in asm
void load_bootsect() {
    uart_txb_block('A');
    for (;;);
    return;
}