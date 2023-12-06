#ifndef _FS_H
#define _FS_H

#include <stdint.h>

#include <process/process.h>

/* syscalls for files */
int8_t file_read(int8_t fd, void* buf, int8_t nbytes);
int8_t file_write(int8_t fd, const void* buf, int8_t nbytes);
int8_t file_open(const int8_t* filename);
int8_t file_close(int8_t fd);

/* syscalls for directories */
int8_t directory_read(int8_t fd, void* buf, int8_t nbytes);
int8_t directory_write(int8_t fd, const void* buf, int8_t nbytes);
int8_t directory_open(const int8_t* filename);
int8_t directory_close(int8_t fd);


#endif