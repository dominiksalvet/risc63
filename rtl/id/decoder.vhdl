--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity decoder is
    port (
        i_inst: in std_ulogic_vector(15 downto 0);

        o_iext_opcode: out t_iext_opcode;
        o_amux_alu: out t_amux_alu;
        o_bmux_alu: out t_bmux_alu
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
    s_ld_group <= '1' when i_inst(15 downto 14) = "11" else '0';
    s_addi_group <= '1' when i_inst(15 downto 14) = "10" else '0';
    s_jz_group <= '1' when i_inst(15 downto 13) = "011" else '0';
    s_slti_group <= '1' when i_inst(15 downto 13) = "010" else '0';
    s_add_group <= '1' when i_inst(15 downto 12) = "0011" else '0';
    s_jmp_inst <= '1' when i_inst(15 downto 12) = "0010" else '0';
    s_extb_group <= '1' when i_inst(15 downto 12) = "0001" else '0';
    s_crr_group <= '1' when i_inst(15 downto 11) = "00001" else '0';
    s_mv_inst <= '1' when i_inst(15 downto 10) = "000001" else '0';
    s_nop_group <= '1' when i_inst(15 downto 10) = "000000" else '0';

    -- immediate value extraction
    o_iext_opcode <= IEXT_LD when s_ld_group = '1' else
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
                  BMUX_PC when (s_addi_group = '1' and i_inst(13 downto 12) = "10") or
                               s_jz_group = '1' and i_inst(12 downto 11) /= "11" or
                               s_jmp_inst = '1' else
                  BMUX_BREG;

end architecture rtl;
