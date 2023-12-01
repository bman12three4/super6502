#include <conio.h>
#include <string.h>

#include "devices/interrupt_controller.h"
#include "interrupts/interrupt.h"
#include "devices/mapper.h"
#include "devices/rtc.h"
#include "devices/serial.h"

#include "devices/terminal.h"


void handle_rtc_interrupt() {
    // cputs("In IRQ interrupt!\n");
    // cputc('A');
    send_eoi();
    asm volatile ("rti");
}

char buf[128];

int main() {
    cputs("Kernel\n");

    // cputs("Init Mapper\n");
    init_mapper();

    // cputs("Initialize Interrupts\n");
    init_interrupts();

    // cputs("Initialize Interrupt Controller\n");
    init_interrupt_controller();

    // cputs("Initialize RTC\n");
    init_rtc();

    register_irq(&handle_rtc_interrupt, 0);

    asm volatile("cli");

    // cputs("Initialize Serial\n");
    serial_init();

    serial_puts("Hello from serial!\n");

    terminal_open(NULL);
    terminal_write(0, "Terminal Write\n", 15);

    while(1) {
        if (terminal_read(0, buf, 128)) {
            cprintf("Fail\n");
            break;
        }
        terminal_write(0, "Got: ", 5);
        terminal_write(0, buf, strlen(buf));
        terminal_write(0, "\n", 1);
    }

    return 0;
}
