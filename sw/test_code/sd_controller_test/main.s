.export _init, _nmi_int, _irq_int

.segment  "VECTORS"

.addr      _nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      _irq_int    ; IRQ/BRK vector

SD_CONTROLLER = $e000
SD_ARG = SD_CONTROLLER + $4
CLK_DIV = $20

.code

_nmi_int:
_irq_int:

_init:
        lda #$00
        sta SD_CONTROLLER

        lda #$aa
        sta SD_ARG
        lda #$01
        sta SD_ARG+1
        lda #$00
        sta SD_ARG+2
        sta SD_ARG+3
        lda #$08
        sta SD_CONTROLLER

@end:   bra @end