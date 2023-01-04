.code

LEDS = $efff
MULTAL = $eff0
MULTAH = $eff1
MULTBL = $eff2
MULTBH = $eff3

MULTPLL = $eff4
MULTPLH = $eff5
MULTPHL = $eff6
MULTPHH = $eff7

main:
    lda #$7b
    sta MULTAL
    lda #$00
    sta MULTAH
    lda #$c8
    sta MULTBL
    lda #$01
    sta MULTBH
    lda MULTPLH
    sta LEDS
    wai
    bra main

.segment "VECTORS"

.addr main
.addr main
.addr main