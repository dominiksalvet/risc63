--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package risc63_pkg is

--- control unit ---------------------------------------------------------------

    type t_jmp_addr_mux is (JMP_ADDR_ALU, JMP_ADDR_SPC);

--- IF stage -------------------------------------------------------------------

    -- value of PC after reset
    constant c_PC_RST: std_ulogic_vector(62 downto 0) := (others => '0');

--- ID stage -------------------------------------------------------------------

    -- no operation instruction binary
    constant c_NOP_INST: std_ulogic_vector(15 downto 0) := (others => '0');

    -- immediate extractor
    type t_iext_type is (IEXT_LD, IEXT_ADDI, IEXT_JZ, IEXT_SLTI, IEXT_JMP);

    -- ALU operand A multiplexer
    type t_alu_a_mux is (AMUX_IMM, AMUX_AREG);

    -- ALU operand B multiplexer
    type t_alu_b_mux is (BMUX_IMM, BMUX_PC, BMUX_BREG);

--- EX stage -------------------------------------------------------------------

    -- data picker opcodes
    constant c_PICKER_EXTB: std_ulogic_vector(3 downto 0) := "0000";
    constant c_PICKER_EXTW: std_ulogic_vector(3 downto 0) := "0001";
    constant c_PICKER_EXTD: std_ulogic_vector(3 downto 0) := "0010";

    constant c_PICKER_EXTBU: std_ulogic_vector(3 downto 0) := "0100";
    constant c_PICKER_EXTWU: std_ulogic_vector(3 downto 0) := "0101";
    constant c_PICKER_EXTDU: std_ulogic_vector(3 downto 0) := "0110";

    constant c_PICKER_INSB: std_ulogic_vector(3 downto 0) := "1000";
    constant c_PICKER_INSW: std_ulogic_vector(3 downto 0) := "1001";
    constant c_PICKER_INSD: std_ulogic_vector(3 downto 0) := "1010";

    constant c_PICKER_MSKB: std_ulogic_vector(3 downto 0) := "1100";
    constant c_PICKER_MSKW: std_ulogic_vector(3 downto 0) := "1101";
    constant c_PICKER_MSKD: std_ulogic_vector(3 downto 0) := "1110";

    -- ALU opcodes
    constant c_ALU_ADD: std_ulogic_vector(4 downto 0) := "00000";
    constant c_ALU_SUB: std_ulogic_vector(4 downto 0) := "00001";
    constant c_ALU_A: std_ulogic_vector(4 downto 0) := "00010";
    constant c_ALU_B: std_ulogic_vector(4 downto 0) := "00011";

    constant c_ALU_AND: std_ulogic_vector(4 downto 0) := "00100";
    constant c_ALU_OR: std_ulogic_vector(4 downto 0) := "00101";
    constant c_ALU_XOR: std_ulogic_vector(4 downto 0) := "00110";

    constant c_ALU_SLT: std_ulogic_vector(4 downto 0) := "01000";
    constant c_ALU_SLTU: std_ulogic_vector(4 downto 0) := "01001";
    constant c_ALU_SGT: std_ulogic_vector(4 downto 0) := "01010";
    constant c_ALU_SGTU: std_ulogic_vector(4 downto 0) := "01011";
    constant c_ALU_SRL: std_ulogic_vector(4 downto 0) := "01100";
    constant c_ALU_SLL: std_ulogic_vector(4 downto 0) := "01101";
    constant c_ALU_SRA: std_ulogic_vector(4 downto 0) := "01110";
    constant c_ALU_RSB: std_ulogic_vector(4 downto 0) := "01111";

    constant c_ALU_EXTB: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_EXTB;
    constant c_ALU_EXTW: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_EXTW;
    constant c_ALU_EXTD: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_EXTD;

    constant c_ALU_EXTBU: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_EXTBU;
    constant c_ALU_EXTWU: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_EXTWU;
    constant c_ALU_EXTDU: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_EXTDU;

    constant c_ALU_INSB: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_INSB;
    constant c_ALU_INSW: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_INSW;
    constant c_ALU_INSD: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_INSD;

    constant c_ALU_MSKB: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_MSKB;
    constant c_ALU_MSKW: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_MSKW;
    constant c_ALU_MSKD: std_ulogic_vector(4 downto 0) := '1' & c_PICKER_MSKD;

    -- ALU adder modes
    type t_adder_mode is (ADDER_ADD, ADDER_SUB, ADDER_RSB);

    -- jump tester conditions
    type t_jmp_cond is (JMP_ALWAYS, JMP_ZERO, JMP_NZERO, JMP_NEVER);

--- WB stage -------------------------------------------------------------------

    type t_result_mux is (RESULT_MEM, RESULT_CR, RESULT_ALU);

end package risc63_pkg;
