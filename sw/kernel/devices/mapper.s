.MACPACK generic

.autoimport

.export _init_mapper
.export _map

MAPPER_BASE = $200

.code

; void init_paging();
; This should be identity mapped at reset, but we can do it again anyway
.proc _init_mapper
    ldx #$00
L1:
    txa
    lsr
    sta MAPPER_BASE,x
    lda #$00
    sta MAPPER_BASE+1,x
    inx
    inx
    cpx #$20
    blt L1
    rts 
.endproc

; void map(uint16_t p_page, uint8_t v_page); 
.proc _map
    asl
    tax                 ; x = v_page * 2
    jsr popa            ; low byte of p_page
    sta MAPPER_BASE,x   ; write low byte to mm_low
    jsr popa            ; high byte of p_page
    sta MAPPER_BASE+1,x ; write high byte to mm_high
    rts
.endproc
