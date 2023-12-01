.MACPACK generic

.autoimport

.import _enable_irq, _send_eoi, _uart_txb_block

.importzp tmp1, ptr1

.export _serial_init
.export _serial_handle_irq

.export _serial_putc, _serial_puts, _serial_getc, _serial_getc_nb

.zeropage

last_char: .res 1


.code

UART        = $efe6
UART_TXB    = UART
UART_RXB    = UART
UART_STATUS = UART + 1

; Initialize Serial Port
; No initialization needed, just register irq handler.
.proc _serial_init
        lda #<_serial_handle_irq
        ldx #>_serial_handle_irq
        jsr pushax
        lda #$01
        jsr _register_irq
        stz last_char
        rts
.endproc

; Serial Port IRQ Handler
; Get the character and store it.
.proc _serial_handle_irq
        lda UART_RXB
        ora #$80        ; set msb
        sta last_char
        jsr _send_eoi
        rti
.endproc

; Serial Port Get Character
; If a character has not been received, block until one is.
.proc _serial_getc
L1:     lda last_char
        bpl L1
        and #$7f
        sta last_char
        rts
.endproc

; Serial Port Get Character Non-Blocking
; return last character, even if it has already been read.
; If the character is new, we still clear the new flag.
.proc _serial_getc_nb
        lda last_char
        bpl L1
        and #$7f
        sta last_char
L1:     rts
.endproc


; Serial Port Put Character
; send a single character over the serial port.
.proc _serial_putc
        jsr _uart_txb_block
        cmp #$0a
        bne @1
        lda #$0d
        jsr _uart_txb_block
@1:     rts
.endproc

; Send a string over the serial port. Needs stlen
.proc _serial_puts
        sta ptr1                ; Store pointer in ptr1
        stx ptr1+1  
        ldy #$00                ; initialize y to 0
L1:     lda (ptr1),y            ; load character from string
        beq L2                  ; Quit if NULL
        jsr _serial_putc        ; send character (does not change y or ptr1)
        iny                     ; increment y
        bne L1                  ; If Y == 0, increment high byte of pointer
        inc ptr1+1
        bne L1                  ; if high byte wraps around, give up
L2:     rts
.endproc