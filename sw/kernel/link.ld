MEMORY
{
  ZP:  start = $0,    size = $100,  type = rw, define = yes;
  SDRAM: start = $200, size = $7cf0, type = rw, define = yes;
  ROM: start = $D000, size = $3000, type = rw, define = yes;
}

FILES {
    %O: format = bin;
}

SEGMENTS {
    ZEROPAGE: load = ZP,  type = zp,  define   = yes;
    DATA:     load = SDRAM, type = rw,  define   = yes;
    BSS:      load = SDRAM, type = bss, define   = yes;
    HEAP:     load = SDRAM, type = bss, optional = yes;
    STARTUP:  load = ROM, type = ro;
    ONCE:     load = ROM, type = ro,  optional = yes;
    CODE:     load = ROM, type = ro;
    RODATA:   load = ROM, type = ro;
    VECTORS:  load = ROM, type = ro,  start    = $FFFA;
}

FEATURES {
    CONDES:    segment = STARTUP,
               type    = constructor,
               label   = __CONSTRUCTOR_TABLE__,
               count   = __CONSTRUCTOR_COUNT__;
    CONDES:    segment = STARTUP,
               type    = destructor,
               label   = __DESTRUCTOR_TABLE__,
               count   = __DESTRUCTOR_COUNT__;
}

SYMBOLS {
    # Define the stack size for the application
    __STACKSIZE__:  value = $0200, type = weak;
    __STACKSTART__: type = weak, value = $0800; # 2k stack
}
