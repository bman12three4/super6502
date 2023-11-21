.MACPACK generic

.autoimport

.export   _irq_int, _nmi_int
.export _register_irq

IRQ_CMD_ADDR    = $effc
IRQ_DAT_ADDR    = $effd

IRQ_CMD_READIRQ = $00

.proc _nmi_int
rti
.endproc


; _irq_int
.proc _irq_int
    ; Load IRQ number
    lda #IRQ_CMD_READIRQ
    sta IRQ_CMD_ADDR
    lda IRQ_DAT_ADDR
    ; shift by 2 (oh so only 128 interrupts are supported lol)
    lsr
    tax
    jmp (irq_table,x)
    ; use that to index jump table
.endproc

; void register_irq(void* addr, uint8_t irqn);
.proc _register_irq
    tax
    jsr popa
    sta irq_table,x
    jsr popa
    sta irq_table+1,x
    rts
.endproc

.data
; interrupt handler jump table
irq_table: .res 256
