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
        0 => "1011000000000000", -- li r0, 0       ; r0 = 0, data pointer
        1 => "1011010000000001", -- li r1, 64      ; r1 = 64
        2 => "1011110000000010", -- li r2, -64     ; r2 = -64
        3 => "00000000--------", -- nop
        4 => "00000000--------", -- nop
        5 => "1110000000000001", -- st r1, r0, 0   ; [r0] = 64
        6 => "1110000100000010", -- st r2, r0, 1   ; [r0 + 1] = -64
        7 => "000001--00000001", -- mv r1, r0      ; r1 = 0
        8 => "000001--00000010", -- mv r2, r0      ; r2 = 0
        9 => "1000000100000000", -- addi r0, 16    ; r0 = 16, 2 dwords = 16 bytes
       10 => "00000000--------", -- nop
       11 => "00000000--------", -- nop
       12 => "00000000--------", -- nop
       13 => "1101111100000001", -- ld r1, r0, -1  ; r1 = -64
       14 => "1101111000000010", -- ld r2, r0, -2  ; r2 = 64
       15 => "1000111100000000", -- addi r0, -16   ; r0 = 0
       16 => "00000000--------", -- nop
       17 => "000001--00010011", -- mv r3, r1      ; r3 = -64
       18 => "000001--00100100", -- mv r4, r2      ; r4 = 64
       19 => "0101100000100001", -- srai r1, 2     ; r1 = -16
       20 => "0101010000100010", -- slli r2, 2     ; r2 = 256
       21 => "00000000--------", -- nop
       22 => "00000000--------", -- nop
       23 => "0011100000010011", -- slt r3, r1     ; r3 = 1
       24 => "0011101000100100", -- sgt r4, r2     ; r4 = 0
       25 => "00000000--------", -- nop
       26 => "00000000--------", -- nop
       27 => "0011010100110001", -- or r1, r3      ; r1 = -15
       28 => "0011010101000010", -- or r2, r4      ; r2 = 256
       29 => "00000000--------", -- nop
       30 => "00000000--------", -- nop
       31 => "1110111000000001", -- st r1, r0, 14  ; [r0 + 14] = -15
       32 => "1110111100000010", -- st r2, r0, 15  ; [r0 + 15] = 256
   others => "00000000--------"  -- nop
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

    drive_input: process
    begin
        i_rst <= '1';
        i_irq <= '0';
        wait for c_CLK_PERIOD;

        i_rst <= '0';
        wait;
    end process drive_input;

    check_output: process
    begin
        for i in 0 to 7 loop
            wait for c_CLK_PERIOD;
            assert o_dmem_we = '0';
            assert o_imem_addr = std_ulogic_vector(to_unsigned(i, o_imem_addr'length));
        end loop;

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(0, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(64, o_dmem_wr_data'length));

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(1, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(-64, o_dmem_wr_data'length));

        for i in 0 to 5 loop
            wait for c_CLK_PERIOD;
            assert o_dmem_we = '0';
        end loop;

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '0';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(1, o_dmem_addr'length));
        assert i_dmem_rd_data = std_ulogic_vector(to_signed(-64, i_dmem_rd_data'length));

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '0';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(0, o_dmem_addr'length));
        assert i_dmem_rd_data = std_ulogic_vector(to_signed(64, i_dmem_rd_data'length));

        for i in 0 to 15 loop
            wait for c_CLK_PERIOD;
            assert o_dmem_we = '0';
        end loop;

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(14, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(-15, o_dmem_wr_data'length));

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(15, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(256, o_dmem_wr_data'length));

        v_done := true; wait;
    end process check_output;

end architecture behavior;
