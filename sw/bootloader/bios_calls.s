.export _sd_readblock

.autoimport

.importzp sreg

; sreg is the pointer to store the data
; a/y is the block address
; send command 17 with the block address of 00/y/a

; void sd_readblock(uint16_t addr, void* buf);

_sd_readblock:
    sta sreg        ; move buf pointer to sreg
    stx sreg+1

    jsr popax       ; move addr to a/y
    tya

    ldx #$1         ; call interrupt 1
    brk

    rts