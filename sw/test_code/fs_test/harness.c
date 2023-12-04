#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define FILE_PATH "fs.fat"

uint32_t lmulii(uint16_t a, uint16_t b) {
    printf("lmulii: %x * %x = %x\n", a, b, a*b);
    return a * b;
}

uint16_t imulii(uint16_t a, uint16_t b) {
    printf("imulii: %x * %x = %x\n", a, b, a*b);
    return a * b;
}

uint8_t SD_readSingleBlock(uint32_t addr, uint8_t *buf, uint8_t *error) {
    FILE* f = fopen(FILE_PATH, "rb");
    fseek(f, addr * 512, SEEK_SET);
    fread(buf, 512, 1, f);
}
