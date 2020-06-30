--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity id_stage is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

        i_inst: in std_ulogic_vector(15 downto 0);

        i_pc: in std_ulogic_vector(62 downto 0)
    );
end entity id_stage;
