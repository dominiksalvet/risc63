--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package alu_pkg is
    constant c_ALU_ADD: std_ulogic_vector(4 downto 0) := "00000";
    constant c_ALU_SUB: std_ulogic_vector(4 downto 0) := "00001";

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

    constant c_ALU_EXTB: std_ulogic_vector(4 downto 0) := "10000";
    constant c_ALU_EXTW: std_ulogic_vector(4 downto 0) := "10001";
    constant c_ALU_EXT: std_ulogic_vector(4 downto 0) := "10010";

    constant c_ALU_EXTBU: std_ulogic_vector(4 downto 0) := "10100";
    constant c_ALU_EXTWU: std_ulogic_vector(4 downto 0) := "10101";
    constant c_ALU_EXTDU: std_ulogic_vector(4 downto 0) := "10110";

    constant c_ALU_INSB: std_ulogic_vector(4 downto 0) := "11000";
    constant c_ALU_INSW: std_ulogic_vector(4 downto 0) := "11001";
    constant c_ALU_INSD: std_ulogic_vector(4 downto 0) := "11010";

    constant c_ALU_MSKB: std_ulogic_vector(4 downto 0) := "11100";
    constant c_ALU_MSKW: std_ulogic_vector(4 downto 0) := "11101";
    constant c_ALU_MSKD: std_ulogic_vector(4 downto 0) := "11110";
end package alu_pkg;
