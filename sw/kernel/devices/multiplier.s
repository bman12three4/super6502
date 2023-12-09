.include "io.inc65"

.MACPACK generic

.import popax
.importzp sreg

.export _lmulii, _imulii

.code

.proc _lmulii
    sta MULTIPLIER_BL
    stx MULTIPLIER_BH
    jsr popax
    sta MULTIPLIER_AL
    stx MULTIPLIER_AH
    lda MULTIPLIER_OHL
    sta sreg
    lda MULTIPLIER_OHH
    sta sreg+1
    lda MULTIPLIER_OLL
    ldx MULTIPLIER_OLH
    rts
.endproc

.proc _imulii
    sta MULTIPLIER_BL
    stx MULTIPLIER_BH
    jsr popax
    sta MULTIPLIER_AL
    stx MULTIPLIER_AH
    lda MULTIPLIER_OLL
    ldx MULTIPLIER_OLH
    rts
.endproc