.include "io.inc65"

.importzp sp, sreg

.export _hex_set_8
.export _hex_set_16
.export _hex_set_24
.export _hex_enable

.autoimport	on

.code

; @in A: idx Stack[0]: val
; @out A: 0 for success, 1 for failure.
; Sets one of the 3 pairs of hex digits.
_hex_set_8:
        phx
        cmp #$3         ; If idx >= 3 then fail
        bcc @1
        lda #$1
        rts
@1:     tax             ; Move idx into x
        jsr popa        ; put val into a
        sta SEVEN_SEG,x ; write to val
        lda #$0
        plx
        rts

; @in A/X: val
; @out A: 0 for success, 1 for failure
; Sets the low 2 pairs of hex digits
_hex_set_16:
        sta SEVEN_SEG
        stx SEVEN_SEG+1
        lda #$0
        rts

; @in A/X/sreg: val
; @out A: 0 for success, 1 for failure
; Sets the 3 pairs of hex digits for a 24 bit value
_hex_set_24:
        sta SEVEN_SEG
        stx SEVEN_SEG+1
        lda sreg
        sta SEVEN_SEG+2
        rts

; @in A: mask
; Set the mask for seven seg enables
_hex_enable:
        sta SEVEN_SEG+3
        rts