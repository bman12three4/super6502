MEMORY
{
  ZP:  start = $0,    size = $100,  type = rw, define = yes;
  KERNEL: start = $1000, size = $7000, type = rw, define = yes;
  SDRAM: start = $9000, size = $5000, type = rw, define = yes;
  BOOTSECTOR: start = $8000, size = $200, type = rw, define = yes, file = "bootloader.bin";
  BOOTLOADER: start = $8200, size = $1000, type = rw, define = yes, file = "boot2.bin";
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
    BOOTSECTOR: load = BOOTSECTOR, type = rw, start = $8000;
    BOOTLOADER: load = BOOTLOADER, type = rw;
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
