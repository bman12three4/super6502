#ifndef _SYSCALL_H
#define _SYSCALL_H

#include <stdint.h>
#include <stdio.h>

/* required syscalls */
/* terminate a process */
int8_t halt (uint8_t status);
/* load and execute a new program */
int8_t execute (const uint8_t* command);
/* read data from keyboard, file, device, or directory */
int8_t read (int8_t fd, void* buf, size_t nbytes);
/* write to terminal or device */
int8_t write (int8_t fd, const void* buf, size_t nbytes);
/* access file system */
int8_t open (const uint8_t* filename);
/* close specified fd and make it available again */
int8_t close (int8_t fd);
/* read program's cmdl arguments into user level buffer */
int8_t getargs (uint8_t* buf, size_t nbytes);


enum syscall_list {
    SYS_HALT = 1,
    SYS_EXECUTE,
    SYS_READ,
    SYS_WRITE,
    SYS_OPEN,
    SYS_CLOSE,
    SYS_GETARGS,
    SYS_VIDMAP,
    SYS_SET_HANDLER,
    SYS_SIGRETURN,
};


#endif