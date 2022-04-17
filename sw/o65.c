#include <conio.h>

#include "o65.h"

void o65_print_option(o65_opt_t* opt) {
    int i;

    cprintf("Option Length: %d\n", opt->olen);
    cprintf("Option Type: %x ", opt->type);

    switch (opt->type) {
        case O65_OPT_FILENAME: cprintf("Filename\n"); break;
        case O65_OPT_OS: cprintf("OS\n"); break;
        case O65_OPT_ASSEMBLER: cprintf("Assembler\n"); break;
        case O65_OPT_AUTHOR: cprintf("Author\n"); break;
        case O65_OPT_DATE: cprintf("Creation Date\n"); break;
        default: cprintf("Invalid\n"); break;
    }

    if (opt->type != O65_OPT_OS) {
        for (i = 0; i < opt->olen - 2; i++) {
            cprintf("%c", opt->data[i]);
        }
    } else {
        cprintf("%x", opt->data[0]);
    }
    cprintf("\n\n");
}