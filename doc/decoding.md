# Decoding of Instructions

This file describes the exact decoding of RISC63 instructions and control registers indexes. That may be useful for programming RISC63 in machine code as well as for creating low level tools such as assembler. In case a binary encoding is not defined below, its behavior is undefined.

## Load and Store Instructions

* bits 15-14 – 11
* bit 13
  * 0 – `ld`
  * 1 – `st`
* bits 12-8 – `imm`
* bits 7-4 – `rb`
* bits 3-0 – `ra`

## Immediate Add Instructions

* bits 15-14 – 10
* bits 13-12
  * 00 – `addi`
  * 01 – `addui`
  * 10 – `auipc`
  * 11 – `li`
* bits 11-4 – `imm`
* bits 3-0 – `ra`

## Conditional Jump Instructions

* bits 15-13 – 011
* bits 12-11
  * 00 – `jz`
  * 01 – `jnz`
  * 10 – `aipc`
  * 11 – `jr`
* bits 10-4 – `imm`
* bits 3-0 – `ra`

## Immediate Arithmetic Instructions

* bits 15-13 – 010
* bits 12-10
  * 000 – `slti`
  * 001 – `sltui`
  * 010 – `sgti`
  * 011 – `sgtui`
  * 100 – `srli`
  * 101 – `slli`
  * 110 – `srai`
  * 111 – `rsbi`
* bits 9-4 – `imm`
* bits 3-0 – `ra`

## Arithmetic and Logic Instructions

* bits 15-12 – 0011
* bits 11-8
  * 0000 – `add`
  * 0001 – `sub`
  * 0100 – `and`
  * 0101 – `or`
  * 0110 – `xor`
  * 1000 – `slt`
  * 1001 – `sltu`
  * 1010 – `sgt`
  * 1011 – `sgtu`
  * 1100 – `srl`
  * 1101 – `sll`
  * 1110 – `sra`
  * 1111 – `rsb`
* bits 7-4 – `rb`
* bits 3-0 – `ra`

## Unconditional Jump Instruction

* bits 15-12 – 0010
* bits 11-0 – `imm`

## Data Manipulation Instructions

* bits 15-12 – 0001
* bits 11-8
  * 0000 – `extb`
  * 0001 – `extw`
  * 0010 – `extd`
  * 0100 – `extbu`
  * 0101 – `extwu`
  * 0110 – `extdu`
  * 1000 – `insb`
  * 1001 – `insw`
  * 1010 – `insd`
  * 1100 – `mskb`
  * 1101 – `mskw`
  * 1110 – `mskd`
* bits 7-4 – `rb`
* bits 3-0 – `ra`

## Control Register Instructions

* bits 15-11 – 00001
* bit 10
  * 0 – `crr`
  * 1 – `crw`
* bits 9-7 – unused
* bits 6-4
  * 000 – `k0`
  * 001 – `k1`
  * 010 – `status`
  * 011 – `ivec`
  * 100 – `spc`
* bits 3-0 – `ra`

## Move Instructions

* bits 15-10 – 000001
* bits 9-8 – unused
* bits 7-4 – `rb`
* bits 3-0 – `ra`

## Instructions without Operands

* bits 15-10 – 000000
* bits 9-8
  * 00 – `nop`
  * 01 – `iret`
* bits 7-0 – unused
