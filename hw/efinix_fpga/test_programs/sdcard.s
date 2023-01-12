.importzp sp, sreg, ptr1, tmp1, tmp2, tmp3, tmp4

.export _sd_card_command
.export _sd_card_resp
.export _sd_card_read_byte
.export _sd_card_wait_for_data

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
; command is in A register, the args are on the stack
; I think the order is high byte first?
_sd_card_command:
    pha

    jsr popeax
    sta SD_ARG
    stx SD_ARG+1
    lda sreg
    sta SD_ARG+2
    lda sreg+1
    sta SD_ARG+3

    pla
    sta SD_CMD
    rts

; void sd_card_resp(uint32_t* resp);
_sd_card_resp:
        phy
        sta ptr1        ; store pointer
        stx ptr1+1
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

_sd_card_read_byte:
        lda SD_DATA
        ldx #$00
        rts

_sd_card_wait_for_data:
        pha
@1:     lda SD_CMD      ; wait for status flag
        and #$02
        beq @1
        pla
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
        ldy #$9
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