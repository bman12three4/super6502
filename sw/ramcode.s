.import _uart_txb_block

.export ram_main

.segment "RAMCODE"

ram_main:
        pha
        phx
        ldx #$0
@loop:  lda string,x
        beq @end
        jsr _uart_txb_block
        inx
        bra @loop
@end:   bra @end
        plx
        pla
        rts

string:
.asciiz "This code is running from RAM!"