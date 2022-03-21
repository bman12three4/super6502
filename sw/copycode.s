        .export         copycode
        .import         __RAMCODE_LOAD__, __RAMCODE_RUN__, __RAMCODE_SIZE__
        .importzp       ptr1, ptr2, tmp1


copycode:
        lda     #<__RAMCODE_LOAD__         ; Source pointer
        sta     ptr1
        lda     #>__RAMCODE_LOAD__
        sta     ptr1+1

        lda     #<__RAMCODE_RUN__          ; Target pointer
        sta     ptr2
        lda     #>__RAMCODE_RUN__
        sta     ptr2+1

        ldx     #<~__RAMCODE_SIZE__
        lda     #>~__RAMCODE_SIZE__        ; Use -(__DATASIZE__+1)
        sta     tmp1
        ldy     #$00

; Copy loop

@L1:    inx
        beq     @L3

@L2:    lda     (ptr1),y
        sta     (ptr2),y
        iny
        bne     @L1
        inc     ptr1+1
        inc     ptr2+1                  ; Bump pointers
        bne     @L1                     ; Branch always (hopefully)

; Bump the high counter byte

@L3:    inc     tmp1
        bne     @L2

; Done

        rts