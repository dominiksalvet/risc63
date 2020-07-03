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

        o_iext_opcode: out t_iext_opcode
    );
end entity decoder;

architecture rtl of decoder is

    signal s_ld_group: std_ulogic; -- ld, st
    signal s_addi_group: std_ulogic; -- addi, addui, auipc, li
    signal s_jz_group: std_ulogic; -- jz, jnz, aipc, jr
    signal s_slti_group: std_ulogic; -- slti, sltui, sgti, sgtui, srli, slli, srai, rsbi
    signal s_slt_group: std_ulogic; -- slt, sltu, sgt, sgtu, srl, sll, sra, rsb,
                                    -- sub, and, or, xor, add
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
    s_slt_group <= '1' when i_inst(15 downto 12) = "0011" else '0';
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

end architecture rtl;
