.code

UART_TX = $efe6
UART_RX = UART_TX
UART_STATUS = $efe7
UART_CONTROL = UART_STATUS

main:
    ldx #$00
loop:
    lda UART_STATUS ; see if bit 0 is set
    bit #$01
    beq loop
    lda UART_RX     ; read rx buffer if so
    sta UART_TX     ; transmit it back again
    bra loop


.segment "VECTORS"

.addr main
.addr main
.addr main