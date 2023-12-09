#ifndef _MULTIPLER_H
#define _MULTIPLER_H

#include <stdint.h>

/* Multiply 2 integers into 1 long */
uint32_t lmulii(uint16_t a, uint16_t b);

/* Multiply 2 integers into 1 integer, discarding upper bits. */
uint16_t imulii(uint16_t a, uint16_t b);

#endif