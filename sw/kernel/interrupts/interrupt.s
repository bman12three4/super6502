.MACPACK generic

.autoimport

.import _enable_irq
.import _map

.export   irq_int, nmi_int
.export _register_irq
.export _init_interrupts

.importzp ptr1, ptr2, tmp1

IRQ_CMD_ADDR    = $effc
IRQ_DAT_ADDR    = $effd

IRQ_CMD_READIRQ = $00

.segment "VECTORS"

nmi_vector:
    .res 2
rst_vector:
    .res 2
irq_vector:
    .res 2

.code

; void init_interrupts();
; remap the upper page into ram,
; then load the new vector addresses.
.proc _init_interrupts
    ; map(001f, f);
    lda #$1f
    jsr pushax
    lda #$f
    jsr _map

    lda #<irq_int
    sta irq_vector
    lda #>irq_int
    sta irq_vector + 1
    
    lda #<nmi_int
    sta nmi_vector
    lda #>nmi_int
    sta nmi_vector + 1

    ; Relocate kernel_hi into final page
    jsr copy_kernel_hi

    rts
.endproc

.proc copy_kernel_hi
        lda     #<__KERNEL_HI_LOAD__         ; Source pointer
        sta     ptr1
        lda     #>__KERNEL_HI_LOAD__
        sta     ptr1+1

        lda     #<__KERNEL_HI_RUN__          ; Target pointer
        sta     ptr2
        lda     #>__KERNEL_HI_RUN__
        sta     ptr2+1

        ldx     #<~__KERNEL_HI_SIZE__
        lda     #>~__KERNEL_HI_SIZE__        ; Use -(__DATASIZE__+1)
        sta     tmp1
        ldy     #$00

; Copy loop

@L1:    inx
        beq     @L3

@L2:    lda     (ptr1),y
        sta     (ptr2),y
        iny
        bne     @L1
        inc     ptr1+1
        inc     ptr2+1                  ; Bump pointers
        bne     @L1                     ; Branch always (hopefully)

; Bump the high counter byte

@L3:    inc     tmp1
        bne     @L2

; Done

        rts
.endproc

; void register_irq(void* addr, uint8_t irqn);
.proc _register_irq
    asl
    tax
    jsr popa
    sta irq_table,x
    jsr popa
    sta irq_table+1,x

    lda #$00
    jsr pusha
    txa
    lsr
    jsr _enable_irq
    rts
.endproc


.segment "KERNEL_HI"

.proc nmi_int
rti
.endproc


; irq_int
.proc irq_int
    ; Load IRQ number
    lda #IRQ_CMD_READIRQ
    sta IRQ_CMD_ADDR
    lda IRQ_DAT_ADDR
    ; shift by 2 (oh so only 128 interrupts are supported lol)
    asl
    tax
    jmp (irq_table,x)
    ; use that to index jump table
.endproc

.data
; interrupt handler jump table
irq_table: .res 256

