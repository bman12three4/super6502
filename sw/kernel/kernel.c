#include <conio.h>
#include <string.h>

#include "devices/interrupt_controller.h"
#include "interrupts/interrupt.h"
#include "devices/mapper.h"
#include "devices/rtc.h"
#include "devices/serial.h"
#include "devices/terminal.h"

#include "filesystems/fat32.h"


void handle_rtc_interrupt() {
    // cputs("In IRQ interrupt!\n");
    // cputc('A');
    send_eoi();
    asm volatile ("rti");
}

char buf[128];

int main() {
    int8_t fd;
    size_t nbytes, i;

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

    rtc_set(0xaaaa, RTC_THRESHOLD);
    rtc_set(0xbbbb, RTC_IRQ_THRESHOLD);

    asm volatile("cli");

    cputs("Initialize Serial\n");
    serial_init();

    serial_puts("Hello from serial!\n");
    
    fat32_init();

    /* This is what is going to be part of open */
    fd = fat32_file_open("VERYLA~1TXT");
    cprintf("fd: %x\n", fd);

    nbytes = fat32_file_read(fd, buf, 23);
    for (i = 0; i < nbytes; i++) {
        cprintf("%c", buf[i]);
    }

    while ((nbytes = fat32_file_read(fd, buf, 128))){
        for (i = 0; i < nbytes; i++) {
            cprintf("%c", buf[i]);
        }
    }

    return 0;
}
