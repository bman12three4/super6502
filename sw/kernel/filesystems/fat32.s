.MACPACK generic

.autoimport
.feature string_escapes

.importzp ptr1, sreg

.import _SD_readSingleBlock

.export _fat32_init

.export _root_cluster, _fat_start_sector, _data_start_sector
.export _fat_size, _sd_buf, _sectors_per_cluster


.data
_root_cluster: .res 4
_fat_start_sector: .res 2
_data_start_sector: .res 4
_fat_size: .res 4
_sectors_per_cluster: .res 1

_sd_buf: .res 512

data_start_sect_str: .asciiz "Data sector start: 0x%lx\n"
starting_cluster_str: .asciiz "Root cluster num: %lx\n";
value_str: .asciiz "Value: 0x%x\n"

.code

bytes_per_sector        = _sd_buf + $0B
sectors_per_cluster     = _sd_buf + $0D
reserved_sectors        = _sd_buf + $0E
fat_count               = _sd_buf + $10
sectors_per_fat         = _sd_buf + $24
root_cluster_offs       = _sd_buf + $2C

.proc _fat32_init
    ; load sector 0 into sd_buf
    lda #$00
    ldx #$00
    stz sreg
    stz sreg+1
    jsr pusheax
    lda #<_sd_buf
    ldx #>_sd_buf
    jsr pushax
    lda #<ptr1
    ldx #>ptr1
    jsr _SD_readSingleBlock

    lda sectors_per_cluster
    sta _sectors_per_cluster

    ldx #$00
L1: lda root_cluster_offs,x
    sta _root_cluster,x
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
    sta _fat_start_sector
    stz _fat_start_sector + 1

    ; multiply fat size and number of fats to get total fat size
    lda fat_count
    jsr pusha0
    lda sectors_per_fat
    ldx sectors_per_fat+1
    jsr _lmulii
    sta _fat_size
    stx _fat_size+1
    lda sreg
    sta _fat_size+2
    lda sreg+1
    sta _fat_size+3


    ; Add fat size to starting fat sector to get data start sector
    cli
    lda _fat_size
    adc _fat_start_sector
    sta _data_start_sector
    lda _fat_size+1
    adc _fat_start_sector+1
    sta _data_start_sector+1
    lda _fat_size+2
    sta _data_start_sector+2
    lda _fat_size+3
    sta _data_start_sector+3

    rts
.endproc
