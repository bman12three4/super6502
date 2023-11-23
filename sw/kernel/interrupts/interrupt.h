#ifndef _INTERRUPT_H
#define _INTERRUPT_H

#include <stdint.h>

#define BUTTON  (1 << 0)
#define UART    (1 << 1)

void init_interrupts();

void register_irq(void* addr, uint8_t irqn);

uint8_t irq_get_status();
void irq_set_status(uint8_t);

#endif