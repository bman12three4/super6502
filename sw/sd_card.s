.include "io.inc65"

.importzp sp, sreg, ptr1

.export _sd_card_command
.export _sd_card_resp

.autoimport on

.code

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
