.MACPACK generic

.autoimport
.feature string_escapes

.importzp ptr1, sreg

.import _SD_readSingleBlock

.export _fat32_init


.data
root_cluster: .res 4
fat_start_sector: .res 2
data_start_sector: .res 4
fat_size: .res 4

sd_buf: .res 512

data_start_sect_str: .asciiz "Data sector start: 0x%lx\n"
starting_cluster_str: .asciiz "Root cluster num: %lx\n";
value_str: .asciiz "Value: 0x%x\n"

.code

bytes_per_sector        = sd_buf + $0B
sectors_per_cluster     = sd_buf + $0D
reserved_sectors        = sd_buf + $0E
fat_count               = sd_buf + $10
sectors_per_fat         = sd_buf + $24
root_cluster_offs       = sd_buf + $2C

.proc _fat32_init
    ; load sector 0 into sd_buf
    lda #$00
    ldx #$00
    stz sreg
    stz sreg+1
    jsr pusheax
    lda #<sd_buf
    ldx #>sd_buf
    jsr pushax
    lda #<ptr1
    ldx #>ptr1
    jsr _SD_readSingleBlock

    ldx #$00
L1: lda root_cluster_offs,x
    sta root_cluster,x
    inx
    cpx #$4
    blt L1

    ; Multiply reserved sectors and bytes per sector, then divide by 512 to get sd sectors
    lda reserved_sectors
    jsr pusha0
    lda bytes_per_sector
    ldx bytes_per_sector+1
    jsr _imulii
    txa
    lsr
    sta fat_start_sector
    stz fat_start_sector + 1

    ; multiply fat size and number of fats to get total fat size
    lda fat_count
    jsr pusha0
    lda sectors_per_fat
    ldx sectors_per_fat+1
    jsr _lmulii
    sta fat_size
    stx fat_size+1
    lda sreg
    sta fat_size+2
    lda sreg+1
    sta fat_size+3


    ; Add fat size to starting fat sector to get data start sector
    lda fat_size
    adc fat_start_sector
    sta data_start_sector
    lda fat_size+1
    adc fat_start_sector+1
    sta data_start_sector+1
    lda fat_size+2
    sta data_start_sector+2
    lda fat_size+3
    sta data_start_sector+3

    lda #<data_start_sect_str
    ldx #>data_start_sect_str
    jsr pushax
    lda data_start_sector+2
    sta sreg
    lda data_start_sector+3
    sta sreg+1
    lda data_start_sector
    ldx data_start_sector+1
    jsr pusheax
    ldy #$6
    jsr _cprintf

    ; load sector <data_start> into sd_buf
    lda data_start_sector+2
    sta sreg
    lda data_start_sector+3
    sta sreg+1
    lda data_start_sector
    ldx data_start_sector+1
    jsr pusheax
    lda #<sd_buf
    ldx #>sd_buf
    jsr pushax
    lda #<ptr1
    ldx #>ptr1
    jsr _SD_readSingleBlock

    rts
.endproc
