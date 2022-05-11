#ifndef _PROCESS_H
#define _PROCESS_H

#include <stdint.h>

#define FILE_DESC_SIZE      8

#define BUF_SIZE            128

#define STDIN               0
#define STDOUT              1
#define STDERR              2

#define FILE_DESC_IN_USE    1

/* file operations struct */
typedef struct fops_t {
    int8_t (*open)(const uint8_t* filename);
    int8_t (*close)(int32_t fd);
    int8_t (*read)(int32_t fd, void* buf, int32_t nbytes);
    int8_t (*write)(int32_t fd, const void* buf, int32_t nbytes);
} fops_t;

/* file descriptors struct */
typedef struct file_desc_t {
    fops_t* file_ops;
    uint16_t entry;
    uint16_t file_pos;          // change if this becomes a problem
    uint8_t flags;
} file_desc_t;

/* Process Control Block struct */
typedef struct pcb_t {
    file_desc_t file_desc_array[FILE_DESC_SIZE];
    uint8_t args[64];
    uint16_t execute_return;
    int16_t pid;
    int16_t parent_pid;
    uint16_t parent_esp;
    uint16_t parent_ebp;
} pcb_t;


void exec(char* filename);

#endif