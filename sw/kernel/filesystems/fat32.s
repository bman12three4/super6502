.MACPACK generic

.autoimport
.feature string_escapes

.importzp ptr1, sreg

.import _SD_readSingleBlock

.export _fat32_init


.data
fat_start_sector: .res 2
data_start_sector: .res 2
sd_buf: .res 512

bps_val_str: .asciiz "Bytes Per Sector: 0x%x\n"
sps_val_str: .asciiz "Sectors Per Cluster: 0x%x\n"
rsv_val_str: .asciiz "Reserved Sectors: 0x%x\n"
fat_count_str: .asciiz "FAT count: 0x%x\n"
fat_sect_str: .asciiz "Sectors per FAT: 0x%x\n"
fat_size_tot_str: .asciiz "Total fat size: 0x%lx\n"
rsv_sect_bytes_str: .asciiz "Total reserved bytes: 0x%x\n"
rsv_sd_sectors: .asciiz "Reserved SD Sectors: 0x%x\n"

.code

bytes_per_sector        = sd_buf + $0B
sectors_per_cluster     = sd_buf + $0D
reserved_sectors        = sd_buf + $0E
fat_count               = sd_buf + $10
sectors_per_fat         = sd_buf + $24

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

    lda #<bps_val_str
    ldx #>bps_val_str
    jsr pushax
    lda bytes_per_sector
    ldx bytes_per_sector+1
    jsr pushax
    ldy #$4
    jsr _cprintf

    lda #<sps_val_str
    ldx #>sps_val_str
    jsr pushax
    lda sectors_per_cluster
    ldx #$00
    jsr pushax
    ldy #$4
    jsr _cprintf

    lda #<rsv_val_str
    ldx #>rsv_val_str
    jsr pushax
    lda reserved_sectors
    ldx #$00
    jsr pushax
    ldy #$4
    jsr _cprintf

    lda #<fat_count_str
    ldx #>fat_count_str
    jsr pushax
    lda fat_count
    ldx #$00
    jsr pushax
    ldy #$4
    jsr _cprintf


    lda #<rsv_sect_bytes_str
    ldx #>rsv_sect_bytes_str
    jsr pushax

    lda reserved_sectors
    jsr pusha0
    lda bytes_per_sector
    ldx bytes_per_sector+1
    jsr _imulii
    jsr pushax
    ldy #$4
    jsr _cprintf

    lda #<fat_size_tot_str
    ldx #>fat_size_tot_str
    jsr pushax

    ; multiply fat size and number of fats

    lda fat_count
    jsr pusha0
    lda sectors_per_fat
    ldx sectors_per_fat+1
    jsr _lmulii
    jsr pusheax
    ldy #$6
    jsr _cprintf

    rts
.endproc