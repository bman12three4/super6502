# Syscalls and Process Creation

## Creating a Process

This is a little bit simpler than on x86 since we don't have to worry about 
process rings and such.


1. Remap the program address space to somewhere new in memory
2. Load the o65 file into memory
3. Remap page zero
4. Jump into starting address of program

We also need to save address of the instruction after the jump. If I am not 
mistaken then this would always be the same anyway. Regardless, we can get
this address by using `jsr` if we want it to be dynamic.

The hardware and software stacks are hardcoded, but we can remap page zero
into a different page (say, page 1) to make the changes to the stack pointers
and such, and then only remap it right before we jump in.

Unfortunately this means we won't be able to use a funtion call for this
since the return address would not be where we expect it.

A more detailed process then:

1. Determine the new processes PID. This will be used to determine the addresses
for where the main memory is mapped.

2. Map An area of ram for page zero. Here will will initialize the kernel
and user stack pointers, as well as place the Process Control Block.

3. Map the main program area into memory and copy data into it

4. Get the return address of the program, which is the address of the 
instruction following the `jmp`. 

5. Remap page zero

6. Immediately after that (like, the very next instruction) `jmp` to the start
of the user program. (We don't use `jsr` because that will save to the wrong
stack).

## Ending A Process

To end a process, we remap the parent processes memory, then jump back to the
address before the `jmp`, as noted before.

## Syscalls

Syscalls require the following:

1. Enter kernel space through use of software interrupt (`brk`)

2. Map in the kernel memory. The kernel is too large to always be mapped, so
we unmap it when we enter user space and remap it when we enter kernel space.

3. Jump to the specific syscall routine in the kernel and do whatever it does

4. Remap the current process memory

5. Jump back into userspace.

A note on 2: While we can't have the entire kernel mapped at all times, we must
have at least part of it so that we can handle interrupts and memory remapping.

This will be the top page in the virtual address space, aka 0xF000 to 0xFFFF.
This must be mapped anyway because it is where the hardware interrupt vectors
are located.

One thing to note about this is that the cc65 runtime will most likely not be
located there, nor do we really want it to be. Because of this, we will not
be able to have any C code, not will we be able to use the runtime in
assembly.