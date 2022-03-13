#include <stdint.h>

#include "sevenseg.h"

int main() {
    hex_enable(0x3f);
    hex_set_24(0xabcdef);
    while(1);
    return 0;
}
