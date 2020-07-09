--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.risc63_pkg.all;

entity picker is
    port (
        i_opcode: in std_ulogic_vector(3 downto 0); -- picker opcode
        i_data_array: in std_ulogic_vector(63 downto 0);
        i_selector: in std_ulogic_vector(2 downto 0);
        o_result: out std_ulogic_vector(63 downto 0)
    );
end entity picker;

architecture rtl of picker is
    -- individual data sizes
    type t_byte_array is array (7 downto 0) of std_ulogic_vector(7 downto 0);
    type t_word_array is array (3 downto 0) of std_ulogic_vector(15 downto 0);
    type t_dword_array is array (1 downto 0) of std_ulogic_vector(31 downto 0);

    -- transform input into individual arrays
    signal s_byte_array: t_byte_array;
    signal s_word_array: t_word_array;
    signal s_dword_array: t_dword_array;

    -- indexes for each data size
    signal s_byte_index: integer range 0 to 7;
    signal s_word_index: integer range 0 to 3;
    signal s_dword_index: integer range 0 to 1;

    -- raw extracted data
    signal s_ext_byte: std_ulogic_vector(7 downto 0);
    signal s_ext_word: std_ulogic_vector(15 downto 0);
    signal s_ext_dword: std_ulogic_vector(31 downto 0);

    -- final inserted data
    signal s_ins_byte: std_ulogic_vector(63 downto 0);
    signal s_ins_word: std_ulogic_vector(63 downto 0);
    signal s_ins_dword: std_ulogic_vector(63 downto 0);

    -- final masked data
    signal s_msk_byte: std_ulogic_vector(63 downto 0);
    signal s_msk_word: std_ulogic_vector(63 downto 0);
    signal s_msk_dword: std_ulogic_vector(63 downto 0);
begin

    -- prepare input
    s_byte_array <= (
        i_data_array(63 downto 56), -- index 7
        i_data_array(55 downto 48),
        i_data_array(47 downto 40),
        i_data_array(39 downto 32),
        i_data_array(31 downto 24),
        i_data_array(23 downto 16),
        i_data_array(15 downto 8),
        i_data_array(7 downto 0) -- index 0
    );
    s_word_array <= (
        i_data_array(63 downto 48), -- index 3
        i_data_array(47 downto 32),
        i_data_array(31 downto 16),
        i_data_array(15 downto 0) -- index 0
    );
    s_dword_array <= (
        i_data_array(63 downto 32), -- index 1
        i_data_array(31 downto 0) -- index 0
    );

    s_byte_index <= to_integer(unsigned(i_selector));
    s_word_index <= to_integer(unsigned(i_selector(2 downto 1)));
    s_dword_index <= to_integer(unsigned'(0 => i_selector(2)));

    s_ext_byte <= s_byte_array(s_byte_index);
    s_ext_word <= s_word_array(s_word_index);
    s_ext_dword <= s_dword_array(s_dword_index);

    insert_data: process(s_byte_index, s_word_index, s_dword_index, i_data_array)
        variable v_ins_byte_array: t_byte_array;
        variable v_ins_word_array: t_word_array;
        variable v_ins_dword_array: t_dword_array;
    begin
        v_ins_byte_array := (others => (others => '0'));
        v_ins_word_array := (others => (others => '0'));
        v_ins_dword_array := (others => (others => '0'));

        v_ins_byte_array(s_byte_index) := i_data_array(7 downto 0);
        v_ins_word_array(s_word_index) := i_data_array(15 downto 0);
        v_ins_dword_array(s_dword_index) := i_data_array(31 downto 0);

        s_ins_byte <= v_ins_byte_array(7) & v_ins_byte_array(6) &
                      v_ins_byte_array(5) & v_ins_byte_array(4) &
                      v_ins_byte_array(3) & v_ins_byte_array(2) &
                      v_ins_byte_array(1) & v_ins_byte_array(0);
        s_ins_word <= v_ins_word_array(3) & v_ins_word_array(2) &
                      v_ins_word_array(1) & v_ins_word_array(0);
        s_ins_dword <= v_ins_dword_array(1) & v_ins_dword_array(0);
    end process insert_data;

    mask_data: process(s_byte_array, s_word_array, s_dword_array,
                       s_byte_index, s_word_index, s_dword_index)
        variable v_msk_byte_array: t_byte_array;
        variable v_msk_word_array: t_word_array;
        variable v_msk_dword_array: t_dword_array;
    begin
        v_msk_byte_array := s_byte_array;
        v_msk_word_array := s_word_array;
        v_msk_dword_array := s_dword_array;

        v_msk_byte_array(s_byte_index) := (others => '0');
        v_msk_word_array(s_word_index) := (others => '0');
        v_msk_dword_array(s_dword_index) := (others => '0');

        s_msk_byte <= v_msk_byte_array(7) & v_msk_byte_array(6) &
                      v_msk_byte_array(5) & v_msk_byte_array(4) &
                      v_msk_byte_array(3) & v_msk_byte_array(2) &
                      v_msk_byte_array(1) & v_msk_byte_array(0);
        s_msk_word <= v_msk_word_array(3) & v_msk_word_array(2) &
                      v_msk_word_array(1) & v_msk_word_array(0);
        s_msk_dword <= v_msk_dword_array(1) & v_msk_dword_array(0);
    end process mask_data;

    with i_opcode select o_result <=
        (55 downto 0 => s_ext_byte(7)) & s_ext_byte when c_PICKER_EXTB,
        (47 downto 0 => s_ext_word(15)) & s_ext_word when c_PICKER_EXTW,
        (31 downto 0 => s_ext_dword(31)) & s_ext_dword when c_PICKER_EXTD,
        (55 downto 0 => '0') & s_ext_byte when c_PICKER_EXTBU,
        (47 downto 0 => '0') & s_ext_word when c_PICKER_EXTWU,
        (31 downto 0 => '0') & s_ext_dword when c_PICKER_EXTDU,
        s_ins_byte when c_PICKER_INSB,
        s_ins_word when c_PICKER_INSW,
        s_ins_dword when c_PICKER_INSD,
        s_msk_byte when c_PICKER_MSKB,
        s_msk_word when c_PICKER_MSKW,
        s_msk_dword when c_PICKER_MSKD,
        (others => 'X') when others;

end architecture rtl;
