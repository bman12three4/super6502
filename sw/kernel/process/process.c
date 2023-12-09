#include <process/process.h>


struct pcb fake_pcb;

//TODO
struct pcb* get_pcb_ptr() {
    return &fake_pcb;
}