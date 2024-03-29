.code

UART_TX = $efe6
UART_RX = UART_TX
UART_STATUS = $efe7
UART_CONTROL = UART_STATUS

main:
    ldx #$00
loop:
    lda string,x
    beq end
    sta UART_TX
    inx
wait:
    lda UART_STATUS
    bit #$02
    beq loop
    bra wait

end:
    wai
    bra end



string:
    .asciiz "Hello, world!"


.segment "VECTORS"

.addr main
.addr main
.addr main