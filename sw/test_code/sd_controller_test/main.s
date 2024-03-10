.export _init, _nmi_int, _irq_int

.segment  "VECTORS"

.addr      _nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      _irq_int    ; IRQ/BRK vector

SD_CONTROLLER = $e000
CLK_DIV = $20

.code

_nmi_int:
_irq_int:

_init:
        lda #$08
        sta SD_CONTROLLER

@end:   bra @end