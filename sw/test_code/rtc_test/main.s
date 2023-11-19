.MACPACK generic

.export _init, _nmi_int, _irq_int

IRQ_CMD = $effc
IRQ_DAT = $effd

RTC_CMD = $effe
RTC_DAT = $efff

.zeropage
finish: .res 1
print: .res 1
iters: .res 1

.code

_nmi_int:
_irq_int:
    lda #$30
    sta RTC_CMD
    lda RTC_DAT
    sta print

    lda iters
    inc
    cmp #$10
    bge @end
    sta iters
    rti

@end:
    lda #$6d
    sta finish

_init:
    ldx #$ff
    txs

    ; Enable irq0
    lda #$20
    sta IRQ_CMD
    lda #$01
    sta IRQ_DAT
    ; edge type
    lda #$40
    sta IRQ_CMD
    lda #$00
    sta IRQ_DAT

    ; Set increment
    lda #$10
    sta RTC_CMD
    lda #$01
    sta RTC_DAT

    ; Set Threshold
    lda #$00
    sta RTC_CMD
    lda #$07
    sta RTC_DAT

    ; Set IRQ Threshold
    lda #$20
    sta RTC_CMD
    lda #$04
    sta RTC_DAT

    lda #$30
    sta RTC_CMD
    lda #$03
    sta RTC_DAT

    stz iters

    cli

wait:
    bra wait