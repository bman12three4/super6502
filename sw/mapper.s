.include "io.inc65"

.importzp sp, sreg

.export _mapper_enable
.export _mapper_read, _mapper_write

.autoimport on

.code


; void mapper_enable(uint8_t en)
_mapper_enable:
	sta MM_CTRL
	rts

_mapper_read:
	phx
	tax
	lda MM_DATA,x
	ldx #$00
	rts

_mapper_write:
	phx
	tax
	jsr popa
	sta MM_DATA,x
	plx
	rts

