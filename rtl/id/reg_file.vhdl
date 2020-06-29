--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    port (
        i_clk: in std_ulogic;

        -- write port A
        i_a_we: in std_ulogic;
        i_a_index: in std_ulogic_vector(3 downto 0);
        i_a_data: in std_ulogic_vector(63 downto 0);

        -- read port B
        i_b_index: in std_ulogic_vector(3 downto 0);
        o_b_data: out std_ulogic_vector(63 downto 0);

        -- read port C
        i_c_index: in std_ulogic_vector(3 downto 0);
        o_c_data: out std_ulogic_vector(63 downto 0)
    );
end entity reg_file;

architecture rtl of reg_file is
    type t_registers is array (0 to 15) of std_ulogic_vector(63 downto 0);
    signal s_registers: t_registers;
begin

    -- asynchronous register read
    o_b_data <= s_registers(to_integer(unsigned(i_b_index)));
    o_c_data <= s_registers(to_integer(unsigned(i_c_index)));

    registers_write: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_a_we = '1' then
                s_registers(to_integer(unsigned(i_a_index))) <= i_a_data;
            end if;
        end if;
    end process registers_write;

end architecture rtl;
