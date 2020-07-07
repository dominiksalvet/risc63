--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file_tb is
end entity reg_file_tb;

architecture behavior of reg_file_tb is
    signal i_clk: std_ulogic := '0';

    -- read port A
    signal i_a_index: std_ulogic_vector(3 downto 0) := (others => '0');
    signal o_a_data: std_ulogic_vector(63 downto 0);

    -- read port B
    signal i_b_index: std_ulogic_vector(3 downto 0) := (others => '0');
    signal o_b_data: std_ulogic_vector(63 downto 0);

    -- write port C
    signal i_c_we: std_ulogic := '0';
    signal i_c_index: std_ulogic_vector(3 downto 0) := (others => '0');
    signal i_c_data: std_ulogic_vector(63 downto 0) := (others => '0');

    -- configuration
    constant c_CLK_PERIOD: time := 10 ns;
    shared variable v_done: boolean := false;
begin

    dut: entity work.reg_file
    port map (
        i_clk,
        i_a_index, o_a_data,
        i_b_index, o_b_data,
        i_c_we, i_c_index, i_c_data
    );

    clk_gen: process
    begin
        while not v_done loop
            i_clk <= '0'; wait for c_CLK_PERIOD / 2;
            i_clk <= '1'; wait for c_CLK_PERIOD / 2;
        end loop; wait;
    end process clk_gen;

    test: process
        constant c_DATA: unsigned(63 downto 0) := (3 downto 0 => '1', others => '0');
    begin
        wait for c_CLK_PERIOD;

        -- write to registers
        i_c_we <= '1';
        for i in 0 to 15 loop
            i_c_index <= std_ulogic_vector(to_unsigned(i, i_c_index'length));
            i_c_data <= std_ulogic_vector(shift_left(c_DATA, 4 * i));
            wait for c_CLK_PERIOD;
        end loop;
        i_c_we <= '0';

        -- read from registers
        for i in 0 to 15 loop
            i_b_index <= std_ulogic_vector(to_unsigned(i, i_b_index'length));
            i_a_index <= std_ulogic_vector(to_unsigned(15 - i, i_a_index'length));
            wait for c_CLK_PERIOD / 4; -- delta delay
            assert o_b_data = std_ulogic_vector(shift_left(c_DATA, 4 * i));
            assert o_a_data = std_ulogic_vector(shift_left(c_DATA, 4 * (15 - i)));
            wait for c_CLK_PERIOD - c_CLK_PERIOD / 4;
        end loop;

        v_done := true; wait;
    end process test;

end architecture behavior;
