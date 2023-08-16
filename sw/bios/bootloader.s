.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, sreg

.autoimport on

.feature string_escapes

.MACPACK generic
.MACPACK longbranch

_console_clear          = $0
_console_read_char      = $2
_console_write_char     = $4
_sd_readblock           = $6

sectors_per_cluster     = $800D
reserved_sectors        = $800E
fat_count               = $8010
sectors_per_fat         = $8024

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

        lda #<_addr
        ldx #>_addr
        jsr pushax

        lda fat_count
        cmp #$2
        jne @fail
        lda sectors_per_fat
        asl
        pha
        lda sectors_per_fat + 1
        rol
        tax
        pla
        adc reserved_sectors
        bcc @a
        inx
@a:     jsr pushax
        stz sreg
        stz sreg+1
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
        sta ptr3
        lda #$82
        sta ptr3 + 1
        ldy #$0b
@1:     lda (ptr3),y

        cmp #$0f
        bne @2
        clc
        lda ptr3
        adc #$20
        sta ptr3
        bra @1

@2:     ldy #11
        lda #$00
        sta (ptr3),y
        lda ptr3
        pha
        ldx ptr3 + 1
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



        ldy #$1b
        lda (ptr3),y
        tax
        dey
        lda (ptr3),y
        sec
        sbc #$02                ; don't handle carry, assume <256
        ; now a is the cluster num minus 2. We need to multiply this by
        ; 8 and add it to 0x77f0
        ; multiply by 8 is asl3
        ldx #$77
        asl
        asl
        asl
        clc
        adc #$f0
        bcc @3
        inx
@3:     pha
        phx

        lda #$00
        sta sreg
        lda #$00
        sta sreg+1
        plx
        pla
        phx
        pha
        jsr pusheax
        lda #<buf
        ldx #>buf
        jsr pushax
        lda #<ptr1
        ldx #>ptr1
        jsr _SD_readSingleBlock

        lda #$00
        sta sreg
        lda #$00
        sta sreg+1
        pla
        plx
        inc
        jsr pusheax
        lda #<buf
        ldx #>buf
        inx
        inx
        jsr pushax
        lda #<ptr1
        ldx #>ptr1
        jsr _SD_readSingleBlock


        jmp buf

        bra @end
        
; Now we have the cluster number of the bootloader (3)
; this means we need to read from address 00ef_e000 + ((3 -2) * 8 * 512)

; 00eff000 is the address we want, which is efe000 + 4096


@fail:  lda #<_fail
        ldx #>_fail
        jsr _cputs

@end:   bra @end

str: .asciiz "boot\r\n"
_boot2_str: .asciiz "BOOT2   BIN"
_fail: .asciiz "not bootloader\r\n"
_good: .asciiz "found bootloader!\r\n"
_cluster: .asciiz "cluster: %lx\r\n"
_addr: .asciiz "addr: %x\r\n"
_end:

.res (440+_start-_end)

.res 6

.res 16
.res 16
.res 16
.res 16

.byte $55
.byte $AA

