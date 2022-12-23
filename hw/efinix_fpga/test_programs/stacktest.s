.code


main:	lda #$ff
		jsr stacktest
end:	bra end



stacktest:
		lda #$55
		pha
		lda #$00
		pla
		sta $efff
		rts


.segment "VECTORS"

.addr main
.addr main
.addr main
