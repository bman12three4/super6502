#ifndef _INTERRUPT_CONTROLLER_H
#define _INTERRUPT_CONTROLLER_H

#include <stdint.h>

// These need to be copied in interrupt_controller.s

#define IRQ_CMD_ADDR 0xeffc
#define IRQ_DAT_ADDR 0xeffd

#define IRQ_CMD_MASK 0xe0
#define IRQ_REG_MASK 0x1f

#define IRQ_CMD_READIRQ 0x00
#define IRQ_CMD_ENABLE 0x20
#define IRQ_CMD_TYPE 0x40
#define IRQ_CMD_EOI 0xff

#define IRQ_EDGE 0
#define IRQ_LEVEL 1



void init_interrupt_controller();

void enable_irq(uint8_t type, uint8_t irqnum);
void disable_irq(uint8_t irqnum);

// This should accept irqnum later.
void send_eoi();

#endif