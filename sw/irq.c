
#include <stdint.h>
#include <conio.h>

#include "devices/interrupt.h"
#include "devices/uart.h"

char lastchar;


void handle_irq() {
    uint8_t status;

    status = irq_get_status();

    if (status & BUTTON) {
        cputs("Button Interrupt!\n");
        irq_set_status(status & ~BUTTON);
    }
    if (status & UART) {
        lastchar = uart_rxb();
        irq_set_status(status & ~UART);
    }
}