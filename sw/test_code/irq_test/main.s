.export _init, _nmi_int, _irq_int

CMD = $effc
DAT = $effd

.code

_nmi_int:
_irq_int:
    lda #$6d
    sta $00

_init:
    lda #$20
    sta CMD
    lda #$ff
    sta DAT
    lda #$40
    sta CMD
    lda #$ff
    sta DAT
    cli
@end:   bra @end