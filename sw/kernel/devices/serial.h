#ifndef _SERIAL_H
#define _SERIAL_H

#include <stdint.h>

void serial_handle_irq();

void serial_init();

void serial_putc(char c);
void serial_puts(char* s);


char serial_getc();
char serial_getc_nb();

#endif