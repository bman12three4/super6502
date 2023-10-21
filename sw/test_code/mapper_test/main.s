.export _init, _nmi_int, _irq_int

.code

_nmi_int:
_irq_int:

MAPPER_BASE = $200

_init:
    ldx #$ff
    txs

    lda #$10
    sta MAPPER_BASE + 2

    ; This should store 0x55aa to memory $010000, instead of $001000

    lda #$aa
    sta $1000
    lda #$55
    sta $1001

    lda #$01
    sta MAPPER_BASE + 2

    ; This should store 0xddcc to memory $001000

    lda #$cc
    sta $1000
    lda #$dd
    sta $1001

    lda #$10
    sta MAPPER_BASE + 2

    lda $1000
    cmp #$aa
    bne @bad
    lda $1001
    cmp #$55
    bne @bad

    lda #$01
    sta MAPPER_BASE + 2

    lda $1000
    cmp #$cc
    bne @bad
    lda $1001
    cmp #$dd
    bne @bad

@end:   
    lda #$6d
    sta $00
    bra @end


@bad:
    lda #$bd
    sta $00
    bra @bad

