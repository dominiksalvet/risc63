--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity control_regs is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

        i_we: in std_ulogic;
        i_index: in std_ulogic_vector(2 downto 0);
        i_wr_data: in std_ulogic_vector(63 downto 0);
        o_rd_data: out std_ulogic_vector(63 downto 0)
    );
end entity control_regs;

architecture rtl of control_regs is
    -- register indexes
    constant c_K0_INDEX: std_ulogic_vector(2 downto 0) := "000";
    constant c_K1_INDEX: std_ulogic_vector(2 downto 0) := "001";
    constant c_STATUS_INDEX: std_ulogic_vector(2 downto 0) := "010";
    constant c_IVEC_INDEX: std_ulogic_vector(2 downto 0) := "011";
    constant c_SPC_INDEX: std_ulogic_vector(2 downto 0) := "100";

    -- real registers
    signal s_k0, s_k1: std_ulogic_vector(63 downto 0);
    signal s_ie: std_ulogic; -- status register
    signal s_ivec: std_ulogic_vector(62 downto 0);
    signal s_spc: std_ulogic_vector(62 downto 0);
begin

    with i_index select o_rd_data <=
        s_k0 when c_K0_INDEX,
        s_k1 when c_K1_INDEX,
        (62 downto 0 => '0') & s_ie when c_STATUS_INDEX,
        s_ivec & '0' when c_IVEC_INDEX,
        s_spc & '0' when c_SPC_INDEX,
        (others => 'X') when others;

    registers_write: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_we = '1' then
                case i_index is
                    when c_K0_INDEX => s_k0 <= i_wr_data;
                    when c_K1_INDEX => s_k1 <= i_wr_data;
                    when c_STATUS_INDEX => s_ie <= i_wr_data(0);
                    when c_IVEC_INDEX => s_ivec <= i_wr_data(63 downto 1);
                    when c_SPC_INDEX => s_spc <= i_wr_data(63 downto 1);
                    when others => null;
                end case;
            end if;

            if i_rst = '1' then
                s_ie <= '0';
            end if;
        end if;
    end process registers_write;

end architecture rtl;
