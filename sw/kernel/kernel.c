#include <conio.h>
#include "devices/interrupt_controller.h"
#include "interrupts/interrupt.h"
#include "devices/mapper.h"
#include "devices/rtc.h"
#include "devices/serial.h"


void handle_rtc_interrupt() {
    // cputs("In IRQ interrupt!\n");
    // cputc('A');
    send_eoi();
    asm volatile ("rti");
}

int main() {

    uint8_t c;

    cputs("Kernel\n");

    cputs("Init Mapper\n");
    init_mapper();

    cputs("Initialize Interrupts\n");
    init_interrupts();

    cputs("Initialize Interrupt Controller\n");
    init_interrupt_controller();

    cputs("Initialize RTC\n");
    init_rtc();

    register_irq(&handle_rtc_interrupt, 0);

    asm volatile("cli");

    cputs("Initialize Serial\n");
    serial_init();

    serial_puts("Hello from serial!\n");

    while(1) {
        c = serial_getc();
        serial_puts("Got a character!: ");
        serial_putc(c);
        serial_putc('\n');
    }

    return 0;
}
