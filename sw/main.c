#define SEVEN_SEG 0x7ff0

#include <stdint.h>

int main() {
    uint16_t* seven_seg;
    seven_seg = (uint16_t*)SEVEN_SEG;

    *seven_seg = 0xbabe;
    return 0;
}
