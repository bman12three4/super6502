.export _init, _nmi_int, _irq_int

.segment  "VECTORS"

.addr      _nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      _irq_int    ; IRQ/BRK vector

SDRAM= $200

.code

_nmi_int:
_irq_int:

_init:
        lda #$aa
        sta $e200

@end:   bra @end