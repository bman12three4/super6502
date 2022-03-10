#include <stdio.h>
#include <spi.h>

int main(void)
{
    printf("Starting spi_write_byte test...\n");
    spi_write_byte(0xa5);
    printf("Done!\n");
    return 0;
}