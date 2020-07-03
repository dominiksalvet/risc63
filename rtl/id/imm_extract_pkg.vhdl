--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package imm_extract_pkg is
    constant c_IEXT_LD: std_ulogic_vector(2 downto 0) := "000";
    constant c_IEXT_ADDI: std_ulogic_vector(2 downto 0) := "001";
    constant c_IEXT_JZ: std_ulogic_vector(2 downto 0) := "010";
    constant c_IEXT_SLTI: std_ulogic_vector(2 downto 0) := "011";
    constant c_IEXT_JMP: std_ulogic_vector(2 downto 0) := "100";
end package imm_extract_pkg;
