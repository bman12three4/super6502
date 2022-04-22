MEMORY
{
  ZP:  start = $0,    size = $100,  type = rw, define = yes;
  SDRAM: start = $1000, size = $6ef0, type = rw, define = yes;
}

FILES {
    %O: format = o65;
}

SEGMENTS {
    ZEROPAGE: load = ZP,  type = zp,  define   = yes;
    DATA:     load = SDRAM, type = rw,  define   = yes, run = SDRAM;
    BSS:      load = SDRAM, type = bss, define   = yes;
    HEAP:     load = SDRAM, type = bss, optional = yes;
    STARTUP:  load = SDRAM, type = ro;
    ONCE:     load = SDRAM, type = ro,  optional = yes;
    CODE:     load = SDRAM, type = ro;
    RODATA:   load = SDRAM, type = ro;
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

FORMATS {
        o65: os = 5, version = 0, type = small,
             export = _start;
    }
