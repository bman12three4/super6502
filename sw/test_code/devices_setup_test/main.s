.export _init, nmi_int, irq_int

.autoimport

.import _init_interrupt_controller
.import _init_rtc

.zeropage

finish: .res 1

.code

nmi_int:
irq_int:
    lda #$6d
    sta $00

_init:
    ldx #$ff
    txs

    LDA     #<(__STACKSTART__ + __STACKSIZE__)
    STA     sp
    LDA     #>(__STACKSTART__ + __STACKSIZE__)
    STA     sp+1

    jsr _init_interrupt_controller
    jsr _init_rtc

    ; enable interrupt 0
    lda #$00
    jsr pusha
    lda #$0
    jsr _enable_irq

    cli

@end:   bra @end