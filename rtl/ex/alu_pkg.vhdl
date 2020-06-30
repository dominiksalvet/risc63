--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package alu_pkg is
    constant c_ALU_SLT: std_ulogic_vector(3 downto 0) := "0000";
    constant c_ALU_SLTU: std_ulogic_vector(3 downto 0) := "0001";
    constant c_ALU_SGT: std_ulogic_vector(3 downto 0) := "0010";
    constant c_ALU_SGTU: std_ulogic_vector(3 downto 0) := "0011";
    constant c_ALU_SRL: std_ulogic_vector(3 downto 0) := "0100";
    constant c_ALU_SLL: std_ulogic_vector(3 downto 0) := "0101";
    constant c_ALU_SRA: std_ulogic_vector(3 downto 0) := "0110";
    constant c_ALU_RSB: std_ulogic_vector(3 downto 0) := "0111";
    constant c_ALU_AND: std_ulogic_vector(3 downto 0) := "1000";
    constant c_ALU_OR: std_ulogic_vector(3 downto 0) := "1001";
    constant c_ALU_XOR: std_ulogic_vector(3 downto 0) := "1010";
    constant c_ALU_ADD: std_ulogic_vector(3 downto 0) := "1100";
    constant c_ALU_SUB: std_ulogic_vector(3 downto 0) := "1111";
end package alu_pkg;
