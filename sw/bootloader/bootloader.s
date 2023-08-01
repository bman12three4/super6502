.segment "BOOTSECTOR"


_start:
        jmp _main

.byte "SUPR6502"

_main:
        brk

_end:

.res (446+_start-_end)

.res 16
.res 16
.res 16
.res 16

.byte $55
.byte $AA

