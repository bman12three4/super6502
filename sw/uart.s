.include "io.inc65"

.importzp sp, sreg

.export _uart_txb, _uart_txb_block
.export _uart_rxb
.export _uart_status

.autoimport	on

.code

; @in A: byte to transmit
; Transmits a byte over the UART
_uart_txb:
        sta UART_TXB        ; Just write value, don't wait
        rts

_uart_txb_block:
        pha
        sta UART_TXB        ; Write value
@1:     lda UART_STATUS     ; Wait for status[0] to be 0
        bit #$01
        bne @1
        pla
        rts

_uart_rxb:
        lda UART_RXB        ; Read value
        ldx #$00
        rts

_uart_status:
        lda UART_STATUS
        ldx #$00
        rts
