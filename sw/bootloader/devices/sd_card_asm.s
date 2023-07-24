.export _SD_command
.export _SD_readRes1

.importzp sp

.autoimport on

; void SD_command(uint8_t cmd, uint32_t arg, uint8_t crc)

; The plan: push crc to stack, load arg into tmp1 through 4

.proc   _SD_command:    near

        pha                     ; Push CRC to cpu stack
        ldy     #$04
        lda     (sp),y          ; Load CMD
        ora     #$40            ; start bit
        jsr     _spi_exchange

        dey
arg_loop:                       ; send ARG
        lda     (sp),y
        jsr     _spi_exchange      
        dey
        bpl     arg_loop

        pla                     ; Pull CRC from stack
        ora     #$01            ; stop bit
        jsr     _spi_exchange
        jsr     incsp5          ; pop all off stack
        rts

.endproc

; uint8_t SD_readRes1 (void)

.proc   _SD_readRes1:   near
; Try to read/write up to 8 times, then return value

        ldx     #$08

tryread:        
        lda     #$ff
        jsr     _spi_exchange
        cmp     #$ff
        bne     end
        dex
        bne     tryread

end:
        rts


.endproc