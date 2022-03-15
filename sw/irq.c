
#include <stdint.h>
#include <conio.h>

#include "interrupt.h"
#include "uart.h"
#include "sevenseg.h"

char lastchar;


void handle_irq() {
    uint8_t status;
    char c;

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