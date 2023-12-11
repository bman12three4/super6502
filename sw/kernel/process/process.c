#include <process/process.h>
#include <devices/mapper.h>

#define USER_WINDOW 0xD0
static uint8_t* user_window = (uint8_t*)0xd000;

struct pcb fake_pcb;

// Naiive pid counter: Value is always next PID.
static int pid;

//TODO
struct pcb* get_pcb_ptr() {
    return &fake_pcb;
}

int32_t create_process(const uint8_t* command)
{
    struct pcb* user_pcb;
    // INPUT VALIDATION
    // Make sure the file exists and such.
    // Make sure file size is < 28k.

    // Load the data into main memory.

    // We have to do this one page at a time since we still need
    // to have the regular kernel code mapped.

    // As long as we have 1 page left that we can use, we can map
    // any other memory into it. Mabye $D000 to $DFFF?

    // Oh we actually had a lot more mapped for userspace at first, but
    // whatever that wouldn't have worked for this page switching
    // thing anyway.

    // We know that the PID of the new process will be `pid`, so we can
    // use the formula to calculate the memory addresses.


    // The 32 bit address is (pid + 1) * 0x10000.
    // We want the upper 20 bits, so we only multiply by 16 (16-12 = 4)
    uint16_t base = (pid + 1) << 4;

    // File starts at 0x1000
    map(base+1, USER_WINDOW);

    // loop through file, copying 4kb into the window, then increment base
    // and remap. Repeat until the file is copied into memory


    map(base, USER_WINDOW);

    // set stack pointers to zero (Where to find them?)

    // Initialize PCB;
    user_pcb = (struct pcb*)(user_window);

    // jump to `return to userspace` which will be in the upper half.

    // TODO: Write that.
    
}