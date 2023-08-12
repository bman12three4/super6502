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

        lda #<_fat_count
        ldx #>_fat_count
        jsr pushax
        lda $8010
        ldx #$0
        jsr pushax
        ldy #$04
        jsr _cprintf

        ; this is offset from bpb?

        lda #<_fat_sectors
        ldx #>_fat_sectors
        jsr pushax
        lda $8026
        sta sreg
        ldx $8027
        stx sreg + 1
        lda $8024
        ldx $8025
        jsr pusheax
        ldy #$06
        jsr _cprintf

        lda #<_reserved_sect
        ldx #>_reserved_sect
        jsr pushax
        lda $800E
        pha
        ldx $800F
        jsr pushax
        ldy #$04
        jsr _cprintf

        lda #<addrh
        sta sreg
        lda #>addrh
        sta sreg + 1
        pla
        clc
        adc #<addrl
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

        lda #<rd_word
        ldx #>rd_word
        jsr pushax

        lda buf
        ldx #$00
        jsr pushax
        ldy #$4
        jsr _cprintf

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


@end:   bra @end

_reserved_sect:
        .asciiz "Reserved Sectors: %x\r\n"
_fat_sectors:
        .asciiz "Sectors per fat: %lx\r\n"
_fat_count:
        .asciiz "Fat Count: %x\r\n"
str: .asciiz "Hello from the bootloader!\r\n"
rd_word: .asciiz "Read: %x\r\n"
_end:

.res (440+_start-_end)

.res 6

.res 16
.res 16
.res 16
.res 16

.byte $55
.byte $AA

