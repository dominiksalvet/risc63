--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity decoder_tb is
end entity decoder_tb;

architecture behavior of decoder_tb is
    signal i_opcode_field: std_ulogic_vector(7 downto 0);
    signal o_iext_type: t_iext_type;
    signal o_amux_alu: t_alu_a_mux;
    signal o_bmux_alu: t_alu_b_mux;
    signal o_alu_opcode: std_ulogic_vector(4 downto 0);
    signal o_jmp_cond: t_jmp_cond;
    signal o_iret: std_ulogic;
    signal o_reg_a_use: std_ulogic;
    signal o_reg_b_use: std_ulogic;
    signal o_mem_we: std_ulogic;
    signal o_cr_we: std_ulogic;
    signal o_reg_c_we: std_ulogic;
    signal o_result_mux: t_result_mux;

    -- configuration
    constant c_CLK_PERIOD: time := 10 ns;
begin

    decoder: entity work.decoder
    port map (
        i_opcode_field,
        o_iext_type,
        o_amux_alu,
        o_bmux_alu,
        o_alu_opcode,
        o_jmp_cond,
        o_iret,
        o_reg_a_use, -- todo test values
        o_reg_b_use, -- todo test values
        o_mem_we,
        o_cr_we,
        o_reg_c_we,
        o_result_mux
    );

    test: process
        constant c_LD: std_ulogic_vector(7 downto 0) := "110-----";
        constant c_ST: std_ulogic_vector(7 downto 0) := "111-----";
        constant c_ADDI: std_ulogic_vector(7 downto 0) := "1000----";
        constant c_ADDUI: std_ulogic_vector(7 downto 0) := "1001----";
        constant c_AUIPC: std_ulogic_vector(7 downto 0) := "1010----";
        constant c_LI: std_ulogic_vector(7 downto 0) := "1011----";
        constant c_JZ: std_ulogic_vector(7 downto 0) := "01100---";
        constant c_JNZ: std_ulogic_vector(7 downto 0) := "01101---";
        constant c_AIPC: std_ulogic_vector(7 downto 0) := "01110---";
        constant c_JR: std_ulogic_vector(7 downto 0) := "01111---";
        constant c_SLTI: std_ulogic_vector(7 downto 0) := "010000--"; -- slti group behavior
        constant c_ADD: std_ulogic_vector(7 downto 0) := "00110000"; -- add group behavior
        constant c_JMP: std_ulogic_vector(7 downto 0) := "0010----";
        constant c_EXTB: std_ulogic_vector(7 downto 0) := "00010000"; -- extb group behavior
        constant c_CRR: std_ulogic_vector(7 downto 0) := "000010--";
        constant c_CRW: std_ulogic_vector(7 downto 0) := "000011--";
        constant c_MV: std_ulogic_vector(7 downto 0) := "000001--";
        constant c_NOP: std_ulogic_vector(7 downto 0) := "00000000";
        constant c_IRET: std_ulogic_vector(7 downto 0) := "00000001";
    begin
        i_opcode_field <= c_LD;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_LD;
        assert o_amux_alu = AMUX_BREG;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_MEM;

        i_opcode_field <= c_ST;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_LD;
        assert o_amux_alu = AMUX_BREG;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '1';
        assert o_cr_we = '0';
        assert o_reg_c_we = '0';

        i_opcode_field <= c_ADDI;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_ADDI;
        assert o_amux_alu = AMUX_AREG;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_ADDUI;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_ADDUI;
        assert o_amux_alu = AMUX_AREG;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_AUIPC;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_ADDUI;
        assert o_amux_alu = AMUX_PC;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_LI;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_ADDI;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_B;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_JZ;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_JZ;
        assert o_amux_alu = AMUX_PC;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_ZERO;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '0';

        i_opcode_field <= c_JNZ;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_JZ;
        assert o_amux_alu = AMUX_PC;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NZERO;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '0';

        i_opcode_field <= c_AIPC;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_JZ;
        assert o_amux_alu = AMUX_PC;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_JR;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_JZ;
        assert o_amux_alu = AMUX_AREG;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_ALWAYS;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '0';

        i_opcode_field <= c_SLTI;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_SLTI;
        assert o_amux_alu = AMUX_AREG;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_SLT;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_ADD;
        wait for c_CLK_PERIOD;
        assert o_amux_alu = AMUX_AREG;
        assert o_bmux_alu = BMUX_BREG;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_JMP;
        wait for c_CLK_PERIOD;
        assert o_iext_type = IEXT_JMP;
        assert o_amux_alu = AMUX_PC;
        assert o_bmux_alu = BMUX_IMM;
        assert o_alu_opcode = c_ALU_ADD;
        assert o_jmp_cond = JMP_ALWAYS;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '0';

        i_opcode_field <= c_EXTB;
        wait for c_CLK_PERIOD;
        assert o_amux_alu = AMUX_AREG;
        assert o_bmux_alu = BMUX_BREG;
        assert o_alu_opcode = c_ALU_EXTB;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_CRR;
        wait for c_CLK_PERIOD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_CR;

        i_opcode_field <= c_CRW;
        wait for c_CLK_PERIOD;
        assert o_amux_alu = AMUX_AREG;
        assert o_alu_opcode = c_ALU_A;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '1';
        assert o_reg_c_we = '0';

        i_opcode_field <= c_MV;
        wait for c_CLK_PERIOD;
        assert o_bmux_alu = BMUX_BREG;
        assert o_alu_opcode = c_ALU_B;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '1';
        assert o_result_mux = RESULT_ALU;

        i_opcode_field <= c_NOP;
        wait for c_CLK_PERIOD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '0';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '0';

        i_opcode_field <= c_iret;
        wait for c_CLK_PERIOD;
        assert o_jmp_cond = JMP_NEVER;
        assert o_iret = '1';
        assert o_mem_we = '0';
        assert o_cr_we = '0';
        assert o_reg_c_we = '0';

        wait;
    end process test;

end architecture behavior;
