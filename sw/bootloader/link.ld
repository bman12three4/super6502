MEMORY
{
  ZP:  start = $0,    size = $100,  type = rw, define = yes;
  BOOTSECT: start = $1000, size = $200, file = %O;
}

SEGMENTS {
    ZEROPAGE: load = ZP,  type = zp,  define   = yes;
    DATA:     load = BOOTSECT, type = rw,  define   = yes;
    BSS:      load = BOOTSECT, type = bss, define   = yes;
    HEAP:     load = BOOTSECT, type = bss, optional = yes;
    STARTUP:  load = BOOTSECT, type = ro, start = $1000;
    CODE:     load = BOOTSECT, type = ro, start = $105a;
    RODATA:   load = BOOTSECT, type = ro;
    SIGN:     load = BOOTSECT, type = ro, start = $11fe;
}

