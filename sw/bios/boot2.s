.importzp sp, ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, sreg, data_start

.autoimport on

.export fatbuf

.feature string_escapes

.MACPACK generic

fatbuf                  = $A000

.segment "BOOTLOADER"

sectors_per_cluster     = $800D
reserved_sectors        = $800E
fat_count               = $8010
sectors_per_fat         = $8024

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

        lda #<fatbuf
        ldx #>fatbuf
        jsr _SD_printBuf

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

@3:     jmp @3

; parse root directory for kernel.o65
        ; load first data cluster (we know this is root.)
        ; If kernel is not in this then we can go read the FAT
        ; later. Saves time if kernel is near beginning

        ; bootsector should still be loaded at $8000
        ; data start should still be valid




str: .asciiz "boot2\r\n"
kernel_str: .asciiz "KERNEL  O65"
_good: .asciiz "Found KERNEL"
word_str: .asciiz "Word Value: %x\r\n"