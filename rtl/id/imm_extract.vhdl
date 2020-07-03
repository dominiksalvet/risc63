--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.imm_extract_pkg.all;

entity imm_extract is
    port (
        i_opcode: in std_ulogic_vector(2 downto 0);
        i_data: in std_ulogic_vector(12 downto 0); -- lower part of instruction
        o_data: out std_ulogic_vector(63 downto 0)
    );
end entity imm_extract;

architecture rtl of imm_extract is
begin

    with i_opcode select o_data <=
        (58 downto 0 => i_data(12)) & i_data(12 downto 8) when c_IEXT_LD,
        (55 downto 0 => i_data(11)) & i_data(11 downto 4) when c_IEXT_ADDI,
        (56 downto 0 => i_data(10)) & i_data(10 downto 4) when c_IEXT_JZ,
        (57 downto 0 => i_data(9)) & i_data(9 downto 4) when c_IEXT_SLTI,
        (51 downto 0 => i_data(11)) & i_data(11 downto 0) when c_IEXT_JMP,
        (others => 'x') when others;

end architecture rtl;
