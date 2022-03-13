.include "io.inc65"

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

_hex_set_16:
        lda #$1
        rts

_hex_set_24:
        lda #$1
        rts

; @in A: mask
; Set the mask for seven seg enables
_hex_enable:
        sta SEVEN_SEG+3
        rts