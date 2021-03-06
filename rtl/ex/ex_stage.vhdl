--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity ex_stage is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

------- input from ID stage ----------------------------------------------------
        i_alu_opcode: in std_ulogic_vector(4 downto 0);
        i_alu_a_operand: in std_ulogic_vector(63 downto 0);
        i_alu_b_operand: in std_ulogic_vector(63 downto 0);

        i_jmp_cond: in t_jmp_cond;
        i_iret: in std_ulogic;
        i_pc: in std_ulogic_vector(62 downto 0);
        i_pc_valid: in std_ulogic;

        i_mem_we: in std_ulogic;
        i_reg_a_data: in std_ulogic_vector(63 downto 0);
        i_cr_we: in std_ulogic;
        i_cr_index: in std_ulogic_vector(2 downto 0);
        i_reg_c_we: in std_ulogic;
        i_reg_c_index: in std_ulogic_vector(3 downto 0);

        i_result_mux: in t_result_mux;

------- output to MEM stage ----------------------------------------------------
        o_jmp_en: out std_ulogic;
        o_iret: out std_ulogic;
        o_pc: out std_ulogic_vector(62 downto 0);
        o_pc_valid: out std_ulogic;

        o_mem_we: out std_ulogic;
        o_mem_wr_data: out std_ulogic_vector(63 downto 0);
        o_cr_we: out std_ulogic;
        o_cr_index: out std_ulogic_vector(2 downto 0);
        o_reg_c_we: out std_ulogic;
        o_reg_c_index: out std_ulogic_vector(3 downto 0);

        o_result_mux: out t_result_mux;
        o_alu_result: out std_ulogic_vector(63 downto 0)
    );
end entity ex_stage;

architecture rtl of ex_stage is
    -- stage registers
    signal s_alu_opcode: std_ulogic_vector(4 downto 0);
    signal s_alu_a_operand: std_ulogic_vector(63 downto 0);
    signal s_alu_b_operand: std_ulogic_vector(63 downto 0);

    signal s_jmp_cond: t_jmp_cond;
    signal s_reg_a_data: std_ulogic_vector(63 downto 0);
begin

    catch_input: process(i_clk)
    begin
        if rising_edge(i_clk) then
            o_iret <= i_iret;
            o_pc <= i_pc;
            o_pc_valid <= i_pc_valid;
            o_mem_we <= i_mem_we;
            o_cr_we <= i_cr_we;
            o_cr_index <= i_cr_index;
            o_reg_c_we <= i_reg_c_we;
            o_reg_c_index <= i_reg_c_index;
            o_result_mux <= i_result_mux;

            s_alu_opcode <= i_alu_opcode;
            s_alu_a_operand <= i_alu_a_operand;
            s_alu_b_operand <= i_alu_b_operand;
            s_jmp_cond <= i_jmp_cond;
            s_reg_a_data <= i_reg_a_data;

            if i_rst = '1' then
                o_iret <= '0';
                o_pc_valid <= '0';
                o_mem_we <= '0';
                o_cr_we <= '0';
                o_reg_c_we <= '0';

                s_jmp_cond <= JMP_NEVER;
            end if;
        end if;
    end process catch_input;

--- ALU ------------------------------------------------------------------------

    m_alu: entity work.alu
    port map (
        s_alu_opcode,
        s_alu_a_operand,
        s_alu_b_operand,
        o_alu_result
    );

--- jump tester ----------------------------------------------------------------

    m_jmp_test: entity work.jmp_test
    port map (
        s_jmp_cond,
        s_reg_a_data,
        o_jmp_en
    );

--------------------------------------------------------------------------------

    o_mem_wr_data <= s_reg_a_data;

end architecture rtl;
