#ifndef _O65_H
#define _O65_H

#include <stdint.h>

#define O65_NON_C64 0x0001
#define O65_MAGIC_0 0x6f
#define O65_MAGIC_1 0x36
#define O65_MAGIC_2 0x35

#define O65_OPT_FILENAME 0
#define O65_OPT_OS 1
#define O65_OPT_ASSEMBLER 2
#define O65_OPT_AUTHOR 3
#define O65_OPT_DATE 4

#define O65_OS_OSA65 1
#define O65_OS_LUNIX 2
#define O65_OS_CC65 3
#define O65_OS_OPENCBM 4
#define O65_OS_SUPER6502 5

typedef union {
    struct {
        int cpu : 1;
        int reloc : 1;
        int size : 1;
        int obj : 1;
        int simple : 1;
        int chain : 1;
        int bsszero : 1;
        int cpu2 : 4;
        int align : 2;
    };
    uint16_t _mode;
} o65_mode_t;

typedef struct {
    uint16_t c64_marker;
    uint8_t magic[3];
    uint8_t version;

    o65_mode_t mode;

    uint16_t tbase;
    uint16_t tlen;
    uint16_t dbase;
    uint16_t dlen;
    uint16_t bbase;
    uint16_t blen;
    uint16_t zbase;
    uint16_t zlen;
    uint16_t stack;

} o65_header_t;

typedef struct {
    uint8_t olen;
    uint8_t type;
    uint8_t data[1];    //This is actually variable length
} o65_opt_t;

#endif


