# List of Instructions

This file includes all instructions of the RISC63 architecture. For each instruction, there is behavior and a potential assembly form provided. If you would rather see instructions decoding, see [decoding.md](decoding.md) file.

In the instructions definitions below, there are the following symbols used:

* `imm[x]` – an `x`-bit immediate value extended with its sign bit
* `ra` – an index of the read and written register
  * also may be read-only or write-only
* `rb` – an index of the read register
* `cr` – a control register index
  * may be either read-only or write-only

## Memory Communication

* `ld ra, rb, imm[5]`
* `st ra, rb, imm[5]`

`ld` loads a 64-bit value from memory to register `ra`. `st` stores a 64-bit value of register `ra` to memory. The memory address is computed as `rb + 8 * imm`.

## Immediate Add

* `addi ra, imm[8]`
* `addui ra, imm[8]`
* `auipc ra, imm[8]`
* `li ra, imm[8]`

## Conditional Jumps

* `jz ra, imm[7]`
* `jnz ra, imm[7]`
* `aipc ra, imm[7]`
* `jr ra, imm[7]`

## Immediate Arithmetic

* `slti ra, imm[6]`
* `sltui ra, imm[6]`
* `sgti ra, imm[6]`
* `sgtui ra, imm[6]`
* `srli ra, imm[6]`
* `slli ra, imm[6]`
* `srai ra, imm[6]`
* `rsbi ra, imm[6]`

## Arithmetic and Logic

* `add ra, rb`
* `sub ra, rb`
* `and ra, rb`
* `or ra, rb`
* `xor ra, rb`
* `slt ra, rb`
* `sltu ra, rb`
* `sgt ra, rb`
* `sgtu ra, rb`
* `srl ra, rb`
* `sll ra, rb`
* `sra ra, rb`
* `rsb ra, rb`

## Unconditional Jump

* `jmp imm[12]`

## Data Manipulation

* `extb ra, rb`
* `extw ra, rb`
* `extd ra, rb`
* `extbu ra, rb`
* `extwu ra, rb`
* `extdu ra, rb`
* `insb ra, rb`
* `insw ra, rb`
* `insd ra, rb`
* `mskb ra, rb`
* `mskw ra, rb`
* `mskd ra, rb`

## Control Registers

* `crr ra, cr`
* `crw ra, cr`

## Data Move

* `mv ra, rb`

## No Operands

* `nop`
* `iret`



## Summary

* `ld` - load from memory
* `st` - store to memory
* `addi` - addition immediate
* `addui` - add upper immediate
* `auipc` - add upper immediate to `pc`
* `li` - load immediate
* `jz` - jump if zero
* `jnz` - jump if not zero
* `aipc` - add immediate to `pc`
* `jr` - jump register
* `slti` - set if less than immediate
* `sltui` - set if less than unsigned immediate
* `sgti` - set if greater than immediate
* `sgtui` - set if greater than unsigned immedate
* `srli` - shift right logical immediate
* `slli` - shift left logical immediate
* `srai` - shift right arithmetic immediate
* `rsbi` - reverse subtract immediate
* `add` - addition
* `sub` - subtract
* `and` - bitwise logical AND
* `or` - bitwise logical OR
* `xor` - bitwise logical XOR
* `slt` - set if less than
* `sltu` - set if less than unsigned
* `sgt` - set if greater than
* `sgtu` - set if greater than unsigned
* `srl` - shift right logical
* `sll` - shift left logical
* `sra` - shifr right arithmetic
* `rsb` - reverse subtract
* `jmp` - jump
* `extb` - extract byte
* `extw` - extract word
* `extd` - extract double word
* `extbu` - extract byte unsigned
* `extwu` - extract word unsigned
* `extdu` - extract double word unsigned
* `insb` - insert byte
* `insw` - insert word
* `insd` - insert double word
* `mskb` - mask byte
* `mskw` - mask word
* `mskd` - mask double word
* `crr` - control register read
* `crw` - control register write
* `mv` - move
* `nop` - no operation
* `iret` - return from interrupt
