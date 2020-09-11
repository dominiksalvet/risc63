--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity control_unit is
    port (
        i_clk: in std_ulogic;

------- input control signals --------------------------------------------------
        i_rst: in std_ulogic;
        i_irq: in std_ulogic;
        i_cr_ie: in std_ulogic;
        i_mem_iret: in std_ulogic;
        i_mem_jmp_en: in std_ulogic;

------- output control signals -------------------------------------------------
        o_irq_en: out std_ulogic;
        o_cr_ie_we: out std_ulogic;
        o_cr_ie: out std_ulogic;
        o_spc_mux: out t_spc_mux;

------- data hazards -----------------------------------------------------------
        i_id_reg_a_re: in std_ulogic;
        i_id_reg_a_index: in std_ulogic_vector(3 downto 0);
        i_id_reg_b_re: in std_ulogic;
        i_id_reg_b_index: in std_ulogic_vector(3 downto 0);

        i_ex_reg_c_we: in std_ulogic;
        i_ex_reg_c_index: in std_ulogic_vector(3 downto 0);
        i_mem_reg_c_we: in std_ulogic;
        i_mem_reg_c_index: in std_ulogic_vector(3 downto 0);
        i_wb_reg_c_we: in std_ulogic;
        i_wb_reg_c_index: in std_ulogic_vector(3 downto 0);

------- pipeline control -------------------------------------------------------
        o_if_jmp_en: out std_ulogic;
        o_if_jmp_addr_mux: out t_jmp_addr_mux;

        o_id_rst: out std_ulogic;
        o_ex_rst: out std_ulogic;
        o_mem_rst: out std_ulogic;

        o_if_stall: out std_ulogic;
        o_id_stall: out std_ulogic
    );
end entity control_unit;

architecture rtl of control_unit is
    signal s_irq_en: std_ulogic;
    signal s_jmp: std_ulogic;

    signal s_spc_mux: t_spc_mux; -- state register

    signal s_reg_a_hazard: std_ulogic;
    signal s_reg_b_hazard: std_ulogic;
    signal s_data_hazard: std_ulogic;
begin

--- jumps and interrupts -------------------------------------------------------

    s_irq_en <= i_irq and i_cr_ie;
    s_jmp <= s_irq_en or i_mem_iret or i_mem_jmp_en;

    o_irq_en <= s_irq_en;
    o_cr_ie_we <= s_irq_en or i_mem_iret;
    o_cr_ie <= '0' when s_irq_en = '1' else '1';

    o_if_jmp_en <= s_jmp;
    o_if_jmp_addr_mux <= JMP_ADDR_IVEC when s_irq_en = '1' else
                         JMP_ADDR_SPC when i_mem_iret = '1' else
                         JMP_ADDR_ALU;

    next_spc_mux: process(i_clk)
    begin
        if rising_edge(i_clk) then
            -- simple FSM implementation
            case s_spc_mux is
                when SPC_IF => s_spc_mux <= SPC_ID;
                when SPC_ID => s_spc_mux <= SPC_EX;
                when SPC_EX | SPC_MEM => s_spc_mux <= SPC_MEM;
            end case;
            if s_jmp = '1' then
                s_spc_mux <= SPC_IF;
            end if;

            if i_rst = '1' then
                s_spc_mux <= SPC_IF;
            end if;
        end if;
    end process next_spc_mux;

    o_spc_mux <= s_spc_mux;

--- data hazard detection ------------------------------------------------------

s_reg_a_hazard <= '1' when i_id_reg_a_re = '1' and
                           ((i_ex_reg_c_we = '1' and i_ex_reg_c_index = i_id_reg_a_index) or
                           (i_mem_reg_c_we = '1' and i_mem_reg_c_index = i_id_reg_a_index) or
                           (i_wb_reg_c_we = '1' and i_wb_reg_c_index = i_id_reg_a_index)) else
                  '0';
s_reg_b_hazard <= '1' when i_id_reg_b_re = '1' and
                           ((i_ex_reg_c_we = '1' and i_ex_reg_c_index = i_id_reg_b_index) or
                           (i_mem_reg_c_we = '1' and i_mem_reg_c_index = i_id_reg_b_index) or
                           (i_wb_reg_c_we = '1' and i_wb_reg_c_index = i_id_reg_b_index)) else
                  '0';

s_data_hazard <= s_reg_a_hazard or s_reg_b_hazard;

--- pipeline control -----------------------------------------------------------

o_id_rst <= i_rst or s_jmp;
o_ex_rst <= i_rst or s_jmp or s_data_hazard;
o_mem_rst <= i_rst or s_jmp;

o_if_stall <= s_data_hazard;
o_id_stall <= s_data_hazard;

end architecture rtl;
