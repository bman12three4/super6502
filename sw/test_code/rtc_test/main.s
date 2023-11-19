.MACPACK generic

.export _init, _nmi_int, _irq_int

IRQ_CMD = $effc
IRQ_DAT = $effd

RTC_CMD = $effe
RTC_DAT = $efff

.zeropage
finish: .res 1

.code

_nmi_int:
_irq_int:
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
    lda #$02
    sta RTC_DAT

    cli

wait:
    bra wait