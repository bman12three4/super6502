.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, sreg, data_start

.autoimport on

.export fatbuf

.feature string_escapes

.MACPACK generic

fatbuf                  = $A000
filebuf                 = $B000

.bss

tbase:  .res 2
tlen:   .res 2
dbase:  .res 2
dlen:   .res 2
olen:   .res 1
otype:  .res 1

filesiz: .res 1
cluster: .res 2

.zeropage

userptr:        .res 2

.segment "BOOTLOADER"

sectors_per_cluster     = $800D
reserved_sectors        = $800E
fat_count               = $8010
sectors_per_fat         = $8024

O65_NO_C65              = $00
O65_MAGIC               = $02
O65_VERSION             = $05
O65_MODE                = $06
O65_TBASE               = $08
O65_TLEN                = $0a
O65_DBASE               = $0c
O65_DLEN                = $0e
O65_BBASE               = $10
O65_BLEN                = $12
O65_ZBASE               = $14
O65_ZLEN                = $16
O65_STACK               = $18
O65_OPT_START           = $1A

_start:
        lda #<str
        ldx #>str
        jsr _cputs

        ; Read root directory entry into fatbuf
        lda data_start
        ldx data_start + 1
        jsr pushax
        stz sreg
        stz sreg+1
        jsr pusheax
        lda #<fatbuf
        ldx #>fatbuf
        jsr pushax
        lda #<ptr1
        ldx #>ptr1
        jsr _SD_readSingleBlock

        ; lda #<fatbuf
        ; ldx #>fatbuf
        ; jsr _SD_printBuf

        lda #$20       ; Start at first directory entry (first is a disk label)
        sta ptr3
        lda #>fatbuf
        sta ptr3 + 1
        ldy #$0b        ; look for attributes
@1:     lda (ptr3),y

        cmp #$0f        ; if attribute is 0xf, this is a lfn
        bne @2          ; if not an lfn, then try to read filename
@next:  clc             ; otherwise, go to the next entry (+0x20)
        lda ptr3
        adc #$20
        sta ptr3
        bcc @4
        inc ptr3 + 1
@4:     lda #<word_str
        ldx #>word_str
        jsr pushax
        lda ptr3
        ldx ptr3 + 1
        pha
        phx
        jsr pushax
        phy
        ldy #$4
        jsr _cprintf
        ply
        plx
        stx ptr3 + 1
        pla
        sta ptr3
        bra @1

@2:     ldy #11         ; ignore the attributes. Write null to make a string
        lda #$00
        sta (ptr3),y
        lda ptr3        ; store address of the filename string on the stack
        pha
        ldx ptr3 + 1
        phx
        jsr _cputs              ; print out short filenames as we read them
        lda #$0d
        jsr _cputc
        lda #$0a
        jsr _cputc
        lda #<kernel_str        ; load the string "KERNEL  O65"
        ldx #>kernel_str        
        jsr pushax
        plx                     ; then push the string we read earlier
        pla
        jsr _strcmp
        bne @next               ; if they are not equal then try next entry
        lda #<_good             ; print match if we found it
        ldx #>_good
        jsr _cputs              ; otherwise continue on

        lda #<word_str
        ldx #>word_str
        jsr pushax

        lda ptr3
        pha
        lda ptr3 + 1
        pha

        ldy #$1d                ; load file size (256)
        lda (ptr3),y
        lsr                     ; divide by 2 to get file size (512)
        sta filesiz
        jsr pusha0
        ldy #$4
        jsr _cprintf

        pla
        sta ptr3 + 1
        pla
        sta ptr3

        ldy #$1b                ; load high byte of low first cluster
        lda (ptr3),y
        tax
        dey
        lda (ptr3),y            ; load low byte of low first cluster

        sec
        sbc #$02                ; don't handle carry, assume low byte is not 0 or 1
        clc
        sta tmp1
        ldx data_start + 1      ; load x as high data start
        phx
        ldx sectors_per_cluster ; multiply cluster num (minus 2) by sectors_per_cluster
        lda #$00
@8:     adc tmp1
        dex
        bne @8
        plx
        clc
        adc data_start          ; add that to low data start
        bcc @5                  ; handle carry
        inx
@5:     sta cluster
        stx cluster + 1

        lda #<filebuf
        ldx #>filebuf
        sta userptr
        stx userptr + 1

@read_sd:
        lda cluster
        ldx cluster + 1
        stz sreg
        stz sreg+1
        jsr pusheax
        lda userptr
        ldx userptr + 1
        jsr pushax
        lda #<ptr1
        ldx #>ptr1
        jsr _SD_readSingleBlock

        ; lda userptr
        ; ldx userptr + 1
        ; jsr _SD_printBuf

        dec filesiz
        bmi @doneload
        inc cluster
        inc userptr + 1
        inc userptr + 1
        bra @read_sd

@doneload:
        ldy #O65_TBASE
        lda filebuf,y
        sta tbase
        iny
        ldx filebuf,y
        stx tbase + 1

        ldy #O65_TLEN
        lda filebuf,y
        sta tlen
        iny
        ldx filebuf,y
        stx tlen + 1


        ldy #O65_DBASE
        lda filebuf,y
        sta dbase
        iny
        ldx filebuf,y
        stx dbase + 1

        ldy #O65_DLEN
        lda filebuf,y
        sta dlen
        iny
        ldx filebuf,y
        stx dlen + 1

        ldy #O65_OPT_START
        phy
@opt_len:
        lda #<opt_str
        ldx #>opt_str
        jsr pushax
        ply
        lda filebuf,y
        beq @opt_end
        sta olen
        phy
        jsr pusha0
        ply
        iny
        lda filebuf,y
        sta otype
        phy
        jsr pusha0
        ldy #$6
        jsr _cprintf

        lda #<word_str
        ldx #>word_str
        jsr pushax

        pla
        clc
        adc olen
        dec
        dec
        pha
        bra @opt_len

@opt_end:
        iny             ; account for reading size
        phy
        lda #<opt_done
        ldx #>opt_done
        jsr pushax
        pla
        pha
        jsr pusha0
        ldy #$4
        jsr _cprintf

        clc
        pla
        ldx #>filebuf
        adc #<filebuf
        bcc @6
        inx
@6:     sta userptr
        stx userptr + 1
        lda #<word_str
        ldx #>word_str
        jsr pushax
        lda userptr
        ldx userptr + 1
        jsr pushax
        ldy #$4
        jsr _cprintf

        lda tbase
        ldx tbase + 1
        jsr pushax
        lda userptr
        ldx userptr + 1
        jsr pushax
        lda tlen
        ldx tlen + 1
        jsr _memcpy

        ; lda #<$1000
        ; ldx #>$1000
        ; jsr _SD_printBuf

        clc
        lda userptr + 1
        adc tlen + 1
        tax
        lda userptr
        adc tlen
        bcc @7
        inx
@7:     sta userptr
        stx userptr + 1
        lda #<word_str
        ldx #>word_str
        jsr pushax
        lda userptr
        ldx userptr + 1
        jsr pushax
        ldy #$4
        jsr _cprintf

        lda dbase
        ldx dbase + 1
        jsr pushax
        lda userptr
        ldx userptr + 1
        jsr pushax
        lda dlen
        ldx dlen + 1
        jsr _memcpy

        jmp $1000

@end:   bra @end


str: .asciiz "boot2\n"
kernel_str: .asciiz "KERNEL  O65"
_good: .asciiz "Found KERNEL\n"
word_str: .asciiz "Word Value: %x\n"

opt_str: .asciiz "Opt Len: %x, Opt Type: %x\n"
opt_done: .asciiz "Options done. total option length: %x\n"