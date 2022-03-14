
#include <stdint.h>

#include "interrupt.h"

// This is defined in main.c
void puts(const char* s);

void handle_irq() {
    uint8_t status;

    puts("Interrupt Detected!\n");

    status = irq_get_status();

    if (status & BUTTON) {
        puts("Button Interrupt!\n");
        irq_set_status(status & ~BUTTON);
    }
    if (status & UART) {
        puts("UART Interrupt!\n");
        irq_set_status(status & ~UART);
    }
}