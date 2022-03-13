#include <stdint.h>

#include "sevenseg.h"

int main() {
    //hex_enable(0xff);
    hex_set_8(0xb5, 0);
    hex_set_8(0x00, 1);
    hex_set_8(0xb0, 2);
    while(1);
    return 0;
}
