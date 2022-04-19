.include "zeropage.inc"

.segment "STARTUP"

.export _init
.import _load_bootsect

_init:  ldx #$ff
        txs
        cld

        jsr _load_bootsect
        jmp $1000
        