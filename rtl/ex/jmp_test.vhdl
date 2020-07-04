--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity jmp_test is
    port (
        i_jmp_cond: in t_jmp_cond;
        i_data: in std_ulogic_vector(63 downto 0);
        o_jmp_en: out std_ulogic
    );
end entity jmp_test;

architecture rtl of jmp_test is
    signal s_is_zero: std_ulogic;
begin

    s_is_zero <= '1' when i_data = (i_data'range => '0') else '0';

    with i_jmp_cond select o_jmp_en <=
        '1' when JMP_ALWAYS,
        s_is_zero when JMP_ZERO,
        not s_is_zero when JMP_NZERO,
        '0' when JMP_NEVER;

end architecture rtl;
