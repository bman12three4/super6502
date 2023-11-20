.MACPACK generic

.importzp tmp1

.export _init_rtc
.export _handle_rtc

RTC_CMD = $effe
RTC_DAT = $efff

RTC_THRESHOLD       = $00
RTC_INCREMENT       = $10
RTC_IRQ_THRESHOLD   = $20
RTC_OUTPUT          = $30
RTC_CONTROL         = $30

; void init_rtc(void);
; Initialize rtc and generate 50ms interrupts
.proc _init_rtc
    lda #RTC_INCREMENT+0    ; Set increment to 1
    sta RTC_CMD
    lda #$01
    sta RTC_DAT
    lda #RTC_INCREMENT+1
    sta RTC_CMD
    lda #$00
    sta RTC_DAT
    lda #RTC_INCREMENT+2
    sta RTC_CMD
    lda #$00
    sta RTC_DAT
    lda #RTC_INCREMENT+3
    sta RTC_CMD
    lda #$00
    sta RTC_DAT

    lda #RTC_THRESHOLD+0    ; Set threshold to 4000 ($fa0)
    sta RTC_CMD
    lda #$a0
    sta RTC_DAT
    lda #RTC_THRESHOLD+1
    sta RTC_CMD
    lda #$0f
    sta RTC_DAT
    lda #RTC_THRESHOLD+2
    sta RTC_CMD
    lda #$00
    sta RTC_DAT
    lda #RTC_THRESHOLD+3
    sta RTC_CMD
    lda #$00
    sta RTC_DAT

    lda #RTC_IRQ_THRESHOLD+0    ; Set irq threshold to 50 ($32)
    sta RTC_CMD
    lda #$32
    sta RTC_DAT
    lda #RTC_IRQ_THRESHOLD+1
    sta RTC_CMD
    lda #$00
    sta RTC_DAT
    lda #RTC_IRQ_THRESHOLD+2
    sta RTC_CMD
    lda #$00
    sta RTC_DAT
    lda #RTC_IRQ_THRESHOLD+3
    sta RTC_CMD
    lda #$00
    sta RTC_DAT

    lda #$30
    sta RTC_CMD
    lda #$3
    sta RTC_DAT
    
    rts

.endproc


.proc _handle_rtc
    nop
    rti
.endproc