.MACPACK generic

.autoimport

.importzp tmp1, tmp2

.export _init_interrupt_controller
.export _enable_irq
.export _disable_irq
.export _send_eoi

IRQ_CMD_ADDR    = $effc
IRQ_DAT_ADDR    = $effd

IRQ_CMD_MASK    = $e0
IRQ_REG_MASK    = $1f
IRQ_CMD_READIRQ = $00
IRQ_CMD_ENABLE  = $20
IRQ_CMD_TYPE    = $40
IRQ_CMD_EOI     = $ff

.code

; void init_irq();
; mask all IRQs, set all type to edge.
.proc _init_interrupt_controller
    ldx #$20    ; enable
    ldy #$ff
    jsr cmd_all
    ldx #$40    ; edge type
    ldy #$00
    jsr cmd_all
    rts

cmd_all:        ; Send the same value to all 32 bytes
    txa
    add #$20
    sta tmp1
loop:
    txa
    sta IRQ_CMD_ADDR
    tya
    sta IRQ_DAT_ADDR
    inx
    cpx tmp1
    blt loop
    rts
.endproc


; void enable_irq(uint8_t type, uint8_t irqnum);
; in A: 
.proc _enable_irq
    ; Decide which byte we need to modify by dividing by 32 (>> 5)
    pha
    lsr
    lsr
    lsr
    lsr
    lsr         ; A is now bytesel
    sta tmp2    ; tmp2 is now bytesel
    add #IRQ_CMD_ENABLE
    sta IRQ_CMD_ADDR
    lda IRQ_DAT_ADDR
    sta tmp1
    pla
    and $07     ; A is now 0-7
    tax
    inx         ; X is now 1-8
    lda #$01
L1: dex
    beq L2
    asl
    bra L1  
L2: pha         ; Push bit mask to stack
    ora tmp1    ; A is now 1 << (0-7) | enable
    sta IRQ_DAT_ADDR


    lda tmp2
    add #IRQ_CMD_TYPE
    sta IRQ_CMD_ADDR
    lda IRQ_DAT_ADDR
    sta tmp1
    jsr popa    ; A is now type
    beq bit0
bit1:           ; set `bit` to 1
    pla
    ora tmp1
    bra L3
bit0:           ; set `bit` to 0
    pla
    eor #$ff
    and tmp1
L3: sta IRQ_DAT_ADDR
    rts

.endproc

.proc _disable_irq
    ; Decide which byte we need to modify by dividing by 32 (>> 5)
    pha
    lsr
    lsr
    lsr
    lsr
    lsr         ; A is now bytesel
    add #IRQ_CMD_ENABLE
    sta IRQ_CMD_ADDR
    lda IRQ_DAT_ADDR
    sta tmp1
    pla
    and $07     ; A is now 0-7
    tax
    inx         ; X is now 1-8
    lda #$01
L1: dex
    beq L2
    asl
    bra L1  
L2: eor #$ff    ; Invert to set enable to 0
    and tmp1    ; a is now ~(1 << (0-7)) & enable
    sta IRQ_DAT_ADDR
    rts
.endproc

; This should accept irqnum later.
; void send_eoi();
.proc _send_eoi
    lda #IRQ_CMD_EOI
    sta IRQ_CMD_ADDR
    lda #$1
    sta IRQ_DAT_ADDR
    rts
.endproc

