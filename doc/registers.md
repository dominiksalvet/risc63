# Registers

There are three types of architectural registers in RISC63:

* A program counter is a unique register controlling the program flow.
* General purpose registers are used as temporary data storage within the processor.
* Control registers are used for specific tasks otherwise impossible to do.

All architectural registers are 64-bit wide and have undefined value after reset, unless otherwise stated.

## Program Counter (`pc`)

The `pc` register is also known as instruction pointer. It holds the address of the currently executing instruction. If that instruction is not a jump, the value of this register is automatically incremented.

The **reset value** of the `pc` register is `0x0`.

## General Purpose Registers (`r0` to `r15`)

The `r0` to `r15` registers may be freely used in any programs. All these registers are equal and, furthermore, there is no implicit register addressing involved in the whole RISC63 architecture.

## Control Registers

The control registers are used for the processor management and configuration, and thus they should not be used in ordinary programs. Their major purpose in RISC63 is the interrupt handling.

> The addresses of control registers are stated in a [Decoding section](https://github.com/dominiksalvet/risc63/blob/master/doc/decoding.md#control-registers).

### Auxiliary Registers (`k0`, `k1`)

The `k0` and `k1` are auxiliary registers with no hardware dedicated use. They are expected to be used during interrupts to prevent overwriting general purpose registers without previous storing.

### Status Register (`status`)

The `status` register is the central processor status register. It contains the following bits:

| 63–1     | 0  |
|----------|----|
| Reserved | IE |

* IE - interrupt enable

The **reset value** of the `status` register is `0x0`. That applies only to bits that are not reserved.

### Interrupt Vector (`ivec`)

The `ivec` register contains the address to jump on when an interrupt occurs.

### Saved Program Counter (`spc`)

Once an interrupt occurs, the next potential `pc` value is written to the `spc` register. This may be used to transparently return control to the interrupted program.
