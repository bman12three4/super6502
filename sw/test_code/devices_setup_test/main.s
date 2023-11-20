.export _init, _nmi_int, _irq_int

.autoimport

.import _init_interrupt_controller
.import _init_rtc

.code

_nmi_int:
_irq_int:
    lda #$6d
    sta $00

_init:
    ldx #$ff
    txs

    jsr _init_interrupt_controller
    jsr _init_rtc

    ; enable interrupt 0
    lda #$00
    jsr pusha
    lda #$1
    jsr _enable_irq

@end:   bra @end