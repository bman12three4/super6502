MEMORY
{
    ZP:     start = $0,    size = $100,  type = rw, define = yes;
    KSTACK: start = $200,  size = $400,  type = rw, define = yes;
    USTACK: start = $600,  size = $400,  type = rw, define = yes;
    PCB:    start = $A00,  size = $100,  type = rw, define = yes;
    KERNEL: start = $1000, size = $C000, type = rw, define = yes, file = %O;
    USER:   start = $D000, size = $1000, type = rw, define = yes;
    IO:     start = $E000, size = $1000, type = rw, define = yes;
    ROM:    start = $f000, size = $1000, type = rw, define = yes; #rw for vectors
}

SEGMENTS {
    ZEROPAGE:   load = ZP,      type = zp, define = yes; 
    STARTUP:    load = KERNEL,  type = ro;
    ONCE:       load = KERNEL,  type = ro, optional = yes;
    CODE:       load = KERNEL,  type = ro;
    RODATA:     load = KERNEL,  type = ro;
    DATA:       load = KERNEL,  type = rw, define = yes;
    BSS:        load = KERNEL,  type = rw, define = yes;
    HEAP:       load = KERNEL,  type = rw, define = yes, optional = yes;
    KERNEL_HI:  load = KERNEL,  RUN = ROM, type = rw, define = yes, optional = yes;
    VECTORS:    load = ROM,     type = ro, start    = $FFFA;
}

FILES
{
    %O: format = o65;
}

FORMATS
{
    o65: os = super, version = 0, type = small,
            export = _init;
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
    __STACKSIZE__:  value = $0200, type = weak;
    __STACKSTART__: type = weak, value = $0800;
}

