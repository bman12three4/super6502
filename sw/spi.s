.include "io.inc65"

.export _spi_byte
.export _spi_word

.importzp	sp, sreg, regsave, regbank
.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4

.code

SPI_SCLK = $01
SPI_SSn  = $02
SPI_MOSI = $04
SPI_MISO = $08


;   Read and write a single byte from the SPI device
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


;   Read and write 16 bits from the SPI device
;   @in AX The word to write 
;   @out AX The read word

_spi_word:
        phy
        ldy #$00
        sta tmp1            ; Save value into tmp1
        stx tmp2
        lda #$02
        sta tmp4

@byte:  lda #$80
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
        tya
        asl
        inc
        bra @3
@2:     tya                 ; Add current value
        asl
@3:     tay                 ; Move read value back to y
        txa
        lsr                 ; Select next bit
        tax
        bne @loop           ; Stop when mask is 0

        lda tmp2            ; Switch to second byte
        sta tmp1
        sty tmp3            ; Store read data in tmp3
        dec tmp4
        bne @byte

        lda #SPI_SSn        ; Raise Slave Select
        sta BB_SPI_BASE
        tya                 ; Get read value from y
        ldx tmp3
        ply
        rts                 ; Return