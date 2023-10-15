.export _init, _nmi_int, _irq_int

.code

_nmi_int:
_irq_int:

_init:
    ldx #$ff
    txs
    lda #$00
    jsr subroutine
    sta $00
@1: bra @1

subroutine:
    inc
    jsr suborutine2
    rts

suborutine2:
    inc
    rts