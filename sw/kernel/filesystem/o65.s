.FEATURE string_escapes

.importzp sp, ptr1, ptr2, tmp1, tmp2

.export _o65_print_option

.autoimport on

.rodata

s_opt_length:
        .asciiz "Option Length: %d\n"

s_opt_type:
        .asciiz "Option Type: %x\n"

s_format_char:
        .asciiz "%c"

s_format_hex:
        .asciiz "%x"

s_filename:
        .asciiz "Filename\n"

s_os:
        .asciiz "OS\n"

s_assembler:
        .asciiz "Assembler\n"

s_author:
        .asciiz "Author\n"

s_date:
        .asciiz "Creation Date\n"

s_invalid:
        .asciiz "Invalid\n"

types_table:
        .addr s_filename
        .addr s_os
        .addr s_assembler
        .addr s_author
        .addr s_date

.code

_o65_print_option:
        sta ptr1                    ; ptr1 = &opt
        stx ptr1+1

        lda #<(s_opt_length)
        ldx #>(s_opt_length)
        jsr pushax
        lda (ptr1)
        sta tmp1                    ; len in tmp1
        jsr pusha0
        ldy #$04
        jsr _cprintf                ; cprintf("Option Length: %d\n", opt->olen)

        lda #<(s_opt_type)
        ldx #>(s_opt_type)
        jsr pushax
        ldy #$1
        lda (ptr1),y
        sta tmp2                    ; type in tmp2
        jsr pusha0
        ldy #$4
        jsr _cprintf                ; cprintf("Option Type: %x\n", opt->type)

        ldy tmp2                    ; get type again
        cpy #$04
        bpl @badtype
        lda types_table,y
        ldx types_table+1,y
        bra @printtype
@badtype:
        lda #<(s_invalid)
        ldx #>(s_invalid)
@printtype:
        jsr pushax
        ldy #$2
        jsr _cprintf                ; print type

        ldy #$2
        lda (ptr1),y
        sta ptr2
        iny
        lda (ptr1),y
        sta ptr2+1                  ; opt->data in ptr2

        lda tmp2
        cmp #$1                     ; compare to OS
        beq @print_os

        ldy #$00
        dec tmp2
        dec tmp2                    ; compare to len-2
@charloop:
        lda #<(s_format_char)
        ldx #>(s_format_char)
        jsr pushax                  ; "%c"
        lda (ptr2),y
        jsr pusha                   ; opt->data[i]
        phy
        ldy #$3
        jsr _cprintf
        ply
        iny
        cpy tmp2
        bcc @charloop
        bra @end

@print_os:
        lda #<(s_format_hex)
        ldx #>(s_format_hex)        ; "%x"
        jsr pushax
        lda (ptr2)
        jsr pusha0                  ; opt->data[0]
        jsr _cprintf

@end:
        lda #$0a
        jsr _cputc
        jsr _cputc


    rts