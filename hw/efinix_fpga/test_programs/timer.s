.code

LEDS = $efff
TIMER_BASE = $eff8
TIMER_DIVISOR = 2
TIMER_CL = 0
TIMER_LL = 0
TIMER_CH = 1
TIMER_LH = 1
TIMER_STATUS = 3
TIMER_OLD = $10

main:
    lda #$01
    sta TIMER_BASE+TIMER_DIVISOR
    lda #$00
    sta TIMER_BASE+TIMER_LH
    lda #$0F
    sta TIMER_BASE+TIMER_LL
    lda TIMER_BASE
    sta TIMER_OLD
    stz LEDS


; load the new value of the timer in a
; subtract the old value of the timer
; if the result is greater than 30, then do something

loop:
    lda TIMER_BASE
    tax
    sec
    sbc TIMER_OLD
    sec
    sbc #$20
    bcc loop

    stx TIMER_OLD
    inc LEDS
    bra loop
    
.segment "VECTORS"

.addr main
.addr main
.addr main
