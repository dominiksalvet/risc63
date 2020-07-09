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

------- input from IF stage ----------------------------------------------------
        i_inst: in std_ulogic_vector(15 downto 0); -- instruction fetched from memory
        i_pc: in std_ulogic_vector(62 downto 0); -- its address

------- input from WB stage ----------------------------------------------------
        i_reg_c_we: in std_ulogic;
        i_reg_c_index: in std_ulogic_vector(3 downto 0);
        i_reg_c_data: in std_ulogic_vector(63 downto 0);

------- output to EX stage -----------------------------------------------------
        o_alu_opcode: out std_ulogic_vector(4 downto 0);
        o_alu_a_operand: out std_ulogic_vector(63 downto 0);
        o_alu_b_operand: out std_ulogic_vector(63 downto 0);

        o_jmp_cond: out t_jmp_cond;
        o_iret: out std_ulogic;

        o_mem_we: out std_ulogic;
        o_reg_b_data: out std_ulogic_vector(63 downto 0); -- used by stores and conditional jumps
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

    -- register file output
    signal s_reg_a_data: std_ulogic_vector(63 downto 0);
    signal s_reg_b_data: std_ulogic_vector(63 downto 0);

    -- decoder output
    signal s_dec_iext_type: t_iext_type;
    signal s_dec_amux_alu: t_alu_a_mux;
    signal s_dec_bmux_alu: t_alu_b_mux;
    signal s_dec_alu_opcode: std_ulogic_vector(4 downto 0);
    signal s_dec_jmp_cond: t_jmp_cond;
    signal s_dec_iret: std_ulogic;
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
            s_ir <= i_inst;
            s_pc <= i_pc;

            if i_rst = '1' then
                s_ir <= c_NOP_INST;
            end if;
        end if;
    end process catch_input;

--- register file --------------------------------------------------------------

    reg_file: entity work.reg_file
    port map (
        i_clk => i_clk,
        i_a_index => s_ir(7 downto 4),
        o_a_data => s_reg_a_data,
        i_b_index => s_ir(3 downto 0),
        o_b_data => s_reg_b_data,
        i_c_we => i_reg_c_we,
        i_c_index => i_reg_c_index,
        i_c_data => i_reg_c_data
    );

--- instruction decoder --------------------------------------------------------

    decoder: entity work.decoder
    port map (
        s_ir,
        s_dec_iext_type,
        s_dec_amux_alu,
        s_dec_bmux_alu,
        s_dec_alu_opcode,
        s_dec_jmp_cond,
        s_dec_iret,
        s_dec_mem_we,
        s_dec_cr_we,
        s_dec_reg_c_we,
        s_dec_result_mux
    );

--- immediate extractor --------------------------------------------------------

    imm_extract: entity work.imm_extract
    port map (
        i_type => s_dec_iext_type,
        i_imm_field => s_ir(12 downto 0),
        o_imm => s_iext_imm
    );

--------------------------------------------------------------------------------

    -- ALU signals
    o_alu_opcode <= s_dec_alu_opcode;
    with s_dec_amux_alu select o_alu_a_operand <=
        s_iext_imm when AMUX_IMM,
        s_reg_a_data when AMUX_AREG;
    with s_dec_bmux_alu select o_alu_b_operand <=
        s_iext_imm when BMUX_IMM,
        s_pc & '0' when BMUX_PC,
        s_reg_b_data when BMUX_BREG;

    -- control flow
    o_jmp_cond <= s_dec_jmp_cond;
    o_iret <= s_dec_iret;

    -- memory write
    o_mem_we <= s_dec_mem_we;
    o_reg_b_data <= s_reg_b_data;

    -- control register write
    o_cr_we <= s_dec_cr_we;
    o_cr_index <= s_ir(6 downto 4);

    -- register write
    o_reg_c_we <= s_dec_reg_c_we;
    o_reg_c_index <= s_ir(3 downto 0);

    -- select result
    o_result_mux <= s_dec_result_mux;

end architecture rtl;
