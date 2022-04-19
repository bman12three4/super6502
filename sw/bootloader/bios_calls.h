#ifndef _BIOS_CALLS_H
#define _BIOS_CALLS_H

#include <stdint.h>

void sd_readblock(uint16_t addr, void* buf);

#endif