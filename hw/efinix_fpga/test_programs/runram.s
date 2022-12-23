.code

loadaddr = $1000


main:	
        ldx #(loadend-loadstart)
loadloop:
        lda loadstart,x
        sta loadaddr,x
        dex
        bpl loadloop

        jsr loadaddr

end:	bra end


loadstart:

stacktest:
		lda #$55
		pha
		lda #$00
		pla
		sta $efff
		rts

loadend:


.segment "VECTORS"

.addr main
.addr main
.addr main