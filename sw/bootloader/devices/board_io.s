.include "io.inc65"

.importzp sp, sreg

.export _sw_read
.export _led_set

.autoimport	on

.code

; @out A: The Value of the switches
; Reads the current values of the switches.
_sw_read:
        lda SW
        ldx #$0
        rts

; @in A: val
; @out A: 0 for success, 1 for failure
; Sets the LEDs
_led_set:
        sta LED
        rts