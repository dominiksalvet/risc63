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

------- basic instructions -----------------------------------------------------

                                 -- start:
        0 => "1011000000000000", -- li r0, 0           ; r0 = 0, data pointer
        1 => "1011010000000001", -- li r1, 64          ; r1 = 64
        2 => "1011110000000010", -- li r2, -64         ; r2 = -64
        3 => "1110000000000001", -- st r1, r0, 0       ; [r0] = 64
        4 => "1110000100000010", -- st r2, r0, 1       ; [r0 + 1] = -64
        5 => "000001--00000001", -- mv r1, r0          ; r1 = 0
        6 => "000001--00000010", -- mv r2, r0          ; r2 = 0
        7 => "1000000100000000", -- addi r0, 16        ; r0 = 16, 2 dwords = 16 bytes
        8 => "1101111100000001", -- ld r1, r0, -1      ; r1 = -64
        9 => "1101111000000010", -- ld r2, r0, -2      ; r2 = 64
       10 => "1000111100000000", -- addi r0, -16       ; r0 = 0
       11 => "000001--00010011", -- mv r3, r1          ; r3 = -64
       12 => "000001--00100100", -- mv r4, r2          ; r4 = 64
       13 => "0101100000100001", -- srai r1, 2         ; r1 = -16
       14 => "0101010000100010", -- slli r2, 2         ; r2 = 256
       15 => "0011100000010011", -- slt r3, r1         ; r3 = 1
       16 => "0011101000100100", -- sgt r4, r2         ; r4 = 0
       17 => "0011010100110001", -- or r1, r3          ; r1 = -15
       18 => "0011010101000010", -- or r2, r4          ; r2 = 256
       19 => "000001--00001000", -- mv r8, r0          ; r8 = 0
       20 => "1110110100000000", -- st r0, r0, 13      ; [r0 + 13] = 0
       21 => "1110111000000001", -- st r1, r0, 14      ; [r0 + 14] = -15
       22 => "1110111100000010", -- st r2, r0, 15      ; [r0 + 15] = 256

------ function calls ----------------------------------------------------------

       23 => "1000011010001000", -- addi r8, 104       ; prepare data pointer for function call
       24 => "0111000000101111", -- aipc r15, 2        ; prepare return address
       25 => "0010000010101111", -- jmp SIGN_FUNCTION  ; +175
       26 => "1000000010001000", -- addi r8, 8         ; next data
       27 => "0111000000101111", -- aipc r15, 2
       28 => "0010000010101100", -- jmp SIGN_FUNCTION  ; +172
       29 => "1000000010001000", -- addi r8, 8         ; next data
       30 => "0111000000101111", -- aipc r15, 2
       31 => "0010000010101001", -- jmp SIGN_FUNCTION  ; +169

------ word manipulation -------------------------------------------------------

       32 => "1011000000000000", -- li r0, 0
       33 => "1011000000100001", -- li r1, 2
       34 => "1011000001000010", -- li r2, 4
       35 => "1011000001100011", -- li r3, 6
       36 => "1011001010000100", -- li r4, 40
       37 => "1011110011100101", -- li r5, -50
       38 => "1011001111000110", -- li r6, 60
       39 => "1011101110100111", -- li r7, -70
       40 => "0001100100000100", -- insw r4, r0        ; r4 = 0   0  0   40
       41 => "0001100100010101", -- insw r5, r1        ; r5 = 0   0  -50 0
       42 => "0001100100100110", -- insw r6, r2        ; r6 = 0   60 0   0
       43 => "0001100100110111", -- insw r7, r3        ; r7 = -70 0  0   0
       44 => "0011010101010100", -- or r4, r5          ; r4 = 0   0  -50 40
       45 => "0011010101110110", -- or r6, r7          ; r6 = -70 60 0   0
       46 => "0011010101100100", -- or r4, r6          ; r4 = -70 60 -50 40
       47 => "000001--01001000", -- mv r8, r4
       48 => "1110000000000100", -- st r4, r0, 0
       49 => "0001000100011000", -- extw r8, r1        ; r8 = -50
       50 => "1000011001001000", -- addi r8, 100       ; r8 = 50
       51 => "0001110100010100", -- mskw r4, r1        ; r4 = -70 60 0  40
       52 => "0001100100011000", -- insw r8, r1        ; r8 = 0   0  50 0
       53 => "0011010110000100", -- or r4, r8          ; r4 = -70 60 50 40
       54 => "1110000000000100", -- st r4, r0, 0

----- interrupts ---------------------------------------------------------------

       55 => "1011001011000001", -- li r1, 44
       56 => "1011010000000000", -- li r0, 64          ; data pointer
       57 => "1011000000010010", -- li r2, 1           ; enable interrupts mask
       58 => "1011000000010011", -- li r3, 1           ; event counter
       59 => "1001000000010001", -- addui r1, 1        ; r1 = 300 (150 words = 300 bytes)
       60 => "000011---0110001", -- crw r1, ivec       ; set up interrupt vector
       61 => "000011---0100010", -- crw r2, status     ; enable interrupts
       62 => "1000000000010011", -- addi r3, 1
       63 => "0010000000000010", -- jmp +2
       64 => "1000000000010011", -- addi r3, 1         ; must be skipped even if interrupted
       65 => "1110000000000011", -- st r3, r0, 0

----- loop forever -------------------------------------------------------------

       66 => "0010000000000000", -- jmp +0

----- interrupt handler --------------------------------------------------------

      150 => "000011---0000011", -- crw k0, r3         ; backup
      151 => "1011000000000011", -- li r3, 0           ; clear
      152 => "000010---0000011", -- crr k0, r3         ; read back
      153 => "1111111100000011", -- st r3, r0, -1
      154 => "1000000000010011", -- addi r3, 1         ; increase event counter
      155 => "00000001--------", -- iret               ; return from interrupt

----- sign function ------------------------------------------------------------

                                 -- SIGN_FUNCTION:     ; [r8] -> [r8]
      200 => "1100000010001001", -- ld r9, r8, 0       ; load operand
      201 => "1011000000001011", -- li r11, 0          ; sign function result
      202 => "1011000000011100", -- li r12, 1
      203 => "000001--10011010", -- mv r10, r9
      204 => "0100000000001001", -- slti r9, 0         ; r9 = r9 < 0
      205 => "0100100000001010", -- sgti r10, 0        ; r10 = r10 > 0
      206 => "0110100001001001", -- jnz r9, NEGATIVE   ; +4
      207 => "0110000001001010", -- jz r10, DONE       ; +4
      208 => "0011000011001011", -- add r11, r12       ; greater than zero
      209 => "0010000000000010", -- jmp DONE           ; +2
                                 -- NEGATIVE:
      210 => "0011000111001011", -- sub r11, r12       ; less than zero
                                 -- DONE:
      211 => "1110000010001011", -- st r11, r8, 0      ; store result
      212 => "0111100000001111", -- jr r15, 0          ; return from function

   others => "----------------"  -- the rest are uninitialized
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
        for i in 0 to 3 loop
            wait for c_CLK_PERIOD;
            assert o_dmem_we = '0';
            assert o_imem_addr = std_ulogic_vector(to_unsigned(i, o_imem_addr'length));
        end loop;

        wait for 2 * c_CLK_PERIOD; -- wait for data hazard
        for i in 4 to 5 loop
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

        wait for 16 * c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(13, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(0, o_dmem_wr_data'length));

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(14, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(-15, o_dmem_wr_data'length));

        wait for c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(15, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(256, o_dmem_wr_data'length));

        wait for 4 * c_CLK_PERIOD;
        assert o_dmem_we = '0';
        assert o_imem_addr = std_ulogic_vector(to_unsigned(200, o_imem_addr'length));

        wait for 16 * c_CLK_PERIOD;
        assert o_imem_addr = std_ulogic_vector(to_unsigned(211, o_imem_addr'length));

        wait for 3 * c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(13, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(0, o_dmem_wr_data'length));

        wait for 2 * c_CLK_PERIOD;
        assert o_imem_addr = std_ulogic_vector(to_unsigned(26, o_imem_addr'length));

        wait for 26 * c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(14, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(-1, o_dmem_wr_data'length));

        wait for 29 * c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(15, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(to_signed(1, o_dmem_wr_data'length));

        wait for 29 * c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(0, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(
            to_signed(-70, o_dmem_wr_data'length / 4) &
            to_signed(60, o_dmem_wr_data'length / 4) &
            to_signed(-50, o_dmem_wr_data'length / 4) &
            to_signed(40, o_dmem_wr_data'length / 4)
        );

        wait for 19 * c_CLK_PERIOD;
        assert o_dmem_we = '1';
        assert o_dmem_addr = std_ulogic_vector(to_unsigned(0, o_dmem_addr'length));
        assert o_dmem_wr_data = std_ulogic_vector(
            to_signed(-70, o_dmem_wr_data'length / 4) &
            to_signed(60, o_dmem_wr_data'length / 4) &
            to_signed(50, o_dmem_wr_data'length / 4) &
            to_signed(40, o_dmem_wr_data'length / 4)
        );

        v_done := true; wait;
    end process check_output;

end architecture behavior;
