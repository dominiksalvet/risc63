--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity alu is
    port (
        i_opcode: in std_ulogic_vector(4 downto 0);
        i_a_operand: in std_ulogic_vector(63 downto 0);
        i_b_operand: in std_ulogic_vector(63 downto 0);
        o_result: out std_ulogic_vector(63 downto 0)
    );
end entity alu;

architecture rtl of alu is
    -- ALU adder signals
    signal s_adder_mode: t_adder_mode;
    signal s_adder_less: std_ulogic;
    signal s_adder_less_unsigned: std_ulogic;
    signal s_adder_result: std_ulogic_vector(63 downto 0);

    -- picker signals
    signal s_picker_result: std_ulogic_vector(63 downto 0);

    -- shift functions to simplify RTL description
    function f_alu_srl(a, b: std_ulogic_vector) return std_ulogic_vector is
    begin
        return std_ulogic_vector(shift_right(unsigned(a), to_integer(unsigned(b))));
    end function f_alu_srl;

    function f_alu_sll(a, b: std_ulogic_vector) return std_ulogic_vector is
    begin
        return std_ulogic_vector(shift_left(unsigned(a), to_integer(unsigned(b))));
    end function f_alu_sll;

    function f_alu_sra(a, b: std_ulogic_vector) return std_ulogic_vector is
    begin
        return std_ulogic_vector(shift_right(signed(a), to_integer(unsigned(b))));
    end function f_alu_sra;
begin

--- adder-subtractor -----------------------------------------------------------

    with i_opcode select s_adder_mode <=
        ADDER_ADD when c_ALU_ADD,
        ADDER_SUB when c_ALU_SUB | c_ALU_SLT | c_ALU_SLTU,
        ADDER_RSB when others;

    m_adder: entity work.adder
    port map (
        s_adder_mode,
        i_a_operand,
        i_b_operand,
        s_adder_less,
        s_adder_less_unsigned,
        s_adder_result
    );

--- data picker ----------------------------------------------------------------

    m_picker: entity work.picker
    port map (
        i_opcode => i_opcode(3 downto 0),
        i_data_array => i_a_operand,
        i_selector => i_b_operand(2 downto 0),
        o_result => s_picker_result
    );

--------------------------------------------------------------------------------

    with i_opcode select o_result <=
        s_adder_result when c_ALU_ADD | c_ALU_SUB | c_ALU_RSB,
        i_a_operand when c_ALU_A,
        i_b_operand when c_ALU_B,
        i_a_operand and i_b_operand when c_ALU_AND,
        i_a_operand or i_b_operand when c_ALU_OR,
        i_a_operand xor i_b_operand when c_ALU_XOR,
        (62 downto 0 => '0') & s_adder_less when c_ALU_SLT | c_ALU_SGT,
        (62 downto 0 => '0') & s_adder_less_unsigned when c_ALU_SLTU | c_ALU_SGTU,
        f_alu_srl(i_a_operand, i_b_operand(5 downto 0)) when c_ALU_SRL,
        f_alu_sll(i_a_operand, i_b_operand(5 downto 0)) when c_ALU_SLL,
        f_alu_sra(i_a_operand, i_b_operand(5 downto 0)) when c_ALU_SRA,
        s_picker_result when others;

end architecture rtl;
