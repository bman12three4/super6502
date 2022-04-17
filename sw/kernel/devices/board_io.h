#ifndef _BOARD_IO_H
#define _BOARD_IO_H

#include <stdint.h>

uint8_t hex_set_8(uint8_t val, uint8_t idx);
uint8_t hex_set_16(uint16_t val);
uint8_t hex_set_24(uint32_t val);

void hex_enable(uint8_t mask);

uint8_t sw_read();

void led_set(uint8_t val);

#endif