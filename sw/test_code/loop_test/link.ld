MEMORY
{
    RAM: start = $0000, size = $200;
    ROM: start = $F000, size = $1000, file = %O;
}

SEGMENTS {
    ZEROPAGE: load = RAM, type = zp,  define   = yes;
    DATA:     load = ROM, type = rw,  define   = yes;
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
