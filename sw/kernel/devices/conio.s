.importzp sp, sreg

.import _uart_txb_block
.import _lastchar

.export _cputc
.export gotoxy
.export _clrscr
.export _cgetc

.autoimport	on

.code

; void __fastcall__ cputc (char c);
_cputc:
        jsr _uart_txb_block
        cmp #$0a
        bne @1
        lda #$0d
        jsr _uart_txb_block
@1:     rts

; void __fastcall__ gotoxy (unsigned char x, unsigned char y);
gotoxy:
        phx
        phy
        tay                         ; Move y position to y
        lda (sp)
        tax                         ; Move x position to x
        lda #$1b
        jsr _uart_txb_block
        lda #'['
        jsr _uart_txb_block
        tya
        jsr _uart_txb_block
        lda #';'
        jsr _uart_txb_block
        txa
        jsr _uart_txb_block
        lda #'H'
        jsr _uart_txb_block
        ply
        plx
        rts

_clrscr:
        phx
        lda #$1b
        jsr _uart_txb_block
        lda #'c'
        jsr _uart_txb_block
        pla
        rts

_cgetc:
@2:     lda _lastchar
        beq @2
        stz _lastchar
        rts