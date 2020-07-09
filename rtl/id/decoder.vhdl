--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity decoder is
    port (
        i_opcode_field: in std_ulogic_vector(7 downto 0); -- higher part of instruction

------- ID signals -------------------------------------------------------------
        o_iext_type: out t_iext_type;
        o_amux_alu: out t_alu_a_mux;
        o_bmux_alu: out t_alu_b_mux;
        o_alu_opcode: out std_ulogic_vector(4 downto 0);

------- control flow signals ---------------------------------------------------
        o_jmp_cond: out t_jmp_cond;
        o_iret: out std_ulogic;

------- write enable signals ---------------------------------------------------
        o_mem_we: out std_ulogic;
        o_cr_we: out std_ulogic;
        o_reg_c_we: out std_ulogic;

------- select result ----------------------------------------------------------
        o_result_mux: out t_result_mux
    );
end entity decoder;

architecture rtl of decoder is
    signal s_ld_group: std_ulogic; -- ld, st
    signal s_addi_group: std_ulogic; -- addi, addui, auipc, li
    signal s_jz_group: std_ulogic; -- jz, jnz, aipc, jr
    signal s_slti_group: std_ulogic; -- slti, sltui, sgti, sgtui, srli, slli, srai, rsbi
    signal s_add_group: std_ulogic; -- add, sub, and, or, xor,
                                    -- slt, sltu, sgt, sgtu, srl, sll, sra, rsb,
    signal s_jmp_inst: std_ulogic;
    signal s_extb_group: std_ulogic; -- extb, extw, extd, extbu, extwu, extdu,
                                     -- insb, insw, insd, mskb, mskw, mskd
    signal s_crr_group: std_ulogic; -- crr, crw
    signal s_mv_inst: std_ulogic;
    signal s_nop_group: std_ulogic; -- nop, iret
begin

    -- instruction/group detection
    s_ld_group <= '1' when i_opcode_field(7 downto 6) = "11" else '0';
    s_addi_group <= '1' when i_opcode_field(7 downto 6) = "10" else '0';
    s_jz_group <= '1' when i_opcode_field(7 downto 5) = "011" else '0';
    s_slti_group <= '1' when i_opcode_field(7 downto 5) = "010" else '0';
    s_add_group <= '1' when i_opcode_field(7 downto 4) = "0011" else '0';
    s_jmp_inst <= '1' when i_opcode_field(7 downto 4) = "0010" else '0';
    s_extb_group <= '1' when i_opcode_field(7 downto 4) = "0001" else '0';
    s_crr_group <= '1' when i_opcode_field(7 downto 3) = "00001" else '0';
    s_mv_inst <= '1' when i_opcode_field(7 downto 2) = "000001" else '0';
    s_nop_group <= '1' when i_opcode_field(7 downto 2) = "000000" else '0';

--- ID signals -----------------------------------------------------------------

    -- immediate value extraction
    o_iext_type <= IEXT_LD when s_ld_group = '1' else
                   IEXT_ADDI when s_addi_group = '1' else
                   IEXT_JZ when s_jz_group = '1' else
                   IEXT_SLTI when s_slti_group = '1' else
                   IEXT_JMP;

    -- ALU operand A multiplexer
    o_amux_alu <= AMUX_IMM when s_addi_group = '1' or s_jz_group = '1' or
                                s_slti_group = '1' or s_jmp_inst = '1' else
                  AMUX_AREG;

    -- ALU operand B multiplexer
    o_bmux_alu <= BMUX_IMM when s_ld_group = '1' else
                  BMUX_PC when (s_addi_group = '1' and i_opcode_field(5 downto 4) = "10") or
                               (s_jz_group = '1' and i_opcode_field(4 downto 3) /= "11") or
                               s_jmp_inst = '1' else
                  BMUX_BREG;

    -- select ALU operation
    o_alu_opcode <= c_ALU_A when (s_addi_group = '1' and i_opcode_field(5 downto 4) = "11") or
                                 s_mv_inst = '1' else
                    c_ALU_B when s_crr_group = '1' else
                    "01" & i_opcode_field(4 downto 2) when s_slti_group = '1' else
                    '0' & i_opcode_field(3 downto 0) when s_add_group = '1' else
                    '1' & i_opcode_field(3 downto 0) when s_extb_group = '1' else
                    c_ALU_ADD;

--- control flow signals -------------------------------------------------------

    -- jump condition
    o_jmp_cond <= JMP_ALWAYS when (s_jz_group = '1' and i_opcode_field(4 downto 3) = "11") or
                                  s_jmp_inst = '1' else
                  JMP_ZERO when s_jz_group = '1' and i_opcode_field(4 downto 3) = "00" else
                  JMP_NZERO when s_jz_group = '1' and i_opcode_field(4 downto 3) = "01" else
                  JMP_NEVER;

    -- interrupt return detected
    o_iret <= '1' when s_nop_group = '1' and i_opcode_field(0) = '1' else '0';

--- write enable signals -------------------------------------------------------

    -- enable write to memory
    o_mem_we <= '1' when s_ld_group = '1' and i_opcode_field(5) = '1' else '0';

    -- control registers
    o_cr_we <= '1' when s_crr_group = '1' and i_opcode_field(2) = '1' else '0';

    -- enable write to C register index
    o_reg_c_we <= '0' when (s_ld_group = '1' and i_opcode_field(5) = '1') or
                           (s_jz_group = '1' and i_opcode_field(4 downto 3) /= "10") or
                           (s_crr_group = '1' and i_opcode_field(2) = '1') else
                  '1';

------- select result ----------------------------------------------------------

    -- which result should be stored to register file
    o_result_mux <= RESULT_MEM when s_ld_group = '1' and i_opcode_field(5) = '0' else
                    RESULT_CR when s_crr_group = '1' and i_opcode_field(2) = '0' else
                    RESULT_ALU;

end architecture rtl;
