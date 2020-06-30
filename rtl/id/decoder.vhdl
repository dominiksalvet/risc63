--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.alu_pkg.all;

entity decoder is
    port (
        i_inst: in std_ulogic_vector(15 downto 0);

        o_alu_opcode: out std_ulogic_vector(3 downto 0)
    );
end entity decoder;

architecture rtl of decoder is

    signal ld_inst: std_ulogic;
    signal st_inst: std_ulogic;
    signal addi_group: std_ulogic; -- addi, addui, auipc, li
    signal jz_group: std_ulogic; -- jz, jnz, aipc, jr
    signal slti_group: std_ulogic; -- slti, sltui, sgti, sgtui, srli, slli, srai, rsbi
    signal slt_group: std_ulogic; -- slt, sltu, sgt, sgtu, srl, sll, sra, rsb
                                  -- and, or, xor, add, sub
    signal jmp_inst: std_ulogic;
    signal crr_inst: std_ulogic;
    signal crw_inst: std_ulogic;
    signal mv_inst: std_ulogic;
    signal nop_group: std_ulogic; -- nop, sysret

begin

    -- instruction/group detection
    ld_inst <= '1' when i_inst(15 downto 13) = "110" else '0';
    st_inst <= '1' when i_inst(15 downto 13) = "111" else '0';
    addi_group <= '1' when i_inst(15 downto 14) = "10" else '0';
    jz_group <= '1' when i_inst(15 downto 13) = "011" else '0';
    slti_group <= '1' when i_inst(15 downto 13) = "010" else '0';
    slt_group <= '1' when i_inst(15 downto 12) = "0011" else '0';
    jmp_inst <= '1' when i_inst(15 downto 12) = "0010" else '0';
    crr_inst <= '1' when i_inst(15 downto 11) = "00010" else '0';
    crw_inst <= '1' when i_inst(15 downto 11) = "00011" else '0';
    mv_inst <= '1' when i_inst(15 downto 8) = "00000001" else '0';
    nop_group <= '1' when i_inst(15 downto 7) = "000000001" else '0';

end architecture rtl;
