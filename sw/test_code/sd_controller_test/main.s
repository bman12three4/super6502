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

SD_DMA_BASE = SD_CONTROLLER + $28
SD_DMA_STAT_CTRL = SD_CONTROLLER + $2C

.zeropage
rca: .res 4

.code

_nmi_int:
_irq_int:

_init:
        ldx #$ff
        txs

@end:   bra @end
