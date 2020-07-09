--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity wb_stage is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

------- input from MEM stage ---------------------------------------------------
        i_reg_c_we: in std_ulogic;
        i_reg_c_index: in std_ulogic_vector(3 downto 0);

        i_result_mux: in t_result_mux;
        i_mem_rd_data: in std_ulogic_vector(63 downto 0);
        i_cr_rd_data: in std_ulogic_vector(63 downto 0);
        i_alu_result: in std_ulogic_vector(63 downto 0);

------- output to ID stage -----------------------------------------------------
        o_reg_c_we: out std_ulogic;
        o_reg_c_index: out std_ulogic_vector(3 downto 0);
        o_reg_c_data: out std_ulogic_vector(63 downto 0)
    );
end entity wb_stage;

architecture rtl of wb_stage is
    -- stage registers
    signal s_result_mux: t_result_mux;
    signal s_mem_rd_data: std_ulogic_vector(63 downto 0);
    signal s_cr_rd_data: std_ulogic_vector(63 downto 0);
    signal s_alu_result: std_ulogic_vector(63 downto 0);
begin

    catch_input: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_reg_c_we <= '0';
            else
                s_result_mux <= i_result_mux;
                s_mem_rd_data <= i_mem_rd_data;
                s_cr_rd_data <= i_cr_rd_data;
                s_alu_result <= i_alu_result;
            end if;
        end if;
    end process catch_input;

    with s_result_mux select o_reg_c_data <=
        s_mem_rd_data when RESULT_MEM,
        s_cr_rd_data when RESULT_CR,
        s_alu_result when RESULT_ALU;

end architecture rtl;
