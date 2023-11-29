.MACPACK generic

.autoimport

.export _terminal_read, _terminal_write, _terminal_open, _terminal_close

.data

terminal_buf: .res 128

.code

.proc _terminal_read

.endproc

.proc _terminal_write

.endproc

; terminal_open
; open terminal device
; Inputs: uint8_t* filename
; Outputs: none
; Return Value: 0 on success
; Function: none.
.proc _terminal_open
    lda #$0
    rts
.endproc

; terminal_close
; close terminal device
; Inputs: int32_t fd
; Outputs: none
; Return Value: 0 on success (but this always failes)
; Function: none.
.proc _terminal_close
    lda #$ff    ; -1
    rts
.endproc