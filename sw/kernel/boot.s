; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for cc65 (Single Board Computer version)

.export   _init, _exit
.import   _main, _cputc

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import   __STACKSTART__, __STACKSIZE__       ; Linker generated

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

; ---------------------------------------------------------------------------
; Call main()
          cli
          JSR     _main

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break

_exit:    JSR     donelib              ; Run destructors
          BRK
