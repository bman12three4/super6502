#include <devices/sd_card.h>
#include <process/process.h>
#include <conio.h>
#include <stdint.h>
#include <string.h>

#include "fat32.h"
#include "fs.h"

static struct fops fat32_file_ops = {fat32_file_open, fat32_file_close, fat32_file_read, fat32_file_write};

int8_t fd_val;


//TODO
size_t fat32_file_write(int8_t fd, const void* buf, size_t nbytes) {
    (void)fd;
    (void)buf;
    (void)nbytes;
    return -1;
}

int8_t fat32_file_close(int8_t fd) {
    (void)fd;
    return -1;
}

int8_t fat32_file_open(const char* filename) {
    int8_t ret;
    int8_t i;
    int8_t fd;

    struct fat32_directory_entry dentry;

    struct pcb* pcb = get_pcb_ptr();

    ret = fat32_get_cluster_by_name(filename, &dentry);
    if (ret) {
        cprintf("Error finding cluster for filename");
        return -1;
    }

    /* try to find an empty file desciptor, fail otherwise */
    //TODO We start at 3 here because 0, 1, 2 will be reserved later
    for (i = 3; i < FILE_DESC_SIZE; i++) {
        if (pcb->file_desc_array[i].flags == !IN_USE) {
            fd = i;
            break;
        }
    }
    if (fd == -1){
        return -1;
    }

    /* add process */
    pcb->file_desc_array[fd].f32_dentry = dentry;
    pcb->file_desc_array[fd].flags = IN_USE;
    pcb->file_desc_array[fd].file_pos = 0;

    pcb->file_desc_array[fd].file_ops = &fat32_file_ops;

    return fd;
}

size_t fat32_file_read(int8_t fd, void* buf, size_t nbytes) {
    uint16_t i;
    uint8_t error;
    size_t offset;
    size_t leftover_length;
    size_t bytes_read = 0;
    size_t clusters;
    struct pcb* pcb = get_pcb_ptr();
    struct file_desc* fdesc = &pcb->file_desc_array[fd];
    uint32_t cluster_seq = fdesc->file_pos >> 9;
    uint32_t cluster = ((uint32_t)fdesc->f32_dentry.cluster_high << 16) | fdesc->f32_dentry.cluster_low;

    /* validate starting position isn't past end of file */
    if (fdesc->file_pos >= fdesc->f32_dentry.file_size){
        return 0;
    }
    /* validate final pos isn't past end of file */
    if (fdesc->file_pos+nbytes > fdesc->f32_dentry.file_size){ 
        nbytes = fdesc->f32_dentry.file_size - fdesc->file_pos;
    }


    for (i = 0; i < cluster_seq; i++) {
        cluster = fat32_next_cluster(cluster);
    }

    // This is an upper bound. It is possible that a 512 chunk can span
    // 2 clusters, but the first one will already be handled.
    clusters = nbytes >> 9;


    /* Handle first unaligned block */
    offset = fdesc->file_pos % 512;
    leftover_length = 512 - offset;

    if (leftover_length != 0) {
        if (nbytes <= leftover_length) {
            fat32_read_cluster(cluster, sd_buf);
            memcpy(buf, sd_buf + offset, nbytes);
            bytes_read += nbytes;
            fdesc->file_pos += bytes_read;
            return bytes_read;
        } else {
            fat32_read_cluster(cluster, sd_buf);
            memcpy(buf, sd_buf + offset, leftover_length);
            bytes_read += leftover_length;
            fdesc->file_pos += bytes_read;
        }
    }


    /* Handle middle aligned blocks */
    for (i = 0; i < clusters; i++) {
        cluster = fat32_next_cluster(cluster);
        if (cluster >= 0xffffff00) {
            // cprintf("Last cluster in file!\n");
        }

        if (nbytes - bytes_read > 512) {
            leftover_length = 512;
        } else {
            leftover_length = nbytes - bytes_read;
        }

        fat32_read_cluster(cluster, sd_buf);
        memcpy((uint8_t*)buf+bytes_read, sd_buf, leftover_length);
        bytes_read += leftover_length;
        fdesc->file_pos += bytes_read;
        if (bytes_read == nbytes) {
            return bytes_read;
        }
    }

    return bytes_read;
}

int8_t fat32_read_cluster(uint32_t cluster, void* buf) {
    uint8_t error;
    uint32_t addr = (cluster - 2) + data_start_sector;
    SD_readSingleBlock(addr, buf, &error);
    return error;
}

// This will not handle clusters numbers that leaves a sector
uint32_t fat32_next_cluster(uint32_t cluster) {
    uint8_t error;
    uint32_t addr = fat_start_sector;
    uint32_t cluster_val;
    SD_readSingleBlock(addr, sd_buf, &error);
    cluster_val = ((uint32_t*)sd_buf)[cluster];
    return cluster_val;
}

int8_t fat32_get_cluster_by_name(const char* name, struct fat32_directory_entry* dentry) {
    struct fat32_directory_entry* local_entry;
    int i = 0;

    uint32_t cluster;

    cluster = fat32_next_cluster(root_cluster);

    cprintf("Sectors per cluster: %hhx\n", sectors_per_cluster);

    fat32_read_cluster(root_cluster, sd_buf);
    for (i = 0; i < 16; i++){
        local_entry = (struct fat32_directory_entry*)(sd_buf + i*32);
        if (local_entry->attr1 == 0xf || local_entry->attr1 & 0x8 || !local_entry->attr1) {
            continue;
        }
        cprintf("Name: %.11s\n", local_entry->file_name, local_entry->file_ext);
        if (!strncmp(local_entry->file_name, name, 11)) {
            i = -1;
            break;
        }
    }
    if (i != -1) {
        cprintf("Failed to find file.\n");
        return -1;
    }

    cprintf("Found file!\n");
    memcpy(dentry, local_entry, 32);
    return 0;
}
