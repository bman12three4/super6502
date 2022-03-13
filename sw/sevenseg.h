#ifndef _SEVEN_SEG
#define _SEVEN_SEG

#include <stdint.h>

uint8_t hex_set_8(uint8_t val, uint8_t idx);
uint8_t hex_set_16(uint16_t val);
uint8_t hex_set_24(uint32_t val);

void hex_enable(uint8_t mask);

#endif