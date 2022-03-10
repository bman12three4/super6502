.include "io.inc65"

.export _spi_byte

.importzp	sp, sreg, regsave, regbank
.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4

.code

SPI_SCLK = $01
SPI_SSn  = $02
SPI_MOSI = $04
SPI_MISO = $08


;   Write a single byte to the SPI device
;   @in A The byte to write 
;   @out A The read byte

_spi_byte:
        phx                 ; Save regs
        phy
        ldy #$00
        sta tmp1            ; Save value into tmp1
        lda #$80
        tax
@loop:  bit tmp1            ; Check if high bit set
        beq @1
        lda #SPI_MOSI       ; Bit not set.
        bra @1
@1:     lda #$00            ; Bit set
        sta BB_SPI_BASE     ; Write data
        adc #SPI_SCLK
        sta BB_SPI_BASE     ; Write clock
        stz tmp2            
        lda BB_SPI_BASE     ; Check MISO value
        and #SPI_MISO
        beq @2
        inc tmp2
@2:     clc                 ; Shift previous value left
        tya                 ; Add current value
        asl
        adc tmp2
        tay                 ; Move read value back to y
        txa
        lsr                 ; Select next bit
        tax
        bne @loop           ; Stop when mask is 0
        lda #SPI_SSn        ; Raise Slave Select
        sta BB_SPI_BASE
        tya                 ; Get read value from y
        ply
        plx
        rts                 ; Return
