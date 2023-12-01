.MACPACK generic

.importzp tmp1

.import popa

.export _init_rtc
.export _handle_rtc
.export _rtc_set

RTC_CMD = $effe
RTC_DAT = $efff

RTC_THRESHOLD       = $00
RTC_INCREMENT       = $10
RTC_IRQ_THRESHOLD   = $20
RTC_OUTPUT          = $30
RTC_CONTROL         = $30

THRESHOLD_0         = $a0
THRESHOLD_1         = $0f
; THRESHOLD_1         = $00
THRESHOLD_2         = $00
THRESHOLD_3         = $00

IRQ_THRESHOLD_0     = $32
; IRQ_THRESHOLD_0     = $10
IRQ_THRESHOLD_1     = $00
IRQ_THRESHOLD_2     = $00
IRQ_THRESHOLD_3     = $00

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
    lda #THRESHOLD_0
    sta RTC_DAT
    lda #RTC_THRESHOLD+1
    sta RTC_CMD
    lda #THRESHOLD_1
    sta RTC_DAT
    lda #RTC_THRESHOLD+2
    sta RTC_CMD
    lda #THRESHOLD_2
    sta RTC_DAT
    lda #RTC_THRESHOLD+3
    sta RTC_CMD
    lda #THRESHOLD_3
    sta RTC_DAT

    lda #RTC_IRQ_THRESHOLD+0    ; Set irq threshold to 50 ($32)
    sta RTC_CMD
    lda #IRQ_THRESHOLD_0
    sta RTC_DAT
    lda #RTC_IRQ_THRESHOLD+1
    sta RTC_CMD
    lda #IRQ_THRESHOLD_1
    sta RTC_DAT
    lda #RTC_IRQ_THRESHOLD+2
    sta RTC_CMD
    lda #IRQ_THRESHOLD_2
    sta RTC_DAT
    lda #RTC_IRQ_THRESHOLD+3
    sta RTC_CMD
    lda #IRQ_THRESHOLD_3
    sta RTC_DAT

    lda #$30
    sta RTC_CMD
    lda #$3
    sta RTC_DAT
    
    rts
.endproc

; void rtc_set(uint32_t val, uint8_t idx);
.proc _rtc_set
    tay             ; move cmd to Y
    ldx #$04
L1: sty RTC_CMD     ; store cmd+idx to CMD    
    jsr popa        ; pop 1 byte of argument
    sta RTC_DAT     ; write it to data
    iny             ; increase index
    dex         
    bne L1          ; repeat 4 times
    rts
.endproc


.proc _handle_rtc
    nop
    rti
.endproc