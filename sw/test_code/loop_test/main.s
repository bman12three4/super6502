.export _init, _nmi_int, _irq_int

.code

_nmi_int:
_irq_int:

_init:
    lda #$00
@1: inc 
    sta $01
    lda $01
    cmp $01
    beq @1

@end:   bra @end