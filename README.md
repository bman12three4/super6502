# Super6502

## Overview

Super6502 is a microcomputer system powered by a 65C02 CPU. The goal of this
project is to create a computer system with modern features and the ability to
run modern software on an unmodified 65C02 core. While the project is almost
entirely contained in an FPGA, this rule is enforced by using an off the shelf
CPU.

## Goals

There are a few goals that I have for this project.

The number 1 goal is to create a pre-emptive multitasking operating system with
virtual memory.

I also have a few stretch goals:

1. Connect it to the internet

2. Boot linux (lol)

Along the way, there are a few milestones that I want to reach:

* USB support, including mass storage and peripherals
* HDMI Display output
* Ethernet

## Details

Currently, the project is built around an Efinix Trion T20F256 Development board.
I also have a breakout board with an SD card slot, a MAX3421E, and an audio codec
(that I forget the pn) which I got at school. Right now I only use the SD card.

The development board is sparse, but it includes SDRAM and enough headers to add
any other peripherals.

I designed a board to plug into one of the headers which exposes nearly all the pins
of a 65C02 directly to the FPGA, with no external circuitry except for 2 pull-up
resistors.

The heart of the project is `super6502.sv`. This file contains all of the various
parts of the project. It contains a small boot rom, but the rest of the code is
loaded from an SD card. All of the peripherals are also instantiated here, and there
is a block at the top for address decoding. It currently contains a very simple MMU
which allows the CPU access to the full 32MB address space. Other peripherals include
a timer, leds, hardware multiplier and divider, a uart, an spi controller (for the sd
card), an interrupt controller, and the SDRAM controller.

The SDRAM controller is the one supplied by the FPGA manufacturer, efinix, but contained
in a wrapper which adapts the native bus to the 6502 bus.

One aspect of the project that I want to improve on is bus interoperability. There is
a huge world of IP that is available if I support AXI or WishBone, but at the moment
I do not.

## Simulation Effort

Because I mostly work on this project while on the bus going to/from work, I can't be
iteratively testing on the hardware. I was inspired by the simulation setup we have at
work for the Starlink ASICs and decided to try and implement something similar, albeit
with only free tools at my disposal. It mostly works, but is very slow. Booting the
kernel takes nearly an hour(!), and that is with no kernel features or functionality.

For this reason, the IP blocks have standalone simulations as well as full system
simulations

## Contributing

While I appreciate feedback, this my own personal project and I will not accept
external contributions.