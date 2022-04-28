.FEATURE string_escapes

.importzp ptr1, regbank

.export _o65_print_option

.autoimport on

; debug only!
;_cprintf = _printf
;_cputc = _putchar

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
        sta ptr1
        stx ptr1+1                  ; temporary

        lda regbank
        pha
        lda regbank+1
        pha
        lda regbank+2
        pha
        lda regbank+3
        pha                         ; push regbank on stack

        lda ptr1
        sta regbank
        lda ptr1+1
        stx regbank+1               ; regbank[0:1] is &opt

        lda #<(s_opt_length)
        ldx #>(s_opt_length)
        jsr pushax
        ldy #$0
        lda (regbank),y

        sta regbank+2               ; len in regbank[2]
        jsr pusha0
        ldy #$04
        jsr _cprintf                ; cprintf("Option Length: %d\n", opt->olen)

        lda #<(s_opt_type)
        ldx #>(s_opt_type)
        jsr pushax
        ldy #$1
        lda (regbank),y
        sta regbank+3               ; type in regbank[3]
        jsr pusha0
        ldy #$4
        jsr _cprintf                ; cprintf("Option Type: %x\n", opt->type)

        lda regbank+3               ; get type again
        cmp #$05
        bcs @badtype
        asl
        tay
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

        inc regbank                 ; (overflow??)
        inc regbank                 ; opt->data in regbank

        lda regbank+3
        cmp #$1                     ; compare to OS
        beq @print_os

        ldy #$00
        phy
        dec regbank+2
        dec regbank+2               ; compare to len-2
@charloop:
        lda #<(s_format_char)
        ldx #>(s_format_char)
        jsr pushax                  ; "%c"
        ply
        lda (regbank),y
        phy
        jsr pusha0                   ; opt->data[i]
        ldy #$4
        jsr _cprintf
        ply
        iny
        cpy regbank+2
        phy
        bmi @charloop
        ply
        bra @end

@print_os:
        lda #<(s_format_hex)
        ldx #>(s_format_hex)        ; "%x"
        jsr pushax
        lda (regbank)
        jsr pusha0                  ; opt->data[0]
        ldy #$4
        jsr _cprintf

@end:   lda #$0a
        jsr _cputc
        jsr _cputc

        pla
        sta regbank+3
        pla
        sta regbank+2
        pla
        sta regbank+1
        pla
        sta regbank

        rts