--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity risc63 is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

        -- instruction memory interface
        o_imem_addr: out std_ulogic_vector(62 downto 0);
        i_imem_data: in std_ulogic_vector(15 downto 0);

        -- data memory interface
        o_dmem_we: out std_ulogic;
        o_dmem_addr: out std_ulogic_vector(60 downto 0);
        o_dmem_data: out std_ulogic_vector(63 downto 0);
        i_dmem_data: in std_ulogic_vector(63 downto 0)
    );
end entity risc63;
