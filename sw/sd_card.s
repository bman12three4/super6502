.include "io.inc65"

.importzp sp, sreg

.export _sd_card_command

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
