#ifndef _FS_H
#define _FS_H

#include <stdint.h>
#include <stdio.h>

#include <process/process.h>

/* syscalls for files */
size_t file_read(int8_t fd, void* buf, size_t nbytes);
size_t file_write(int8_t fd, const void* buf, size_t nbytes);
int8_t file_open(const char* filename);
int8_t file_close(int8_t fd);

/* syscalls for directories */
size_t directory_read(int8_t fd, void* buf, size_t nbytes);
size_t directory_write(int8_t fd, const void* buf, size_t nbytes);
int8_t directory_open(const char* filename);
int8_t directory_close(int8_t fd);


#endif