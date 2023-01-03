.code

LEDS = $efff
TIMER_BASE = $eff8
TIMER_DIVISOR = 2
TIMER_CL = 0
TIMER_LL = 0
TIMER_CH = 1
TIMER_LH = 1
TIMER_STATUS = 3
TIMER_CONTROL = 3
TIMER_OLD = $10

main:
    lda #$ff
    sta TIMER_BASE+TIMER_DIVISOR
    lda #$01
    sta TIMER_BASE+TIMER_CONTROL
    lda #$00
    sta TIMER_BASE+TIMER_LH
    lda #$10
    sta TIMER_BASE+TIMER_LL
    cli

loop:
    wai
    bra loop

irq:
    lda TIMER_BASE
    inc LEDS
    rti

    
.segment "VECTORS"

.addr main
.addr main
.addr irq
