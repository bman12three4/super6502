.segment "VECTORS"

.addr      _nmi_int    ; NMI vector
.addr      _na         ; Reset vector (Doesn't matter, will go back to ROM)
.addr      _irq_int    ; IRQ/BRK vector

.segment "CODE"

_na:
    rti

_nmi_int:
    rti

_irq_int:
    rti
