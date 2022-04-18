MEMORY
{
  ZP:  start = $0,    size = $100,  type = rw, define = yes;
  SDRAM: start = $1000, size = $6ef0, type = rw, define = yes;
  ROM: start = $8000, size = $8000, fill = yes, fillval = $ff, file = %O;
}

SEGMENTS {
    ZEROPAGE: load = ZP,  type = zp,  define   = yes;
    DATA:     load = ROM, type = rw,  define   = yes, run = SDRAM;
    BSS:      load = SDRAM, type = bss, define   = yes;
    HEAP:     load = SDRAM, type = bss, optional = yes;
    STARTUP:  load = ROM, type = ro;
    ONCE:     load = ROM, type = ro,  optional = yes;
    CODE:     load = ROM, type = ro;
    RODATA:   load = ROM, type = ro;
}

