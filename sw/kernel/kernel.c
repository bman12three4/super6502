#include <conio.h>
#include "devices/interrupt_controller.h"
#include "devices/rtc.h"


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

    // cputs("Initialize Serial\n");
    // // init_serial();
    // enable_irq(2, IRQ_EDGE);

    while(1);

    return 0;
}