#include <conio.h>
#include "devices/interrupt_controller.h"
#include "interrupts/interrupt.h"
#include "devices/rtc.h"


void handle_rtc_interrupt() {
    cputs("In IRQ interrupt!\n");
    asm volatile ("rti");
}

int main() {

    cputs("Kernel\n");

    // cputs("Init Paging\n")
    // init_paging()

    // cputs("Initialize Interrupts\n");
    // init_interrupts();

    cputs("Initialize Interrupt Controller\n");
    init_interrupt_controller();

    cputs("Initialize RTC\n");
    init_rtc();

    register_irq(&handle_rtc_interrupt, 0);

    // cputs("Initialize Serial\n");
    // // init_serial();
    // enable_irq(2, IRQ_EDGE);

    while(1);

    return 0;
}
