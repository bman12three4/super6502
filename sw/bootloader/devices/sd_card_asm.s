.export _SD_command
.export _SD_readRes1
.export _SD_readRes2
.export _SD_readRes3
.export _SD_readBytes
.export _SD_powerUpSeq
.export _res1_cmd

.importzp sp, ptr1

.autoimport on

.MACPACK generic

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

end:                            ; x will be 0 here anyway
        rts

.endproc

; void SD_readRes2(uint8_t *res)

.proc   _SD_readRes2:   near

        sta     ptr1            ; store res in ptr1
        stx     ptr1 + 1

        jsr     _SD_readRes1    ; get first response 1
        sta     (ptr1)

        lda     #$ff
        jsr     _spi_exchange   ; get final byte of response
        ldy     #$01
        sta     (ptr1),y
        jsr     incsp2
        rts

.endproc

; void SD_readBytes(uint8_t *res, uint8_t n)

.proc   _SD_readBytes:  near

        tax
        jsr     popptr1         ; store res in ptr1

read:  
        lda     #$ff            ; read data first
        jsr     _spi_exchange
        sta     (ptr1)
        inc     ptr1            ; then increment res
        bne     @L1
        inc     ptr1 + 1
@L1:    dex                     ; then decrement x
        bne     read            ; and if x is zero we are done
        rts

.endproc

; void SD_readRes3(uint8_t *res)

.proc   _SD_readRes3:   near

        sta     ptr1            ; store res in ptr1
        stx     ptr1 + 1

        jsr     _SD_readRes1    ; read respopnse 1 in R3
        cmp     #$02            ; if error reading R1, return
        bge     @L1

        inc     ptr1            ; read remaining bytes
        bne     @L2
        inc     ptr1
@L2:    lda     ptr1            ; push low byte
        sta     (sp)
        ldy     #$01
        lda     ptr1 + 1        ; push high byte
        sta     (sp),y
        lda     #$04            ; R3_BYTES
        jsr     _SD_readBytes

@L1:    rts

.endproc

; uint8_t res1_cmd(uint8_t cmd, uint32_t arg, uint8_t crc)

.proc   _res1_cmd:      near

        pha                     ; push crc to processor stack
        lda     #$ff
        jsr     _spi_exchange
        lda     #$00            ; this gets ignored anyway
        jsr     _spi_select
        lda     #$ff
        jsr     _spi_exchange

        pla
        jsr     _SD_command     ; rely on command to teardown stack

        jsr     _SD_readRes1
        tay                     ; spi doesn't touch y

        lda     #$ff
        jsr     _spi_exchange
        lda     #$00            ; this gets ignored anyway
        jsr     _spi_deselect
        lda     #$ff
        jsr     _spi_exchange

        tya
        ldx     #$00            ; Promote to integer
        rts

.endproc

; void SD_powerUpSeq(void)

.proc   _SD_powerUpSeq: near

        lda     #$00
        jsr     _spi_deselect
        jsr     _sd_delay
        lda     #$ff
        jsr     _spi_exchange
        lda     #$00
        jsr     _spi_deselect

        ldx     #$50            ; SD_INIT_CYCLES
@L1:    lda     #$ff
        jsr     _spi_exchange
        dex
        bne @L1

        rts

.endproc


; 1ms delay approx. saves no registers
.proc   _sd_delay:      near
        ldx     #$01            ; delay loop: A*X*10 + 4
@L1:    lda     #$c8            ; 1ms at 2MHz
@L2:    dec                     ; 2
        bne     @L2             ; 3
        dex                     ; 2
        bne     @L1             ; 3
        rts
.endproc