; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for cc65 (Single Board Computer version)

.export   _init, _exit
.import   _main, _cputc

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import   __STACKSTART__, __STACKSIZE__       ; Linker generated

.import   __KERNEL_HI_LOAD__, __KERNEL_HI_RUN__, __KERNEL_HI_SIZE__

.import    copydata, zerobss, initlib, donelib

.include  "zeropage.inc"

; ---------------------------------------------------------------------------
; Place the startup code in a special segment

.segment "STARTUP"

; ---------------------------------------------------------------------------
; A little light 6502 housekeeping

_init:    LDX     #$FF                 ; Initialize stack pointer to $01FF
          TXS
          CLD                          ; Clear decimal mode

; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer

          LDA     #<(__STACKSTART__ + __STACKSIZE__)
          STA     sp
          LDA     #>(__STACKSTART__ + __STACKSIZE__)
          STA     sp+1

; ---------------------------------------------------------------------------
; Initialize memory storage

          JSR     zerobss              ; Clear BSS segment (no longer fails)
        ;   JSR     copydata             ; Initialize DATA segment (this also fails. but prints something)
          JSR     initlib              ; Run constructors (This one works)
          JSR     copy_kernel_hi
; ---------------------------------------------------------------------------
; Call main()
          cli
          JSR     _main

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break

_exit:    JSR     donelib              ; Run destructors
          BRK


.proc copy_kernel_hi
        lda     #<__KERNEL_HI_LOAD__         ; Source pointer
        sta     ptr1
        lda     #>__KERNEL_HI_LOAD__
        sta     ptr1+1

        lda     #<__KERNEL_HI_RUN__          ; Target pointer
        sta     ptr2
        lda     #>__KERNEL_HI_RUN__
        sta     ptr2+1

        ldx     #<~__KERNEL_HI_SIZE__
        lda     #>~__KERNEL_HI_SIZE__        ; Use -(__DATASIZE__+1)
        sta     tmp1
        ldy     #$00

; Copy loop

@L1:    inx
        beq     @L3

@L2:    lda     (ptr1),y
        sta     (ptr2),y
        iny
        bne     @L1
        inc     ptr1+1
        inc     ptr2+1                  ; Bump pointers
        bne     @L1                     ; Branch always (hopefully)

; Bump the high counter byte

@L3:    inc     tmp1
        bne     @L2

; Done

        rts
.endproc