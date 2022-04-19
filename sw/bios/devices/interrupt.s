.include "io.inc65"

.export   _irq_int, _nmi_int

.importzp sreg, ptr1

.segment  "CODE"

; IRQ
_irq_int:
        jmp (irqmap,x)

_nmi_int:
        rti

irqmap:
        .addr handle_invalid
        .addr handle_sd_read

handle_invalid:
        rti

; sreg is the pointer to store the data
; a/y is the block address
; send command 17 with the block address of 00/y/a
handle_sd_read:
        sta SD_ARG          ; send command
        sty SD_ARG+1
        stz SD_ARG+2
        stz SD_ARG+3
        lda #$11
        sta SD_CMD

@1:     lda SD_CMD          ; wait for status flag
        and #$01
        beq @1

@2:     lda SD_CMD          ; wait for data
        and #$02
        beq @2

        ldy #$00
@loop:  lda SD_DATA         ; copy first 256 bytes
        sta (sreg),y
        iny
        bne @loop

        ldy #$00            ; copy second 256 bytes
        inc sreg+1
@loop2: lda SD_DATA
        sta (sreg),y
        iny
        bne @loop2

        rti