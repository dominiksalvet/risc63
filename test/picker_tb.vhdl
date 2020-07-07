--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity picker_tb is
end entity picker_tb;

architecture behavior of picker_tb is
    signal i_opcode: std_ulogic_vector(3 downto 0) := (others => '0');
    signal i_data_array: std_ulogic_vector(63 downto 0) := (others => '0');
    signal i_selector: std_ulogic_vector(2 downto 0) := (others => '0');
    signal o_result: std_ulogic_vector(63 downto 0);

    -- configuration
    constant c_CLK_PERIOD: time := 10 ns;
begin

    dut: entity work.picker
    port map (
        i_opcode, i_data_array, i_selector, o_result
    );

    test: process
        constant c_LOW_BYTE: std_ulogic_vector(7 downto 0) := x"ef";
        constant c_LOW_WORD: std_ulogic_vector(15 downto 0) := x"cd" & c_LOW_BYTE;
        constant c_LOW_DWORD: std_ulogic_vector(31 downto 0) := x"89ab" & c_LOW_WORD;
        constant c_QWORD: std_ulogic_vector(63 downto 0) := x"01234567" & c_LOW_DWORD;
    begin

        i_data_array <= c_QWORD; -- permanent input

------- test extract -----------------------------------------------------------

        i_opcode <= c_PICKER_EXTB;
        for i in 0 to 7 loop
            i_selector <= std_ulogic_vector(to_unsigned(i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                resize(signed(c_QWORD(8 * i + 7 downto 8 * i)), o_result'length)
            );
        end loop;

        i_opcode <= c_PICKER_EXTW;
        for i in 0 to 3 loop
            i_selector <= std_ulogic_vector(to_unsigned(2 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                resize(signed(c_QWORD(16 * i + 15 downto 16 * i)), o_result'length)
            );
        end loop;
        -- test unaligned selector
        i_selector <= std_ulogic_vector(to_unsigned(1, i_selector'length));
        wait for c_CLK_PERIOD;
        assert o_result = std_ulogic_vector(
            resize(signed(c_QWORD(15 downto 0)), o_result'length)
        );

        i_opcode <= c_PICKER_EXTD;
        for i in 0 to 1 loop
            i_selector <= std_ulogic_vector(to_unsigned(4 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                resize(signed(c_QWORD(32 * i + 31 downto 32 * i)), o_result'length)
            );
        end loop;

------- test extract unsigned --------------------------------------------------

        i_opcode <= c_PICKER_EXTBU;
        for i in 0 to 7 loop
            i_selector <= std_ulogic_vector(to_unsigned(i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                resize(unsigned(c_QWORD(8 * i + 7 downto 8 * i)), o_result'length)
            );
        end loop;

        i_opcode <= c_PICKER_EXTWU;
        for i in 0 to 3 loop
            i_selector <= std_ulogic_vector(to_unsigned(2 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                resize(unsigned(c_QWORD(16 * i + 15 downto 16 * i)), o_result'length)
            );
        end loop;
        -- test unaligned selector
        i_selector <= std_ulogic_vector(to_unsigned(3, i_selector'length));
        wait for c_CLK_PERIOD;
        assert o_result = std_ulogic_vector(
            resize(unsigned(c_QWORD(31 downto 16)), o_result'length)
        );

        i_opcode <= c_PICKER_EXTDU;
        for i in 0 to 1 loop
            i_selector <= std_ulogic_vector(to_unsigned(4 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                resize(unsigned(c_QWORD(32 * i + 31 downto 32 * i)), o_result'length)
            );
        end loop;

------- test insert ------------------------------------------------------------

        i_opcode <= c_PICKER_INSB;
        for i in 0 to 7 loop
            i_selector <= std_ulogic_vector(to_unsigned(i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                shift_left(resize(unsigned(c_LOW_BYTE), o_result'length), 8 * i)
            );
        end loop;

        i_opcode <= c_PICKER_INSW;
        for i in 0 to 3 loop
            i_selector <= std_ulogic_vector(to_unsigned(2 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                shift_left(resize(unsigned(c_LOW_WORD), o_result'length), 16 * i)
            );
        end loop;
        -- test unaligned selector
        i_selector <= std_ulogic_vector(to_unsigned(5, i_selector'length));
        wait for c_CLK_PERIOD;
        assert o_result = std_ulogic_vector(
            shift_left(resize(unsigned(c_LOW_WORD), o_result'length), 32)
        );

        i_opcode <= c_PICKER_INSD;
        for i in 0 to 1 loop
            i_selector <= std_ulogic_vector(to_unsigned(4 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = std_ulogic_vector(
                shift_left(resize(unsigned(c_LOW_DWORD), o_result'length), 32 * i)
            );
        end loop;

------- test mask --------------------------------------------------------------

        i_opcode <= c_PICKER_MSKB;
        for i in 0 to 7 loop
            i_selector <= std_ulogic_vector(to_unsigned(i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = (c_QWORD and not std_ulogic_vector(
                shift_left(resize(unsigned'(x"ff"), o_result'length), 8 * i)
            ));
        end loop;

        i_opcode <= c_PICKER_MSKW;
        for i in 0 to 3 loop
            i_selector <= std_ulogic_vector(to_unsigned(2 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = (c_QWORD and not std_ulogic_vector(
                shift_left(resize(unsigned'(x"ffff"), o_result'length), 16 * i)
            ));
        end loop;
        -- test unaligned selector
        i_selector <= std_ulogic_vector(to_unsigned(7, i_selector'length));
        wait for c_CLK_PERIOD;
        assert o_result = (c_QWORD and not std_ulogic_vector(
            shift_left(resize(unsigned'(x"ffff"), o_result'length), 48)
        ));

        i_opcode <= c_PICKER_MSKD;
        for i in 0 to 1 loop
            i_selector <= std_ulogic_vector(to_unsigned(4 * i, i_selector'length));
            wait for c_CLK_PERIOD;
            assert o_result = (c_QWORD and not std_ulogic_vector(
                shift_left(resize(unsigned'(x"ffffffff"), o_result'length), 32 * i)
            ));
        end loop;

        wait;
    end process test;

end architecture behavior;
