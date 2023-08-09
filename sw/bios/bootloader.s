.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3

.autoimport on

.feature string_escapes

.MACPACK generic

_console_clear          = $0
_console_read_char      = $2
_console_write_char     = $4
_sd_readblock           = $6

.segment "BOOTSECTOR"

_start:
        jmp _main

.byte "SUPR6502"

_main:
        lda #<str
        ldx #>str
        jsr _cputs
@end:   bra @end


str: .asciiz "Hello from the bootloader!\r\n"

_end:

.res (446+_start-_end)

.res 16
.res 16
.res 16
.res 16

.byte $55
.byte $AA

