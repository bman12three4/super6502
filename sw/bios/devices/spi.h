#ifndef _SPI_H
#define _SPI_H

#include <stdint.h>

void spi_select(uint8_t id);
void spi_deselect(uint8_t id);
uint8_t spi_read();
void spi_write(uint8_t data);
uint8_t spi_exchange(uint8_t data);

#endif