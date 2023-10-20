.export _init, _nmi_int, _irq_int

.code

_nmi_int:
_irq_int:

MAPPER_BASE = $200

_init:
    ldx #$ff
    txs

    lda #$10
    sta MAPPER_BASE + 2

    lda #$aa
    sta $1000
    lda #$55
    sta $1001


@end:   bra @end