#ifndef _MAPPER_H
#define _MAPPER_H

#include <stdint.h>

void init_mapper();

void map(uint16_t p_page, uint8_t v_page); 

#endif