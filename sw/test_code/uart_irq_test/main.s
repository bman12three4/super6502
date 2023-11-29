.export _init, nmi_int, irq_int

.autoimport

.import _init_interrupt_controller

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

    ; enable interrupt 0
    lda #$00
    jsr pusha
    lda #$1
    jsr _enable_irq

    cli

@end:   bra @end