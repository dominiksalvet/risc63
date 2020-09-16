--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity adder_tb is
end entity adder_tb;

architecture behavior of adder_tb is
    signal i_mode: t_adder_mode;
    signal i_a: std_ulogic_vector(63 downto 0);
    signal i_b: std_ulogic_vector(63 downto 0);
    signal o_less: std_ulogic;
    signal o_less_unsigned: std_ulogic;
    signal o_result: std_ulogic_vector(63 downto 0);

    -- auxiliary functions
    function f_slt(a, b: signed) return std_ulogic is
    begin
        if a < b then
            return '1';
        else
            return '0';
        end if;
    end function f_slt;

    function f_sltu(a, b: unsigned) return std_ulogic is
    begin
        if a < b then
            return '1';
        else
            return '0';
        end if;
    end function f_sltu;

    -- configuration
    constant c_CLK_PERIOD: time := 10 ns;
begin

    m_adder: entity work.adder
    port map (
        i_mode,
        i_a,
        i_b,
        o_less,
        o_less_unsigned,
        o_result
    );

    test: process
        type t_values is array(0 to 6) of signed(63 downto 0);
        constant c_VALUES: t_values := (
            x"fffc72815b398000", -- -1000000000000000
            x"fffffffdabf41c00", -- -10000000000
            x"fffffffffffe7960", -- -100000
            x"0000000000000000", -- 0
            x"00000000000186a0", -- 100000
            x"00000002540be400", -- 10000000000
            x"00038d7ea4c68000" -- 1000000000000000
        );
    begin
------- test addition ----------------------------------------------------------

        i_mode <= ADDER_ADD;
        for i in c_VALUES'range loop
            i_a <= std_ulogic_vector(c_VALUES(i));
            for j in c_VALUES'range loop
                i_b <= std_ulogic_vector(c_VALUES(j));
                wait for c_CLK_PERIOD;
                assert o_result = std_ulogic_vector(c_VALUES(i) + c_VALUES(j));
            end loop;
        end loop;

------- test subtraction -------------------------------------------------------

        i_mode <= ADDER_SUB;
        for i in c_VALUES'range loop
            i_a <= std_ulogic_vector(c_VALUES(i));
            for j in c_VALUES'range loop
                i_b <= std_ulogic_vector(c_VALUES(j));
                wait for c_CLK_PERIOD;
                assert o_result = std_ulogic_vector(c_VALUES(i) - c_VALUES(j));
            end loop;
        end loop;

        i_mode <= ADDER_RSB; -- reverse subtraction
        for i in c_VALUES'range loop
            i_a <= std_ulogic_vector(c_VALUES(i));
            for j in c_VALUES'range loop
                i_b <= std_ulogic_vector(c_VALUES(j));
                wait for c_CLK_PERIOD;
                assert o_result = std_ulogic_vector(c_VALUES(j) - c_VALUES(i));
            end loop;
        end loop;

------- test compare -----------------------------------------------------------

        i_mode <= ADDER_SUB;
        for i in c_VALUES'range loop
            i_a <= std_ulogic_vector(c_VALUES(i));
            for j in c_VALUES'range loop
                i_b <= std_ulogic_vector(c_VALUES(j));
                wait for c_CLK_PERIOD;
                assert o_less = f_slt(c_VALUES(i), c_VALUES(j));
                assert o_less_unsigned = f_sltu(
                    unsigned(c_VALUES(i)), unsigned(c_VALUES(j))
                );
            end loop;
        end loop;

        i_mode <= ADDER_RSB; -- reverse compare
        for i in c_VALUES'range loop
            i_a <= std_ulogic_vector(c_VALUES(i));
            for j in c_VALUES'range loop
                i_b <= std_ulogic_vector(c_VALUES(j));
                wait for c_CLK_PERIOD;
                assert o_less = f_slt(c_VALUES(j), c_VALUES(i));
                assert o_less_unsigned = f_sltu(
                    unsigned(c_VALUES(j)), unsigned(c_VALUES(i))
                );
            end loop;
        end loop;

        wait;
    end process test;

end architecture behavior;
