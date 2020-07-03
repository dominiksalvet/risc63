--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity id_stage is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

        i_inst: in std_ulogic_vector(15 downto 0);
        i_pc: in std_ulogic_vector(62 downto 0);

        o_alu_opcode: out std_ulogic_vector(4 downto 0);
        o_alu_a_operand: out std_ulogic_vector(63 downto 0);
        o_alu_b_operand: out std_ulogic_vector(63 downto 0);

        o_reg_b_data: out std_ulogic_vector(63 downto 0);
        o_reg_c_we: out std_ulogic;
        o_reg_c_index: out std_ulogic_vector(3 downto 0);

        o_jmp_cond: out t_jmp_cond
    );
end entity id_stage;

architecture rtl of id_stage is
    s_ir: std_ulogic_vector(15 downto 0);
    s_pc: std_ulogic_vector(62 downto 0);
begin

    catch_input: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_ir <= c_NOP_INST;
            else
                s_ir <= i_inst;
                s_pc <= i_pc;
            end if;
        end if;
    end process catch_input;

end architecture rtl;
