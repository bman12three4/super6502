#include <conio.h>

#include "sd_print.h"
#include "sd_card.h"


void SD_printBuf(uint8_t *buf)
{
    uint8_t colCount = 0;
    uint16_t i;
    for(i = 0; i < SD_BLOCK_LEN; i++)
    {
        cprintf("%2x", *buf++);
        if(colCount == 31)
        {
            cputs("\n");
            colCount = 0;
        }
        else
        {
            cputc(' ');
            colCount++;
        }
    }
    cputs("\n");
}
