--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity imm_extract is
    port (
        i_type: in t_iext_type;
        i_imm_field: in std_ulogic_vector(12 downto 0); -- lower part of instruction
        o_imm: out std_ulogic_vector(63 downto 0)
    );
end entity imm_extract;

architecture rtl of imm_extract is
begin

    with i_type select o_imm <=
        (55 downto 0 => i_imm_field(12)) & i_imm_field(12 downto 8) & "000" when IEXT_LD,
        (55 downto 0 => i_imm_field(10)) & i_imm_field(10 downto 4) & '0' when IEXT_JZ,
        (57 downto 0 => i_imm_field(9)) & i_imm_field(9 downto 4) when IEXT_SLTI,
        (50 downto 0 => i_imm_field(11)) & i_imm_field(11 downto 0) & '0' when IEXT_JMP,
        (55 downto 0 => i_imm_field(11)) & i_imm_field(11 downto 4) when IEXT_ADDI,
        (47 downto 0 => i_imm_field(11)) & i_imm_field(11 downto 4) & "00000000" when IEXT_ADDUI;

end architecture rtl;
