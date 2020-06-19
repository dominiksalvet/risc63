# Registers

There are three types of architectural registers in RISC63:

* A program counter is a unique register controlling the program flow.
* A general purpose register is used as temporary data storage within the processor.
* A control register is used for a specific task otherwise impossible to do.

All these registers are 64-bit wide.

## Program Counter

The program counter register is also known as instruction pointer. It holds the address of the next instruction to be executed. If that instruction is not of a jump type, the value of this register is automatically incremented.

It is strongly recommended to refer to the program counter register as the `pc` register.

## General Purpose Registers

There are 16 general purpose registers, which may be freely used by programs. All are equal and, furthermore, there is no implicit register addressing involved in the whole RISC63 architecture.

Please, refer to the individual registers as the `r0` to `r15` registers.

## Control Registers

The control registers are used for the processor management and configuration, and thus ordinary programs should not use them. In RISC63, their major purpose is the interrupt management.

* spc - saved PC
* ivec - interrupt vector
* status - machine status (includes IE)
* cause - interrupt cause
* k0, k1 - auxiliary registers
