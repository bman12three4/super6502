.export _init, _nmi_int, _irq_int

.code

_nmi_int:
_irq_int:

_init:
    lda #$aa
    sta $10
    lda #$55
    sta $11

    lda #$ff
    sta $12
    lda #$00
    sta $13

    lda $10
    lda $11
    lda $12
    lda $13

@1: bra @1