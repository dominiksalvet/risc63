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

------- interrupts and jumps ---------------------------------------------------
        o_irq_en: out std_ulogic;
        o_cr_ie_we: out std_ulogic;
        o_cr_ie: out std_ulogic;

        o_if_jmp_en: out std_ulogic;
        o_if_jmp_addr_mux: out t_jmp_addr_mux;

------- data hazards -----------------------------------------------------------
        i_id_reg_a_use: in std_ulogic;
        i_id_reg_a_index: in std_ulogic_vector(3 downto 0);
        i_id_reg_b_use: in std_ulogic;
        i_id_reg_b_index: in std_ulogic_vector(3 downto 0);

        i_ex_reg_c_we: in std_ulogic;
        i_ex_reg_c_index: in std_ulogic_vector(3 downto 0);
        i_mem_reg_c_we: in std_ulogic;
        i_mem_reg_c_index: in std_ulogic_vector(3 downto 0);
        i_wb_reg_c_we: in std_ulogic;
        i_wb_reg_c_index: in std_ulogic_vector(3 downto 0);

------- pipeline control -------------------------------------------------------
        o_id_rst: out std_ulogic;
        o_ex_rst: out std_ulogic;
        o_mem_rst: out std_ulogic;

        o_if_stall: out std_ulogic;
        o_id_stall: out std_ulogic;

        o_spc_mux: out t_spc_mux
    );
end entity control_unit;

architecture rtl of control_unit is
    signal s_irq: std_ulogic; -- interrupt request buffer

    signal s_irq_en: std_ulogic;
    signal s_jmp: std_ulogic;

    signal s_reg_a_hazard: std_ulogic;
    signal s_reg_b_hazard: std_ulogic;
    signal s_data_hazard: std_ulogic;

    signal s_id_rst: std_ulogic;
    signal s_ex_rst: std_ulogic;
    signal s_mem_rst: std_ulogic;

    signal s_valid_pc_id: std_ulogic;
    signal s_valid_pc_ex: std_ulogic;
    signal s_valid_pc_mem: std_ulogic;
begin

--- interrupt buffer -----------------------------------------------------------

    irq_buffering: process(i_clk)
    begin
        if rising_edge(i_clk) then
            s_irq <= i_irq;

            if i_rst = '1' then
                s_irq <= '0';
            end if;
        end if;
    end process irq_buffering;

--- interrupts and jumps -------------------------------------------------------

    s_irq_en <= s_irq and i_cr_ie;
    o_irq_en <= s_irq_en;
    o_cr_ie_we <= s_irq_en or i_mem_iret;
    o_cr_ie <= not s_irq_en;

    s_jmp <= s_irq_en or i_mem_iret or i_mem_jmp_en; -- interrupt is also considered a jump
    o_if_jmp_en <= s_jmp;
    o_if_jmp_addr_mux <= JMP_ADDR_IVEC when s_irq_en = '1' else
                         JMP_ADDR_SPC when i_mem_iret = '1' else
                         JMP_ADDR_ALU;

--- data hazard detection ------------------------------------------------------

    s_reg_a_hazard <= '1' when i_id_reg_a_use = '1' and
                               ((i_ex_reg_c_we = '1' and i_ex_reg_c_index = i_id_reg_a_index) or
                               (i_mem_reg_c_we = '1' and i_mem_reg_c_index = i_id_reg_a_index) or
                               (i_wb_reg_c_we = '1' and i_wb_reg_c_index = i_id_reg_a_index)) else
                      '0';
    s_reg_b_hazard <= '1' when i_id_reg_b_use = '1' and
                               ((i_ex_reg_c_we = '1' and i_ex_reg_c_index = i_id_reg_b_index) or
                               (i_mem_reg_c_we = '1' and i_mem_reg_c_index = i_id_reg_b_index) or
                               (i_wb_reg_c_we = '1' and i_wb_reg_c_index = i_id_reg_b_index)) else
                      '0';

    s_data_hazard <= s_reg_a_hazard or s_reg_b_hazard;

--- pipeline control -----------------------------------------------------------

    s_id_rst <= i_rst or s_jmp;
    s_ex_rst <= i_rst or s_jmp or s_data_hazard;
    s_mem_rst <= i_rst or s_jmp;

    o_id_rst <= s_id_rst;
    o_ex_rst <= s_ex_rst;
    o_mem_rst <= s_mem_rst;

    o_if_stall <= s_data_hazard and not s_jmp;
    o_id_stall <= s_data_hazard;

    update_valid_pcs: process(i_clk)
    begin
        if rising_edge(i_clk) then
            s_valid_pc_id <= '1';
            s_valid_pc_ex <= s_valid_pc_id;
            s_valid_pc_mem <= s_valid_pc_ex;

            if s_id_rst = '1' then
                s_valid_pc_id <= '0';
            end if;

            if s_ex_rst = '1' then
                s_valid_pc_ex <= '0';
            end if;

            if s_mem_rst = '1' then
                s_valid_pc_mem <= '0';
            end if;
        end if;
    end process update_valid_pcs;

    o_spc_mux <= SPC_MEM when s_valid_pc_mem = '1' else -- the least recent PC has priority
                 SPC_EX when s_valid_pc_ex = '1' else
                 SPC_ID when s_valid_pc_id = '1' else
                 SPC_IF; -- IF always has a valid PC

end architecture rtl;
