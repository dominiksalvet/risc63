--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity risc63_tb is
end entity risc63_tb;

architecture behavior of risc63_tb is
    signal i_clk: std_ulogic := '0';
    signal i_rst: std_ulogic := '0';
    signal i_irq: std_ulogic := '0';
    signal o_imem_addr: std_ulogic_vector(62 downto 0);
    signal i_imem_rd_data: std_ulogic_vector(15 downto 0) := c_NOP_INST;
    signal o_dmem_we: std_ulogic;
    signal o_dmem_addr: std_ulogic_vector(60 downto 0);
    signal o_dmem_wr_data: std_ulogic_vector(63 downto 0);
    signal i_dmem_rd_data: std_ulogic_vector(63 downto 0) := (others => '0');

    -- configuration
    constant c_CLK_PERIOD: time := 10 ns;
    shared variable v_done: boolean := false;
begin

    risc63: entity work.risc63
    port map (
        i_clk,
        i_rst,
        i_irq,
        o_imem_addr,
        i_imem_rd_data,
        o_dmem_we,
        o_dmem_addr,
        o_dmem_wr_data,
        i_dmem_rd_data
    );

    clk_gen: process
    begin
        while not v_done loop
            i_clk <= '0'; wait for c_CLK_PERIOD / 2;
            i_clk <= '1'; wait for c_CLK_PERIOD / 2;
        end loop; wait;
    end process clk_gen;

    test: process
    begin
        i_rst <= '1';
        wait for c_CLK_PERIOD;

        i_rst <= '0';
        wait for c_CLK_PERIOD;

        v_done := true; wait;
    end process test;

end architecture behavior;
