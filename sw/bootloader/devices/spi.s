.include "io.inc65"

.importzp zp, sreg

.export _spi_select, _spi_deselect
.export _spi_read, _spi_write, _spi_exchange

.autoimport on

.code

; void spi_select(uint8_t id)
; Select a (the) slave by pulling its CS line down
; TODO allow active high or active low CS
; TODO allow more than one slave
_spi_select:
    lda #$1         ; Ignore whatever id is, 1 is the only option
    sta SPI_CTRL
    rts

; void spi_deslect(uint8_t id)
; Deslect a slave by pulling its CS line up
; TODO allow active high or active low CS
_spi_deselect:
    stz SPI_CTRL
    rts

; uint8_t spi_read()
_spi_read:
    lda #$0
; void spi_write(uint8_t data)
_spi_write:
; uint8_t spi_exchange(uint8_t data)
_spi_exchange:
    sta SPI_OUTPUT
@1: lda SPI_CTRL
    bmi @1
    lda SPI_INPUT
    rts
