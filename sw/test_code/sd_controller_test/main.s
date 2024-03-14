.export _init, _nmi_int, _irq_int

.segment  "VECTORS"

.addr      _nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      _irq_int    ; IRQ/BRK vector

SD_CONTROLLER = $e000
SD_ARG = SD_CONTROLLER + $4
SD_RESP = SD_CONTROLLER + $10
CLK_DIV = $20

.zeropage
rca: .res 4

.code

_nmi_int:
_irq_int:

_init:
        ldx #$ff
        txs

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
        jsr delay

        lda #55
        sta SD_CONTROLLER
        jsr delay
        lda #41
        sta SD_CONTROLLER
        jsr delay

@acmd41:
        lda #55
        sta SD_CONTROLLER

        jsr delay

        lda #$80
        sta SD_ARG+1
        lda #$ff
        sta SD_ARG+2
        lda #$40
        sta SD_ARG+3
        lda #41
        sta SD_CONTROLLER

        jsr delay

        lda SD_RESP+3
        bmi card_ready


        ldx #$10
@loop:  dex
        bne @loop

        bra @acmd41

card_ready:
        lda #2
        sta SD_CONTROLLER

        jsr delay

        lda #3
        sta SD_CONTROLLER

        jsr delay

        lda SD_RESP
        sta rca
        lda SD_RESP+1
        sta rca+1
        lda SD_RESP+2
        sta rca+2
        lda SD_RESP+3
        sta rca+3

        lda rca
        sta SD_ARG
        lda rca+1
        sta SD_ARG+1
        lda rca+2
        sta SD_ARG+2
        lda rca+3
        sta SD_ARG+3
        lda #7
        sta SD_CONTROLLER

        jsr delay

        lda #17
        sta SD_CONTROLLER

@end:   bra @end

delay:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rts