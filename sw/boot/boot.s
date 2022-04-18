; We need to to read the boot sector from the
; SD card, verify the last 2 bytes, then jump to the
; beginning of it.

.include "zeropage.inc"

.segment "STARTUP"

.import _load_bootsect

_init:  ldx #$ff
        txs
        cld

        jsr _load_bootsect
        jmp $1000
        