; We need to to read the boot sector from the
; SD card, verify the last 2 bytes, then jump to the
; beginning of it.

.include "zeropage.inc"

.import _load_bootsect

.export _init, _boot

.segment "STARTUP"

_init:  jmp _boot

.segment "CODE"

_boot:  ldx #$ff
        txs
        cld

        jsr _load_bootsect
        jmp $1000

.segment "SIGN"
.byte $55
.byte $aa
