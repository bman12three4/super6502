#include <conio.h>
#include "devices/interrupt_controller.h"
#include "devices/rtc.h"


int main() {

    cputs("Kernel\n");

    // cputs("Init Paging")
    // init_paging()

    // cputs("Initialize Interrupts");
    // init_interrupts();

    cputs("Initialize Interrupt Controller");
    init_interrupt_controller();

    cputs("Initialize RTC");
    init_rtc();

    // cputs("Initialize Serial");
    // // init_serial();
    // enable_irq(2, IRQ_EDGE);

    while(1);

    return 0;
}