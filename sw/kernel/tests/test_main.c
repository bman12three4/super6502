#include <stdio.h>

#include "devices/board_io.h"
#include "devices/uart.h"
#include "devices/interrupt.h"

int main(void)
{
    int retval = 0;

    int i;

    printf("\nStarting tests...\n\n");

    printf("Testing hex_set_8...\n");
    for (i = 0; i < 3; i++) {
        if (hex_set_8(i+1, i)) {
            printf("Failed to write to idx %d!\n", i);
            retval++;
        }
        if (*(uint8_t*)0x7ff0+i != i+1) {
            printf("Incorrect value at idx %d!\n", i);
            retval++;
        }
    }

    if (!hex_set_8(0xab, 3)) {
        printf("Writing to idx 3 should fail!\n");
        retval++;
    }
    printf("Done!\n\n");

    printf("Testing hex_set_16...\n");
    if (hex_set_16(0xabcd)){
        printf("Failed to write!\n");
    }
    if (*(uint16_t*)0x7ff0 != 0xabcd) {
        printf("Incorrect value!\n", i);
        retval++;
    }
    printf("Done!\n\n");

    printf("Testing hex_set_24...\n");
    if (hex_set_24(0xabcdef)){
        printf("Failed to write!\n");
    }
    if (*(uint16_t*)0x7ff0 != 0xcdef && *(uint8_t*)0x7ff2 != 0xab) {
        printf("Incorrect value!\n", i);
        retval++;
    }
    printf("Done!\n\n");

    printf("Testing hex_enable...\n");
    hex_enable(0xa5);
    if (*(uint8_t*)0x7ff3 != 0xa5) {
        printf("Incorrect value!\n", i);
        retval++;
    }
    printf("Done!\n\n");

    printf("Testing uart_txb_block...\n");
    *(uint8_t*)0x7ff5 = 0;
    uart_txb_block(0xa5);
    if (*(uint8_t*)0x7ff4 != 0xa5) {
        printf("Incorrect value!\n", i);
        retval++;
    }
    printf("Done!\n\n");

    printf("Testing uart_status...\n");
    *(uint8_t*)0x7ff5 = 0xa5;
    if (uart_status() != 0xa5) {
        printf("Incorrect value!\n", i);
        retval++;
    }
    printf("Done!\n\n");


    printf("Testing irq_get_status...\n");
    *(uint8_t*)0x7fff = 0xa5;
    if (irq_get_status() != 0xa5) {
        printf("Incorrect value!\n", i);
        retval++;
    }
    printf("Done!\n\n");


    return retval != 0;
}