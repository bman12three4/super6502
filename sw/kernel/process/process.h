#ifndef _PROCESS_H
#define _PROCESS_H

#include <stdint.h>

#include <filesystems/fat32.h>

#define FILE_DESC_SIZE      8


#define IN_USE              1


struct fops {
    int8_t (*open)(const int8_t* filename);
    int8_t (*close)(int8_t fd);
    int8_t (*read)(int8_t fd, void* buf, int8_t nbytes);
    int8_t (*write)(int8_t fd, const void* buf, int8_t nbytes);
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
    uint32_t execute_return;
    int32_t pid;
    int32_t parent_pid;
    uint32_t parent_esp;
    uint32_t parent_ebp;
};


struct pcb* get_pcb_ptr();

#endif