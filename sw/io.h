#ifndef _IO_H
#define IO_H


#define IO_REMAP 0x7f00


enum io_regions {
    io_region_de10lite = 0,
};


int io_remap(int region);

#endif
