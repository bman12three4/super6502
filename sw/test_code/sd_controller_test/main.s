.export _init, _nmi_int, _irq_int

.segment  "VECTORS"

.addr      _nmi_int    ; NMI vector
.addr      _init       ; Reset vector
.addr      _irq_int    ; IRQ/BRK vector

SD_CONTROLLER = $e000

SD_CMD = SD_CONTROLLER
SD_ARG = SD_CONTROLLER + $4
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

                stz SD_PHY_CLKCTRL
                stz SD_PHY_SAMP_VOLT
                lda #SPEED_512B
                sta SD_PHY_BLKSIZ
                lda #SDIOCLK_100KHZ
                sta SD_PHY_CLKDIV

@wait_clk:      lda SD_PHY_CLKDIV
                cmp #SDIOCLK_100KHZ
                bne @wait_clk

                stz SD_CMD+$3
                lda #$04
                sta SD_CMD+$2
                lda #$08
                sta SD_CMD+$1
                lda #$40
                sta SD_CMD

                jsr wait_busy

                lda #$01
                sta SD_CMD+$1
                lda #$48
                sta SD_CMD

                jsr wait_busy

@end:
                bra @end


wait_busy:      lda SD_CMD+$1
                bit #$40
                bne wait_busy
                rts