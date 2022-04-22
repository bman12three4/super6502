.export _handle_syscall

.import _invalid_syscall, _read, _write

_handle_syscall:
    jmp _invalid_syscall
    rts

_syscall_table:
    .addr _invalid_syscall
    .addr _read
    .addr _write