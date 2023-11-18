.MACPACK generic

.export _init, _nmi_int, _irq_int

.import tmp1

CMD = $effc
DAT = $effd

.zeropage
finish: .res 1
curr_irq: .res 1

.code

_nmi_int:
_irq_int:
    ; We should have triggered interrupt 1
    stz CMD
    lda DAT
    cmp curr_irq
    bne @bad

    lda #$ff
    sta CMD
    lda #$1
    sta DAT

    inc curr_irq
    beq @good
    cli
    rti

@good:
    lda #$6d
    sta finish

@bad:
    lda #$bd
    sta finish

_init:
    ldx #$ff
    txs
    ldx #$20    ; enable
    ldy #$ff
    jsr cmd_all
    ldx #$40    ; edge type
    ldy #$00
    jsr cmd_all
    stz curr_irq
    cli
    jmp wait

cmd_all:
    txa
    add #$20
    sta tmp1
loop:
    txa
    sta CMD
    tya
    sta DAT
    inx
    cpx tmp1
    blt loop
    rts

wait:
    bra wait