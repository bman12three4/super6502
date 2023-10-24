.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, sreg
.exportzp data_start

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

.zeropage

data_start: .res 2


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
@a:     sta data_start
        stx data_start + 1
        jsr pushax
        stz sreg
        stz sreg+1
        jsr pusheax
        lda #<buf
        ldx #>buf
        jsr pushax
        lda #<ptr1
        ldx #>ptr1
        jsr _SD_readSingleBlock

        ; lda #<buf
        ; ldx #>buf
        ; jsr _SD_printBuf


        lda #$20       ; Start at first directory entry (first is a disk label)
        sta ptr3
        lda #>buf
        sta ptr3 + 1
        ldy #$0b        ; look for attributes
@1:     lda (ptr3),y

        cmp #$0f        ; if attribute is 0xf, this is a lfn
        bne @2          ; if not an lfn, then try to read filename
        clc             ; otherwise, go to the next entry (+0x20)
        lda ptr3
        adc #$20
        sta ptr3
        bra @1

@2:     ldy #11         ; ignore the attributes. Write null to make a string
        lda #$00
        sta (ptr3),y
        lda ptr3        ; store address of the filename string on the stack
        pha
        ldx ptr3 + 1
        phx
        lda #<_boot2_str        ; load the string "BOOT2   BIN"
        ldx #>_boot2_str
        jsr pushax
        plx                     ; then push the string we read earlier
        pla
        jsr _strcmp
        bne @fail               ; if they are not equal then fail
        lda #<_good             ; TODO: We should try the next entry
        ldx #>_good
        jsr _cputs              ; otherwise continue on


        ldy #$1b                ; load the high byte of the low first cluster
        lda (ptr3),y
        tax
        dey
        lda (ptr3),y            ; load the low byte of the low first cluster
        
        sec
        sbc #$02                ; don't handle carry, assume low byte is not 0 or 1
        ldx data_start + 1      ; load x as high data start
        asl                     ; multiply cluster num (minus 2) by 8
        asl
        asl
        clc
        adc data_start          ; add that to low data start
        bcc @3                  ; handle carry
        inx
@3:     stz sreg
        stz sreg+1
        phx
        pha



        jsr pusheax
        lda #<buf
        ldx #>buf
        jsr pushax
        lda #<ptr1
        ldx #>ptr1
        jsr _SD_readSingleBlock

        stz sreg
        stz sreg+1
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

str: .asciiz "boot\n"
_boot2_str: .asciiz "BOOT2   BIN"
_fail: .asciiz "not bootloader\n"
_good: .asciiz "found bootloader!\n"
_cluster: .asciiz "cluster: %lx\n"
_addr: .asciiz "addr: %x\n"
_end:

.res (440+_start-_end)

.res 6

.res 16
.res 16
.res 16
.res 16

.byte $55
.byte $AA

