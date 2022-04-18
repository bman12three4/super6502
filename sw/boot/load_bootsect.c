#include <stdint.h>

#include "devices/sd_card.h"

#define BOOTSECTOR_LOAD_ADDRESS 0x1000

#define BOOTSIG_0 0x55
#define BOOTSIG_1 0xaa

//Should probably do this in asm
void load_bootsect() {
    uint32_t rca;
    uint8_t sig[2];
    
    sd_init();
	rca = sd_get_rca();
	sd_select_card(rca);

    sd_readblock(0, (uint8_t*)BOOTSECTOR_LOAD_ADDRESS);

    sig[0] = ((uint8_t*)BOOTSECTOR_LOAD_ADDRESS)[510];
    sig[1] = ((uint8_t*)BOOTSECTOR_LOAD_ADDRESS)[511];

    if (sig[0] != BOOTSIG_0 || sig[1] != BOOTSIG_1) {
        for(;;);    //maybe figure out a way to have an error message here
    }

    return;
}