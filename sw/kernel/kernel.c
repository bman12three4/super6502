#include <conio.h>
#include "devices/interrupt_controller.h"
#include "interrupts/interrupt.h"
#include "devices/mapper.h"
#include "devices/rtc.h"


void handle_rtc_interrupt() {
    // cputs("In IRQ interrupt!\n");
    cputc('A');
    send_eoi();
    asm volatile ("rti");
}

int main() {

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

    // cputs("Initialize Serial\n");
    // // init_serial();
    // enable_irq(2, IRQ_EDGE);

    while(1);

    return 0;
}
