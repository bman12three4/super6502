.export _init, _nmi_int, _irq_int

.include  "zeropage.inc"

.autoimport

.segment  "VECTORS"

.addr      _nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      _irq_int    ; IRQ/BRK vector

SD_CONTROLLER = $e000

SD_CMD = SD_CONTROLLER
SD_ARG = SD_CONTROLLER + $4
SD_DATA = SD_ARG
SD_FIFO_0 = SD_CONTROLLER + $8
SD_FIFO_2 = SD_CONTROLLER + $C


SD_PHY = SD_CONTROLLER + $10
SD_PHY_CLKDIV = SD_PHY
SD_PHY_CLKCTRL = SD_PHY + $1
SD_PHY_SAMP_VOLT = SD_PHY + $2
SD_PHY_BLKSIZ = SD_PHY + $3



SD_DMA_BASE = SD_CONTROLLER + $28
SD_DMA_STAT_CTRL = SD_CONTROLLER + $2C

SDIOCLK_100KHZ = $FC
SPEED_512B = $09

.zeropage
rca: .res 4

.code

_nmi_int:
_irq_int:

_init:
                ldx #$ff
                txs
                cld

                lda #<(__STACKSTART__ + __STACKSIZE__)
                sta sp
                lda #>(__STACKSTART__ + __STACKSIZE__)
                sta sp+1

                stz SD_PHY_CLKCTRL
                stz SD_PHY_SAMP_VOLT
                lda #SPEED_512B
                sta SD_PHY_BLKSIZ
                lda #SDIOCLK_100KHZ
                sta SD_PHY_CLKDIV

@wait_clk:      lda SD_PHY_CLKDIV
                cmp #SDIOCLK_100KHZ
                bne @wait_clk

                ; send_goidle();
                jsr send_goidle

                ; send_r1(8, 0x1aa);
                lda #$0
                sta sreg+1
                lda #$0
                sta sreg
                ldx #$01
                lda #$aa
                jsr pusheax
                lda #$08
                jsr send_r1

@acmd41:
                ; send_r1(55, 0x00);
                lda #$0
                sta sreg+1
                lda #$0
                sta sreg
                ldx #$00
                lda #$00
                jsr pusheax
                lda #55
                jsr send_r1

                ; send_r1(41, 0x4000ff80);
                lda #$40
                sta sreg+1
                lda #$0
                sta sreg
                ldx #$ff
                lda #$80
                jsr pusheax
                lda #41
                jsr send_r1

                lda sreg+1
                bpl @acmd41

                ; cmd 11
                ; cmd 2
                ; cmd 3


@end:
                bra @end


wait_busy:      lda SD_CMD+$1
                bit #$40
                bne wait_busy
                rts


; No arguments, no response
; sends cmd0
; also clears removed and error flags?
send_goidle:
                stz SD_ARG+$3
                stz SD_ARG+$2
                stz SD_ARG+$1
                stz SD_ARG

                stz SD_CMD+$3
                lda #$04
                sta SD_CMD+$2
                lda #$80
                sta SD_CMD+$1
                lda #$40
                sta SD_CMD

                jsr wait_busy

                rts

; Command in A
; Arg on stack as 32 bits
; returns the response in eax
; (How can we signal a failure then?)
send_r1:
                pha             ; push command to stack
                jsr popeax
                PHA
                stx SD_ARG+$1
                lda sreg
                sta SD_ARG+$2
                lda sreg+1
                sta SD_ARG+$3
                pla
                sta SD_ARG      ; lsb has to be the last written.
                lda #$81        ; This also clears error flag (only for acmd41?)
                sta SD_CMD+$1
                pla
                ora #$40
                sta SD_CMD

                jsr wait_busy

                lda SD_DATA + $3
                sta sreg+1
                lda SD_DATA + $2
                sta sreg
                ldx SD_DATA + $1
                lda SD_DATA

                rts