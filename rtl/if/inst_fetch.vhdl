--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity inst_fetch is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

        i_jmp_en: in std_ulogic;
        i_jmp_addr: in std_ulogic_vector(62 downto 0);

        o_inst_addr: out std_ulogic_vector(62 downto 0)
    );
end entity inst_fetch;

architecture rtl of inst_fetch is
    signal s_pc: std_ulogic_vector(62 downto 0);
begin

    next_inst_addr: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_pc <= c_PC_RST;
            elsif i_jmp_en = '1' then
                s_pc <= i_jmp_addr;
            else
                s_pc <= std_ulogic_vector(unsigned(s_pc) + 1);
            end if;
        end if;
    end process next_inst_addr;

    o_inst_addr <= s_pc;

end architecture rtl;
