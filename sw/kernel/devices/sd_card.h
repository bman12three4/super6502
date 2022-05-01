#ifndef _SD_CARD_H
#define _SD_CARD_H

#include <stdint.h>

uint16_t sd_init();
uint16_t sd_select_card(uint16_t rca);
uint16_t sd_get_status(uint16_t rca);
void sd_readblock(uint32_t addr, void* buf);

void sd_card_command(uint32_t arg, uint8_t cmd);

void sd_card_resp(uint32_t* resp);
uint8_t sd_card_read_byte();
void sd_card_wait_for_data();

#endif
