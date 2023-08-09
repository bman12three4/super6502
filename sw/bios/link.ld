MEMORY
{
  ZP:  start = $0,    size = $100,  type = rw, define = yes;
  SDRAM: start = $200, size = $7e00, type = rw, define = yes;
  BOOTLOADER: start = $8000, size = $1000, type = rw, define = yes, file = "bootloader.bin";
  ROM: start = $F000, size = $1000, file = %O;
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
    VECTORS:  load = ROM, type = ro,  start    = $FFFA;
    BOOTSECTOR: load = BOOTLOADER, type = rw, start = $8000;
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
