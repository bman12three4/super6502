; ---------------------------------------------------------------------------
; interrupt.s
; ---------------------------------------------------------------------------
;
; Interrupt handler.
;
; Checks for a BRK instruction and returns from all valid interrupts.

.import   _handle_irq
.import _cputc, _clrscr

.export   _irq_int, _nmi_int

.include "io.inc65"

.segment  "CODE"

.PC02                             ; Force 65C02 assembly mode

; ---------------------------------------------------------------------------
; Non-maskable interrupt (NMI) service routine

_nmi_int:  RTI                    ; Return from all NMI interrupts

; ---------------------------------------------------------------------------
; Maskable interrupt (IRQ) service routine

_irq_int:  PHX                    ; Save X register contents to stack
           TSX                    ; Transfer stack pointer to X
           PHA                    ; Save accumulator contents to stack
           INX                    ; Increment X so it points to the status
           INX                    ;   register value saved on the stack
           LDA $100,X             ; Load status register contents
           AND #$10               ; Isolate B status bit
           BNE break              ; If B = 1, BRK detected

; ---------------------------------------------------------------------------
; IRQ detected, return

irq:       PLA                    ; Restore accumulator contents
           PLX                    ; Restore X register contents
           jsr _handle_irq        ; Handle the IRQ
           RTI                    ; Return from all IRQ interrupts

; ---------------------------------------------------------------------------
; BRK detected, stop

break:     


bios_table:
        .addr   _console_clear
        .addr   _console_read_char
        .addr   _console_write_char


_console_clear:
        jsr _clrscr
        rti

_console_read_char:
        ; not supported
        rti

_console_write_char:
        jsr _cputc
        rti



; What functions do we need?
; UART
;   clear
;   write character
;   read character
; DISK
;   init (or should it just init on boot?)
;   read sector into memory
; FS
;   init (if disk init succeeds, should it always try?)
;   find add

; I think that is all we need for now?
; How do we call the functions?

; we have to call `brk` to trigger the interrupt
; in any of the three registers we can have arguments
; or we could have them pushed to the stack, assuming
; the stack is in the same location
; Or you could pass a pointer which points to an array
; of arguments

; for things like clear, read/write character, and init you don't
; need any arguments.

; jump table index needs to be in x, but also needs to be a multiple
; of 2.
