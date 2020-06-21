----------------------------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    port (
        clk: in std_ulogic;

        a_we: in std_ulogic;
        a_w_index: in std_ulogic_vector(3 downto 0);
        a_w_data: in std_ulogic_vector(63 downto 0);

        a_r_index: in std_ulogic_vector(3 downto 0);
        a_r_data: out std_ulogic_vector(63 downto 0);

        b_index: in std_ulogic_vector(3 downto 0);
        b_data: out std_ulogic_vector(63 downto 0)
    );
end entity reg_file;

architecture rtl of reg_file is
    type registers_t is array (0 to 15) of std_ulogic_vector(63 downto 0);
    signal registers : registers_t;
begin

    a_r_data <= registers(to_integer(unsigned(a_r_index)));
    b_r_data <= registers(to_integer(unsigned(b_r_index)));

    registers_write: process(clk)
    begin
        if rising_edge(clk) then
            if a_we = '1' then
                registers(to_integer(unsigned(a_w_index))) <= a_w_data;
            end if;
        end if;
    end process registers_write;

end architecture rtl;
