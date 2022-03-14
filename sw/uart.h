#ifndef _UART_H
#define _UART_H

#include <stdint.h>

void uart_txb(uint8_t val);
void uart_txb_block(uint8_t val);

uint8_t uart_status();

#endif