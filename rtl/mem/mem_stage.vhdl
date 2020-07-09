--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity mem_stage is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

------- input from EX stage ----------------------------------------------------
        i_jmp_en: in std_ulogic;
        i_iret: in std_ulogic;

        i_mem_we: in std_ulogic;
        i_mem_wr_data: in std_ulogic_vector(63 downto 0);
        i_cr_we: in std_ulogic;
        i_cr_index: in std_ulogic_vector(2 downto 0);
        i_reg_c_we: in std_ulogic;
        i_reg_c_index: in std_ulogic_vector(3 downto 0);

        i_result_mux: in t_result_mux;
        i_alu_result: in std_ulogic_vector(63 downto 0);

------- control unit signals ---------------------------------------------------
        o_jmp_en: out std_ulogic;
        o_iret: out std_ulogic;

------- data memory interface --------------------------------------------------
        -- ALU result has to be used as memory address
        o_mem_we: out std_ulogic;
        o_mem_wr_data: out std_ulogic_vector(63 downto 0);

------- control registers interface --------------------------------------------
        -- ALU result has to be used as input data
        o_cr_we: out std_ulogic;
        o_cr_index: out std_ulogic_vector(2 downto 0);

------- output to WB stage -----------------------------------------------------
        o_reg_c_we: out std_ulogic;
        o_reg_c_index: out std_ulogic_vector(3 downto 0);

        o_result_mux: out t_result_mux;
        o_alu_result: out std_ulogic_vector(63 downto 0)
    );
end entity mem_stage;

architecture rtl of mem_stage is
begin

    catch_input: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_jmp_en <= '0';
                o_iret <= '0';
                o_mem_we <= '0';
                o_cr_we <= '0';
                o_reg_c_we <= '0';
            else
                o_jmp_en <= i_jmp_en;
                o_iret <= i_iret;
                o_mem_we <= i_mem_we;
                o_mem_wr_data <= i_mem_wr_data;
                o_cr_we <= i_cr_we;
                o_cr_index <= i_cr_index;
                o_reg_c_we <= i_reg_c_we;
                o_reg_c_index <= i_reg_c_index;
                o_result_mux <= i_result_mux;
                o_alu_result <= i_alu_result;
            end if;
        end if;
    end process catch_input;

end architecture rtl;
