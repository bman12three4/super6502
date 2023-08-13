.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, sreg

.autoimport on

.feature string_escapes

.MACPACK generic

.segment "BOOTLOADER"

_start:
        lda #<str
        ldx #>str
        jsr _cputs

str: .byte "This is a very long message which would otherwise"
     .byte "take up a lot of space in the bootsector, where space"
     .byte "is at quite a premium.", $00