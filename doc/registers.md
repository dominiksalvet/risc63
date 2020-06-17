# Registers

There are three types of architectural registers in RISC63:

* A program counter (PC) is a unique register controlling the program flow.
* A general purpose register (GPR) may be used as temporary data storage within the processor.
* A control register (CR) is an entry point to get or set the processor general behavior.

## Program Counter

* pc - program counter

## General Purpose Registers

* r0-r15 - general purpose registers

## Control Registers

* spc - saved PC
* ivec - interrupt vector
* status - machine status (includes IE)
* cause - interrupt cause
* k0, k1 - auxiliary registers
