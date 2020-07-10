--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        i_rst: in std_ulogic;
        i_jmp_en: in std_ulogic;

        o_id_rst: out std_ulogic;
        o_ex_rst: out std_ulogic;
        o_mem_rst: out std_ulogic
    );
end entity control_unit;

architecture rtl of control_unit is
begin

    o_id_rst <= i_rst or i_jmp_en;
    o_ex_rst <= i_rst or i_jmp_en;
    o_mem_rst <= i_rst or i_jmp_en;

end architecture rtl;
