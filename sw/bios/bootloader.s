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
addrl = $0000


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

        ; we need to read from data segment 0, that will be the first directory entry
        ; that has sector offset $00ef_e000

        lda #$00
        sta sreg
        lda #$00
        sta sreg+1
        lda #$f0
        ldx #$77
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


        lda #$20
        sta ptr2
        lda #$82
        sta ptr2 + 1
        ldy #$0b
@1:     lda (ptr2),y

        cmp #$0f
        bne @2
        clc
        lda ptr2
        adc #$20
        sta ptr2
        bra @1

@2:     ldy #11
        lda #$00
        sta (ptr2),y
        lda ptr2
        pha
        ldx ptr2 + 1
        phx
        lda #<_boot2_str
        ldx #>_boot2_str
        jsr pushax
        plx
        pla
        jsr _strcmp
        bne @fail
        lda #<_good
        ldx #>_good
        jsr _cputs
        bra @end

@fail:  lda #<_fail
        ldx #>_fail
        jsr _cputs

@end:   bra @end

str: .asciiz "boot\r\n"
_boot2_str: .asciiz "BOOT2   BIN"
_fail: .asciiz "not bootloader\r\n"
_good: .asciiz "found bootloader!\r\n"
_end:

.res (440+_start-_end)

.res 6

.res 16
.res 16
.res 16
.res 16

.byte $55
.byte $AA

