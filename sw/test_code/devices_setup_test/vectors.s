; ---------------------------------------------------------------------------
; vectors.s
; ---------------------------------------------------------------------------
;
; Defines the interrupt vector table.

.import    _init
.import    nmi_int, irq_int

.segment  "VECTORS"

.addr      nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      irq_int    ; IRQ/BRK vector