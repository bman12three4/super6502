; ---------------------------------------------------------------------------
; interrupt.s
; ---------------------------------------------------------------------------
;
; Interrupt handler.
;
; Checks for a BRK instruction and returns from all valid interrupts.

.export   _irq_int, _nmi_int


IRQ_VECTOR = $220
NMI_VECTOR = $222

.segment  "CODE"

.PC02                             ; Force 65C02 assembly mode

; ---------------------------------------------------------------------------
; Non-maskable interrupt (NMI) service routine

_nmi_int:  jmp (NMI_VECTOR)

; ---------------------------------------------------------------------------
; Maskable interrupt (IRQ) service routine

_irq_int:  jmp (IRQ_VECTOR)