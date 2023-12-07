#ifndef _PROCESS_H
#define _PROCESS_H

#include <stdint.h>

#include <filesystems/fat32.h>
#include <stdio.h>

#define FILE_DESC_SIZE      8


#define IN_USE              1


struct fops {
    int8_t (*open)(const char* filename);
    int8_t (*close)(int8_t fd);
    size_t (*read)(int8_t fd, void* buf, size_t nbytes);
    size_t (*write)(int8_t fd, const void* buf, size_t nbytes);
};

struct file_desc {
    struct fops* file_ops;
    uint8_t fs_type;
    union {
        struct fat32_directory_entry f32_dentry;
    };
    uint32_t file_pos;
    uint32_t flags;
};

/* Process Control Block struct */
struct pcb {
    struct file_desc file_desc_array[FILE_DESC_SIZE];
    int32_t is_vidmapped;
    uint8_t args[128];
    uint16_t execute_return;
    uint16_t pid;
    uint16_t parent_pid;
    uint16_t parent_esp;
};


struct pcb* get_pcb_ptr();

#endif