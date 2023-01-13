.importzp sp, sreg, ptr1, tmp1, tmp2, tmp3, tmp4

.export _sd_card_command
.export _sd_card_resp

.autoimport on

.code


SD_ARG      = $efd8
SD_CMD      = $efdc
SD_DATA     = $efdd

_resp = $10


main:
@cmd0:
        jsr stztmp              ; arg = 0
        lda #$00                ; cmd = 0
        jsr _sd_card_command
           
        nop                     ; no resp, so need to wait for cmd to finish
        lda #$18
@delay: dec
        bne @delay


@cmd8:
        lda #$aa
        sta tmp1
        inc tmp2                ; arg = 000001aa
        lda #$08                ; cmd = 8
        jsr _sd_card_command
     
        lda #<_resp
        ldx #>_resp
        jsr _sd_card_resp_timeout
 
        lda _resp
        beq @cmd8
         
end:
        wai
        bra end

stztmp:
    stz tmp1
    stz tmp2
    stz tmp3
    stz tmp4 
    rts

; Send sd card command.
; command is in A register, the args are in tmp1-4 le
_sd_card_command:
    pha                 ; store cmd
    lda tmp1            ; write args
    sta SD_ARG
    lda tmp2
    sta SD_ARG+1
    lda tmp3
    sta SD_ARG+2
    lda tmp4
    sta SD_ARG+3
    pla                 ; write cmd
    sta SD_CMD
    rts


; void sd_card_resp(uint32_t* resp);
_sd_card_resp:
        phy
        sta ptr1        ; store pointer
        stx ptr1+1
        lda #$0
        ldy #$0
        sta (ptr1),y
        iny
        sta (ptr1),y
        iny
        sta (ptr1),y
        iny
        sta (ptr1),y
@1:     lda SD_CMD      ; wait for status flag
        and #$01
        beq @1
        lda SD_ARG
        ldy #$0
        sta (ptr1),y
        lda SD_ARG+1
        iny
        sta (ptr1),y
        lda SD_ARG+2
        iny
        sta (ptr1),y
        lda SD_ARG+3
        iny
        sta (ptr1),y
        ply
        rts

    
; int sd_card_resp_timeout(uint32_t* resp);
_sd_card_resp_timeout:
        phy
        sta ptr1        ; store pointer
        stx ptr1+1
        lda #$0
        ldy #$0
        sta (ptr1),y
        iny
        sta (ptr1),y
        iny
        sta (ptr1),y
        iny
        sta (ptr1),y
        ldy #$12
@1:     dey
        beq @timeout
        lda SD_CMD      ; wait for status flag
        and #$01
        beq @1
        lda SD_ARG
        ldy #$0
        sta (ptr1),y
        lda SD_ARG+1
        iny
        sta (ptr1),y
        lda SD_ARG+2
        iny
        sta (ptr1),y
        lda SD_ARG+3
        iny
        sta (ptr1),y
        ply
        lda #$00
        ldx #$00
        rts
@timeout:
        ply
        lda #$ff
        ldx #$ff
        rts

.segment "VECTORS"

.addr main
.addr main
.addr main