--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity id_stage is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;
        i_stall: in std_ulogic;

------- input from IF stage ----------------------------------------------------
        i_inst: in std_ulogic_vector(15 downto 0); -- instruction fetched from memory
        i_pc: in std_ulogic_vector(62 downto 0); -- its address

------- register file interface ------------------------------------------------
        o_reg_a_use: out std_ulogic;
        o_reg_a_index: out std_ulogic_vector(3 downto 0);
        i_reg_a_data: in std_ulogic_vector(63 downto 0);

        o_reg_b_use: out std_ulogic;
        o_reg_b_index: out std_ulogic_vector(3 downto 0);
        i_reg_b_data: in std_ulogic_vector(63 downto 0);

------- output to EX stage -----------------------------------------------------
        o_alu_opcode: out std_ulogic_vector(4 downto 0);
        o_alu_a_operand: out std_ulogic_vector(63 downto 0);
        o_alu_b_operand: out std_ulogic_vector(63 downto 0);

        o_jmp_cond: out t_jmp_cond;
        o_iret: out std_ulogic;
        o_pc: out std_ulogic_vector(62 downto 0);
        o_pc_valid: out std_ulogic;

        o_mem_we: out std_ulogic;
        o_reg_a_data: out std_ulogic_vector(63 downto 0); -- used by stores and conditional jumps
        o_cr_we: out std_ulogic; -- control registers related
        o_cr_index: out std_ulogic_vector(2 downto 0);
        o_reg_c_we: out std_ulogic; -- write result from WB stage later
        o_reg_c_index: out std_ulogic_vector(3 downto 0);

        o_result_mux: out t_result_mux
    );
end entity id_stage;

architecture rtl of id_stage is
    -- stage registers
    signal s_ir: std_ulogic_vector(15 downto 0);
    signal s_pc: std_ulogic_vector(62 downto 0);

    -- decoder output
    signal s_dec_iext_type: t_iext_type;
    signal s_dec_amux_alu: t_alu_a_mux;
    signal s_dec_bmux_alu: t_alu_b_mux;
    signal s_dec_alu_opcode: std_ulogic_vector(4 downto 0);
    signal s_dec_jmp_cond: t_jmp_cond;
    signal s_dec_iret: std_ulogic;
    signal s_dec_reg_a_use: std_ulogic;
    signal s_dec_reg_b_use: std_ulogic;
    signal s_dec_mem_we: std_ulogic;
    signal s_dec_cr_we: std_ulogic;
    signal s_dec_reg_c_we: std_ulogic;
    signal s_dec_result_mux: t_result_mux;

    -- immediate extractor output
    signal s_iext_imm: std_ulogic_vector(63 downto 0);
begin

    catch_input: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_stall = '0' then
                o_pc_valid <= '1';

                s_ir <= i_inst;
                s_pc <= i_pc;
            end if;

            if i_rst = '1' then
                o_pc_valid <= '0';

                s_ir <= c_NOP_INST;
            end if;
        end if;
    end process catch_input;

--- instruction decoder --------------------------------------------------------

    m_dec: entity work.decoder
    port map (
        s_ir(15 downto 8), -- opcode part
        s_dec_iext_type,
        s_dec_amux_alu,
        s_dec_bmux_alu,
        s_dec_alu_opcode,
        s_dec_jmp_cond,
        s_dec_iret,
        s_dec_reg_a_use,
        s_dec_reg_b_use,
        s_dec_mem_we,
        s_dec_cr_we,
        s_dec_reg_c_we,
        s_dec_result_mux
    );

--- immediate extractor --------------------------------------------------------

    m_iext: entity work.imm_extract
    port map (
        i_type => s_dec_iext_type,
        i_imm_field => s_ir(12 downto 0),
        o_imm => s_iext_imm
    );

--------------------------------------------------------------------------------

    -- register file interface
    o_reg_a_use <= s_dec_reg_a_use;
    o_reg_a_index <= s_ir(3 downto 0);

    o_reg_b_use <= s_dec_reg_b_use;
    o_reg_b_index <= s_ir(7 downto 4);

    -- ALU signals
    o_alu_opcode <= s_dec_alu_opcode;
    with s_dec_amux_alu select o_alu_a_operand <=
        i_reg_b_data when AMUX_BREG,
        s_pc & '0' when AMUX_PC,
        i_reg_a_data when AMUX_AREG;
    with s_dec_bmux_alu select o_alu_b_operand <=
        i_reg_b_data when BMUX_BREG,
        s_iext_imm when BMUX_IMM;

    -- control flow
    o_jmp_cond <= s_dec_jmp_cond;
    o_iret <= s_dec_iret;
    o_pc <= s_pc; -- current instruction address

    -- memory write
    o_mem_we <= s_dec_mem_we;
    o_reg_a_data <= i_reg_a_data;

    -- control register write
    o_cr_we <= s_dec_cr_we;
    o_cr_index <= s_ir(6 downto 4);

    -- register write
    o_reg_c_we <= s_dec_reg_c_we;
    o_reg_c_index <= s_ir(3 downto 0);

    -- select result
    o_result_mux <= s_dec_result_mux;

end architecture rtl;
