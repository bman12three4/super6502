#ifndef _MAPPER_H
#define _MAPPER_H

#include <stdint.h>

void mapper_enable(uint8_t en);

uint8_t mapper_read(uint8_t addr);
void mapper_write(uint8_t data, uint8_t addr);

#endif

