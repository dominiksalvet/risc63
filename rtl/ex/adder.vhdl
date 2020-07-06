--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity adder is
    port (
        i_mode: in t_adder_mode;
        i_a: in std_ulogic_vector(63 downto 0);
        i_b: in std_ulogic_vector(63 downto 0);

        o_less: out std_ulogic;
        o_less_unsigned: out std_ulogic;
        o_result: out std_ulogic_vector(63 downto 0)
    );
end entity adder;

architecture rtl of adder is
    signal s_invert_a: std_ulogic;
    signal s_invert_b: std_ulogic;

    -- intermediate adder signals
    signal s_a: std_ulogic_vector(63 downto 0);
    signal s_b: std_ulogic_vector(63 downto 0);
    signal s_cin: std_ulogic;
    signal s_result: std_ulogic_vector(64 downto 0); -- includes carry out
begin

    -- invert A or B if needed
    s_invert_a <= '1' when i_mode = ADDER_RSB else '0';
    s_invert_b <= '1' when i_mode = ADDER_SUB else '0';
    s_a <= i_a xor (63 downto 0 => s_invert_a);
    s_b <= i_b xor (63 downto 0 => s_invert_b);

    -- if not adding, a subtraction is performed
    s_cin <= '0' when i_mode = ADDER_ADD else '1';

    -- universal adder
    s_result <= std_ulogic_vector(
        unsigned('0' & s_a) +
        unsigned('0' & s_b) +
        (0 => s_cin) -- carry in (array of std_ulogic, implicit conversion)
    );

    -- assign final outputs
    o_less <= not s_result(64) when i_a(63) = i_b(63) else -- when signs are equal
              i_a(63) when i_mode = ADDER_SUB else -- if subtract and A is negative, then it is less
              i_b(63); -- for reverse subtract uses
    o_less_unsigned <= not s_result(64);

    o_result <= s_result(o_result'range); -- use only relevant bits

end architecture rtl;
