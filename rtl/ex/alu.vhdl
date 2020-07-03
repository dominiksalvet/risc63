--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.alu_pkg.all;

entity alu is
    port (
        i_opcode: in std_ulogic_vector(4 downto 0);
        i_a_operand: in std_ulogic_vector(63 downto 0);
        i_b_operand: in std_ulogic_vector(63 downto 0);
        o_result: out std_ulogic_vector(63 downto 0)
    );
end entity alu;
