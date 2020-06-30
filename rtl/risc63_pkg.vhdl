--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package risc63_pkg is
    -- value of PC after reset
    constant c_PC_RST: std_ulogic_vector(62 downto 0) := (others => '0');
end package risc63_pkg;
