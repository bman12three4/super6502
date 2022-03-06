#include <io.h>

int io_remap(int region) {
    *(unsigned char*)IO_REMAP = region;
    return (*(unsigned char*)IO_REMAP == region);
}
