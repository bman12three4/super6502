.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, sreg

.autoimport on

.feature string_escapes

.MACPACK generic

_console_clear          = $0
_console_read_char      = $2
_console_write_char     = $4
_sd_readblock           = $6

buf  = $8200
addrh = $0000
addrl = $0001


.segment "BOOTSECTOR"

_start:
        jmp _main

.byte "SUPR6502"

_preamble:

.res (11+_start-_preamble)

_bpb: .res 60

_main:
        lda #<str
        ldx #>str
        jsr _cputs

        lda #<addrh
        sta sreg
        lda #>addrh
        sta sreg + 1
        lda #<addrl
        ldx #>addrl
        jsr pusheax
        lda #<buf
        ldx #>buf
        jsr pushax
        lda #<ptr1
        ldx #>ptr1
        jsr _SD_readSingleBlock
        
        lda #<buf
        ldx #>buf
        jsr _SD_printBuf

        lda #<_reserved_sect
        ldx #>_reserved_sect
	jsr pushax
	lda $800E
	ldx $800F
	jsr pushax
	ldy #$04
        jsr _cprintf


@end:   bra @end

_reserved_sect:
	.asciiz "Reserved Sectors: %x\r\n"
str: .asciiz "Hello from the bootloader!\r\n"

_end:

.res (440+_start-_end)

.res 6

.res 16
.res 16
.res 16
.res 16

.byte $55
.byte $AA

