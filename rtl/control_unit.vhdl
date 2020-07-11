--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity control_unit is
    port (
        i_rst: in std_ulogic;
        i_mem_jmp_en: in std_ulogic;
        i_mem_iret: in std_ulogic;

        o_if_jmp_en: out std_ulogic;
        o_if_jmp_addr_mux: out t_jmp_addr_mux;
        o_id_rst: out std_ulogic;
        o_ex_rst: out std_ulogic;
        o_mem_rst: out std_ulogic
    );
end entity control_unit;

architecture rtl of control_unit is
    signal s_jmp: std_ulogic;
begin

    s_jmp <= i_mem_jmp_en or i_mem_iret; -- any control flow

    o_if_jmp_en <= s_jmp;
    o_if_jmp_addr_mux <= JMP_ADDR_ALU when i_mem_jmp_en = '1' else JMP_ADDR_SPC;

    o_id_rst <= i_rst or s_jmp;
    o_ex_rst <= i_rst or s_jmp;
    o_mem_rst <= i_rst or s_jmp;

end architecture rtl;
