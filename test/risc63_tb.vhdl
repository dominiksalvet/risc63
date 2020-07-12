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
    signal i_rst: std_ulogic;
    signal i_irq: std_ulogic;
    signal o_imem_addr: std_ulogic_vector(62 downto 0);
    signal i_imem_rd_data: std_ulogic_vector(15 downto 0);
    signal o_dmem_we: std_ulogic;
    signal o_dmem_addr: std_ulogic_vector(60 downto 0);
    signal o_dmem_wr_data: std_ulogic_vector(63 downto 0);
    signal i_dmem_rd_data: std_ulogic_vector(63 downto 0);

--- instruction memory ---------------------------------------------------------
    constant c_IMEM_ADDR_WIDTH: integer := 8;
    constant c_IMEM_MAX_ADDR: integer := (integer'(2) ** c_IMEM_ADDR_WIDTH) - 1;
    constant c_IMEM_ADDR_MSB: integer := c_IMEM_ADDR_WIDTH - 1;

    type t_imem is array(0 to c_IMEM_MAX_ADDR) of std_ulogic_vector(15 downto 0);
    -- test program that uses as many instruction types as possible
    signal s_imem: t_imem := (
        others => c_NOP_INST
    );

--- data memory ----------------------------------------------------------------
    constant c_DMEM_ADDR_WIDTH: integer := 6;
    constant c_DMEM_MAX_ADDR: integer := (integer'(2) ** c_DMEM_ADDR_WIDTH) - 1;
    constant c_DMEM_ADDR_MSB: integer := c_DMEM_ADDR_WIDTH - 1;

    -- addressed from 0 as well (possible due to harvard architecture)
    type t_dmem is array(0 to c_DMEM_MAX_ADDR) of std_ulogic_vector(63 downto 0);
    signal s_dmem: t_dmem; -- uninitialized

--------------------------------------------------------------------------------

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

--- instruction memory ---------------------------------------------------------

    i_imem_rd_data <= s_imem(to_integer(unsigned(o_imem_addr(c_IMEM_ADDR_MSB downto 0))));

--- data memory ----------------------------------------------------------------

    dmem_write: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if o_dmem_we = '1' then
                s_dmem(to_integer(unsigned(
                    o_dmem_addr(c_DMEM_ADDR_MSB downto 0)
                ))) <= o_dmem_wr_data;
            end if;
        end if;
    end process dmem_write;

    i_dmem_rd_data <= s_dmem(to_integer(unsigned(o_dmem_addr(c_DMEM_ADDR_MSB downto 0))));

--------------------------------------------------------------------------------

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
        i_irq <= '0';
        wait for c_CLK_PERIOD;

        i_rst <= '0';
        wait for c_CLK_PERIOD;

        v_done := true; wait;
    end process test;

end architecture behavior;
