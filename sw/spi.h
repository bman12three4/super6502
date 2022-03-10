#ifndef _SPI_H
#define _SPI_H

#include <stdint.h>

uint8_t spi_byte(uint8_t);
void spi_deselect(void);

#endif