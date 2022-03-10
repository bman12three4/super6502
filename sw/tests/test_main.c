#include <stdio.h>
#include <stdint.h>

#include <spi.h>

char retval;

int main(void)
{
    printf("Setting SPI location to 0x02\n");
    *(uint8_t*)0x7ff0 = 2;
    if (!(*(uint8_t*)0x7ff0 == 2)) {
        printf("Expected 0x02 at 0x7ff0\n");
        return 1;
    }
    printf("Done!\n\n");

    printf("Starting spi_byte test...\n");
    retval = spi_byte(0xa5);
    if (retval != 0) {
        printf("Expected 0 return value from spi_byte\n");
        return 1;
    }
    printf("Done!   %x\n", retval);
    return 0;
}