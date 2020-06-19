# Registers

There are three types of architectural registers in RISC63:

* A program counter is a unique register controlling the program flow.
* A general purpose register is used as temporary data storage within the processor.
* A control register is used for a specific task otherwise impossible to do.

All these registers are 64-bit wide.

## Program Counter (`pc`)

The `pc` register is also known as instruction pointer. It holds the address of the next instruction to be executed. If that instruction is not of a jump type, the value of this register is automatically incremented.

## General Purpose Registers (`r0` to `r15`)

The `r0` to `r15` registers may be freely used in any programs. All these registers are equal and, furthermore, there is no implicit register addressing involved in the whole RISC63 architecture.

## Control Registers

The control registers are used for the processor management and configuration, and thus they should not be used in ordinary programs. Their major purpose in RISC63 is the interrupt handling.

### Auxiliary Registers (`k0`, `k1`)

The `k0` and `k1` are auxiliary registers with no hardware dedicated use. They are expected to be used during interrupts to prevent overwriting general purpose registers without previous storing.

### Status Register (`status`)

The `status` register is the central processor status register. It contains the following bits:

| 63 - 1   | 0  |
|----------|----|
| reserved | ie |

* `ie` - interrupt enable

### Interrupt Vector (`ivec`)

The `ivec` register contains the address to jump on when an interrupt occurs.

### Saved Program Counter (`spc`)

Once an interrupt occurs, the `pc` value is stored to the `spc` register since it will be overwritten by the `ivec` value. This way, it is possible to return the control to the interrupted program without noticing.
