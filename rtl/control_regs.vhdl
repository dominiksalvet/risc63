--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity control_regs is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

------- standard interface -----------------------------------------------------
        i_we: in std_ulogic;
        i_index: in std_ulogic_vector(2 downto 0);
        i_wr_data: in std_ulogic_vector(63 downto 0);
        o_rd_data: out std_ulogic_vector(63 downto 0);

------- individual writes ------------------------------------------------------
        i_ie_we: in std_ulogic;
        i_ie: in std_ulogic;
        i_spc_we: in std_ulogic;
        i_spc: in std_ulogic_vector(62 downto 0);

------- individual reads -------------------------------------------------------
        o_ie: out std_ulogic;
        o_ivec: out std_ulogic_vector(62 downto 0);
        o_spc: out std_ulogic_vector(62 downto 0)
    );
end entity control_regs;

architecture rtl of control_regs is
    -- real registers
    signal s_k0, s_k1: std_ulogic_vector(63 downto 0);
    signal s_ie: std_ulogic; -- status register
    signal s_ivec: std_ulogic_vector(62 downto 0);
    signal s_spc: std_ulogic_vector(62 downto 0);
begin

    -- standard interface read
    with i_index select o_rd_data <=
        s_k0 when c_CR_K0,
        s_k1 when c_CR_K1,
        (62 downto 0 => '0') & s_ie when c_CR_STATUS,
        s_ivec & '0' when c_CR_IVEC,
        s_spc & '0' when c_CR_SPC,
        (others => 'X') when others;

    registers_write: process(i_clk)
    begin
        if rising_edge(i_clk) then
            -- standard interface write
            if i_we = '1' then
                case i_index is
                    when c_CR_K0 => s_k0 <= i_wr_data;
                    when c_CR_K1 => s_k1 <= i_wr_data;
                    when c_CR_STATUS => s_ie <= i_wr_data(0);
                    when c_CR_IVEC => s_ivec <= i_wr_data(63 downto 1);
                    when c_CR_SPC => s_spc <= i_wr_data(63 downto 1);
                    when others => null;
                end case;
            end if;

            -- individual writes
            if i_ie_we = '1' then
                s_ie <= i_ie;
            end if;
            if i_spc_we = '1' then
                s_spc <= i_spc;
            end if;

            if i_rst = '1' then
                s_ie <= '0';
            end if;
        end if;
    end process registers_write;

    -- individual reads
    o_ie <= s_ie;
    o_ivec <= s_ivec;
    o_spc <= s_spc;

end architecture rtl;
