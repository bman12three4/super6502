.include "io.inc65"

.importzp sp, sreg, ptr1, tmp1, tmp2, tmp3, tmp4

.export _sd_card_command
.export _sd_card_resp
.export _sd_card_wait_for_data
.export _sd_init
.export _sd_get_rca
.export _sd_select_card
.export _sd_readblock

.autoimport on

.code

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

_sd_card_wait_for_data:
        pha
@1:     lda SD_CMD      ; wait for status flag
        and #$02
        beq @1
        pla
        rts

; void sd_init();
;
_sd_init:
        stz tmp1
        stz tmp2
        stz tmp3
        stz tmp4                ; arg = 0
        lda #$00                ; cmd = 0
        jsr _sd_card_command

		nop
		nop

        lda #$aa
        sta tmp1
        inc tmp2                ; arg = 000001aa
        lda #$08                ; cmd = 8
        jsr _sd_card_command

        lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        stz tmp1
        stz tmp2                ; arg = 00000000
        lda #$37                ; cmd = 55
        jsr _sd_card_command

		lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        lda #$18
        sta tmp3
        lda #$40
        sta tmp4                ; arg = 40180000
        lda #$29                ; cmd = 41
        jsr _sd_card_command

        lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        stz tmp3
        stz tmp4
        lda #$02                ; arg = 0
        jsr _sd_card_command    ; cmd = 2

        lda #$25
@1:	dec A
        bne @1

        lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        rts

; uint16_t sd_get_rca();
;
_sd_get_rca:
        stz tmp1
        stz tmp2
        stz tmp3
        stz tmp4                ; arg = 0
        lda #$03                ; cmd = 3
        jsr _sd_card_command

        stz _resp
        stz _resp+1
        stz _resp+2
        stz _resp+3             ; resp = 0

        lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        lda _resp+2             ; return resp >> 16
        ldx _resp+3
        rts


; uint16_t sd_select_card(uint16_t rca)
;
_sd_select_card:
        stz tmp1
        stz tmp2
        sta tmp3
        stx tmp4                ; arg = rca << 16
        lda #$07                ; cmd = 7
        jsr _sd_card_command

        lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        lda _resp               ; return resp
        ldx _resp+1
        rts

; uint16_t sd_get_status(uint16_t rca)
; (this is basically the same as select card...)
_sd_get_status:
        stz tmp1
        stz tmp2
        sta tmp3
        stx tmp4                ; arg = rca << 16
        lda #$0d                ; cmd = 13
        jsr _sd_card_command

        lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        lda _resp               ; return resp
        ldx _resp+1
        rts

; void sd_readblock(uint32_t addr, void* buf)
;
_sd_readblock:
        sta ptr1                ; ptr1 = &buf      
        stx ptr1+1

        lda (sp)
        sta tmp1
        lda (sp+1)
        sta tmp2
        lda (sp+2)
        sta tmp3
        lda (sp+3)
        sta tmp4                ; arg = addr
        lda #$11                ; cmd = 17
        jsr _sd_card_command

        lda #<_resp 
        ldx #>_resp
        jsr _sd_card_resp       ; resp

        jsr _sd_card_wait_for_data

        ldy #$00
        sty tmp1                
@loop:  lda SD_DATA             ; loop 256 times
        sta (ptr1),y
        iny
        bne @loop
        lda tmp1
        bne @end                ; stop after second loop
        inc ptr1+1              ; inc high byte of ptr (+256)
        bra @loop               ; y is already zer0

@end:   jsr incsp4              ; addr was on stack
        rts

.bss
_resp:  .res 4
        