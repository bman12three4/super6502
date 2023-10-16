.export _init, _nmi_int, _irq_int

.code

_nmi_int:
_irq_int:

_init:
    ldx #$ff
    txs

    lda #$aa
    sta $01
    lda #$bb
    sta $00
    ldy #$1
    lda #$cc
    sta ($00),y

@end:   bra @end