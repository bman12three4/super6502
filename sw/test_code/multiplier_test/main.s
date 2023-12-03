.MACPACK generic

.export _init, _nmi_int, _irq_int

MULTIPLIER_BASE = $eff0

MULTIPLIER_AL = MULTIPLIER_BASE + 0
MULTIPLIER_AH = MULTIPLIER_BASE + 1
MULTIPLIER_BL = MULTIPLIER_BASE + 2
MULTIPLIER_BH = MULTIPLIER_BASE + 3

MULTIPLIER_OLL = MULTIPLIER_BASE + 4
MULTIPLIER_OLH = MULTIPLIER_BASE + 5
MULTIPLIER_OHL = MULTIPLIER_BASE + 6
MULTIPLIER_OHH = MULTIPLIER_BASE + 7

GOLDEN_OUTPUT_0 = $03
GOLDEN_OUTPUT_1 = $0a
GOLDEN_OUTPUT_2 = $08
GOLDEN_OUTPUT_3 = $00

.zeropage
finish: .res 1

.data

output: .res 4

.code

_nmi_int:
_irq_int:

_init:
    ldx #$ff
    txs

    lda #$01
    sta MULTIPLIER_AL
    lda #$02
    sta MULTIPLIER_AH

    lda #$03
    sta MULTIPLIER_BL
    lda #$04
    sta MULTIPLIER_BH

    ldx #$00
L1: lda MULTIPLIER_OLL,x
    sta output,x
    inx
    cpx #$4
    bne L1

    lda output
    cmp #GOLDEN_OUTPUT_0
    bne fail
    lda output+1
    cmp #GOLDEN_OUTPUT_1
    bne fail
    lda output+2
    cmp #GOLDEN_OUTPUT_2
    bne fail
    lda output+3
    cmp #GOLDEN_OUTPUT_3
    bne fail

    lda #$6d
    sta finish    

fail:
    lda #$bd
    sta finish