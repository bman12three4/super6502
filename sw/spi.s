.include "io.inc65"

.export _spi_write_byte

.importzp	sp, sreg, regsave, regbank
.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4

.code

SPI_SCLK = $01
SPI_SSn  = $02
SPI_MOSI = $04


;   Write a single byte to the SPI device
;   @in A The byte to write 

_spi_write_byte:
        phx                 ; Save regs
        phy
        sta tmp1            ; Save value into tmp1
        lda #$80
        tax
@loop:  bit tmp1            ; Check if high bit set
        beq @1
        lda #SPI_MOSI            ; Bit not set.
        bra @1
@1:     lda #$00            ; Bit set
        sta BB_SPI_BASE     ; Write data
        adc #SPI_SCLK
        sta BB_SPI_BASE     ; Write clock
        txa
        lsr                 ; Select next bit
        tax
        bne @loop           ; Stop when mask is 0
        lda #SPI_SSn        ; Raise Slave Select
        sta BB_SPI_BASE
        ply                 ; Restore regs
        plx
        rts                 ; Return
