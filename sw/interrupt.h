#ifndef _INTERRUPT_H
#define _INTERRUPT_H

#include <stdint.h>

#define BUTTON  (1 << 0)

void irq_int();
void nmi_int();

uint8_t irq_get_status();

#endif