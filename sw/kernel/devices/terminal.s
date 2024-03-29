.MACPACK generic

.autoimport

.importzp tmp1, ptr1

.import _serial_getc
.export _terminal_read, _terminal_write, _terminal_open, _terminal_close

.data

terminal_buf: .res 128

.code

; int8_t terminal_read(uint8_t fd, void* buf, uint8_t nbytes);
; Read up to size-1 (127 max) before the enter key is pressed.
; A newline character is automatically added.
; Inputs: int8_t* buf - where input characters are stored
;         uint8_t n - number of characters to read (max buf size minux 1)
; Return Value: number of characters read on success, -1 on failure
; Function: Reads keyboard input
.proc _terminal_read
        cmp #$00            ; Check that nbytes is > 0 and < 128
        beq FAIL
        cmp #$81
        bge FAIL
        sta tmp1            ; Store nbytes in tmp1
        
        jsr popax          ; Check that buf != NULL
        cmp #$00
        bne L1
        cpx #$00
        bne L1
        bra FAIL


        ; while i < nbytes, store getc into terminal_buf y
L1:     sta ptr1    
        stx ptr1+1
        ldy #$00
LOOP:   cpy tmp1
        bge END
        jsr _serial_getc
        sta terminal_buf,y

        cmp #$0d            ; If newline, do something
        bne L2
        lda #$0a            ; hacky serial, we want $0a, not $0d
        jsr _serial_putc
        bra END

L2:     cmp #$08            ; Handle backspace
        bne L3
        lda tmp1
        beq LOOP
        lda #$08
        jsr _serial_putc
        dey
        lda #$00
        sta terminal_buf,y
        bra LOOP

L3:     lda terminal_buf,y  ; Normal character
        sta (ptr1),y
        jsr _serial_putc
        iny
        bra LOOP

END:    phy                 ; Zero out terminal buffer
        ldy #$00
        lda #$00
L4:     sta terminal_buf,y
        iny
        cpy #$80
        blt L4

L5:     ply                 ; End string with NULL
        lda #$0a
        sta (ptr1),y
        iny
        cpy #$80            ; But not if we are at max
        bge L6
        lda #$00
        sta (ptr1),y

L6:     lda #$00            ; Return - on success
        rts

FAIL:   lda #$ff            ; return -1 on fail
        rts
.endproc

; int8_t terminal_write(uint8_t fd, const void* buf, uint8_t nbytes);
; write characters to the terminal
; Inputs: int8_t* buf - buffer of characters to write
;         uint8_t n - number of characters to write
; Return Value: 0 on success, -1 on failure
; Writes to screen. Only stops after n chars written.
; This seems to not care about null termination?
.proc _terminal_write
        sta tmp1            ; put nbytes in tmp1

        jsr popax           ; check that buf is not null
        cmp #$00
        bne L1
        cpx #$00
        bne L1
        bra FAIL
L1:     sta ptr1
        stx ptr1+1
        ldy #$00
LOOP:   lda (ptr1),y        ; Loop through buffer and print
        jsr _serial_putc
        iny
        cpy tmp1
        blt LOOP
        lda #$00
        rts

FAIL:   lda #$ff            ; old code didn't fail, but new code does.
        rts
.endproc

; terminal_open
; open terminal device
; Inputs: uint8_t* filename
; Outputs: none
; Return Value: 0 on success
; Function: none.
.proc _terminal_open
    lda #$0
    rts
.endproc

; terminal_close
; close terminal device
; Inputs: int32_t fd
; Outputs: none
; Return Value: 0 on success (but this always failes)
; Function: none.
.proc _terminal_close
    lda #$ff    ; -1
    rts
.endproc