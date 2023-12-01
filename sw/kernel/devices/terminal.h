#ifndef _TERMINAL_H
#define _TERMINAL_H

#include <stdint.h>

int8_t terminal_read(uint8_t fd, void* buf, uint8_t nbytes);
int8_t terminal_write(uint8_t fd, const void* buf, uint8_t nbytes);
int8_t terminal_open(const uint8_t* filename);
int8_t terminal_close(uint8_t fd);


#endif /* _TERMINAL_H */

