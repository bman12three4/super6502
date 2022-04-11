#ifndef _SD_CARD_H
#define _SD_CARD_H

#include <stdint.h>

void sd_card_command(uint32_t arg, uint8_t cmd);

void sd_card_resp(uint32_t* resp);

#endif