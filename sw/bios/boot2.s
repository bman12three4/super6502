.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, sreg

.autoimport on

.feature string_escapes

.MACPACK generic

.segment "BOOTLOADER"

_start:
        lda #<str
        ldx #>str
        jsr _cputs

str: .byte "This is a very long message which would otherwise "
     .byte "take up a lot of space in the bootsector, where space "
     .byte "is at quite a premium. In fact, this string is as "
     .byte "long as all the rest of the bootloader code, presuming "
     .byte "I stretch it out long enough. It is quite remarkable "
     .byte "Just how much you can do with so few bytes. Only a couple "
     .byte "hundred are required to start up a modern computer. "
     .byte "This is, of course, not a modern computer, but I want it "
     .byte "to act like it in a way. This means using a modern "
     .byte "(well, in the sense that its from 1996 and not 1983)"
     .byte "anyway, I've exceeded 512 bytes now so good luck.", $00