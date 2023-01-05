.code

LEDS = $efff

DIVNL = $efe8
DIVNH = $efe9
DIVDL = $efea
DIVDH = $efeb

DIVQL = $efec
DIVQH = $efed
DIVRL = $efee
DIVRH = $efef

main:
    lda #$c8
    sta DIVNL
    lda #$01
    sta DIVNH
    lda #$0d
    sta DIVDL
    lda #$00
    sta DIVDH
    lda DIVQL
    sta LEDS
    wai
    bra main

.segment "VECTORS"

.addr main
.addr main
.addr main