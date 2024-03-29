#include <stdint.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

#include "devices/board_io.h"
#include "devices/uart.h"
#include "devices/sd_card.h"
#include "devices/sd_print.h"

#define KERNEL_LOAD_ADDR 0xD000

//uint8_t buf[512];
uint8_t *buf = (uint8_t*)0x8000;

int main() {
    // array to hold responses
    uint8_t res[5], token;
    uint32_t addr = 0x00000000;
	uint16_t i;

	cputs("Start\n");

    // initialize sd card
    if(SD_init() != SD_SUCCESS)
    {
        cputs("Error\n");
    }
    else
    {
        cputs("Success\n");


        res[0] = SD_readSingleBlock(addr, buf, &token);
        // if no error, print buffer
        if((res[0] == 0x00) && (token == SD_START_TOKEN)) {
#ifndef RTL_SIM
            SD_printBuf(buf);
#endif
        }

        //else if error token received, print
        else if(!(token & 0xF0))
        {
            cputs("Error\n");
        } else {
            cprintf("bad token: %x\n", token);
        }

        __asm__ ("jmp (%v)", buf);
    }

    while(1) ;

}
