--------------------------------------------------------------------------------
-- Copyright 2020 Dominik Salvet
-- github.com/dominiksalvet/risc63
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.risc63_pkg.all;

entity risc63 is
    port (
        i_clk: in std_ulogic;
        i_rst: in std_ulogic;

------- instruction memory interface -------------------------------------------
        o_imem_addr: out std_ulogic_vector(62 downto 0);
        i_imem_rd_data: in std_ulogic_vector(15 downto 0);

------- data memory interface --------------------------------------------------
        o_dmem_we: out std_ulogic;
        o_dmem_addr: out std_ulogic_vector(60 downto 0);
        o_dmem_wr_data: out std_ulogic_vector(63 downto 0);
        i_dmem_rd_data: in std_ulogic_vector(63 downto 0)
    );
end entity risc63;

architecture rtl of risc63 is
    -- control unit output
    signal s_cu_id_rst: std_ulogic;
    signal s_cu_ex_rst: std_ulogic;
    signal s_cu_mem_rst: std_ulogic;

    -- IF stage output
    signal s_if_pc: std_ulogic_vector(62 downto 0);

    -- ID stage output
    signal s_id_alu_opcode: std_ulogic_vector(4 downto 0);
    signal s_id_alu_a_operand: std_ulogic_vector(63 downto 0);
    signal s_id_alu_b_operand: std_ulogic_vector(63 downto 0);
    signal s_id_jmp_cond: t_jmp_cond;
    signal s_id_iret: std_ulogic;
    signal s_id_mem_we: std_ulogic;
    signal s_id_reg_b_data: std_ulogic_vector(63 downto 0);
    signal s_id_cr_we: std_ulogic;
    signal s_id_cr_index: std_ulogic_vector(2 downto 0);
    signal s_id_reg_c_we: std_ulogic;
    signal s_id_reg_c_index: std_ulogic_vector(3 downto 0);
    signal s_id_result_mux: t_result_mux;

    -- EX stage output
    signal s_ex_jmp_en: std_ulogic;
    signal s_ex_iret: std_ulogic;
    signal s_ex_mem_we: std_ulogic;
    signal s_ex_mem_wr_data: std_ulogic_vector(63 downto 0);
    signal s_ex_cr_we: std_ulogic;
    signal s_ex_cr_index: std_ulogic_vector(2 downto 0);
    signal s_ex_reg_c_we: std_ulogic;
    signal s_ex_reg_c_index: std_ulogic_vector(3 downto 0);
    signal s_ex_result_mux: t_result_mux;
    signal s_ex_alu_result: std_ulogic_vector(63 downto 0);

    -- MEM stage output
    signal s_mem_jmp_en: std_ulogic;
    signal s_mem_iret: std_ulogic; -- todo
    signal s_mem_cr_we: std_ulogic; -- todo
    signal s_mem_cr_index: std_ulogic_vector(2 downto 0); -- todo
    signal s_mem_reg_c_we: std_ulogic;
    signal s_mem_reg_c_index: std_ulogic_vector(3 downto 0);
    signal s_mem_result_mux: t_result_mux;
    signal s_mem_alu_result: std_ulogic_vector(63 downto 0);

    -- WB stage output
    signal s_wb_reg_c_we: std_ulogic;
    signal s_wb_reg_c_index: std_ulogic_vector(3 downto 0);
    signal s_wb_reg_c_data: std_ulogic_vector(63 downto 0);
begin

    control_unit: entity work.control_unit
    port map (
        i_rst => i_rst,
        i_jmp_en => s_mem_jmp_en,
        o_id_rst => s_cu_id_rst,
        o_ex_rst => s_cu_ex_rst,
        o_mem_rst => s_cu_mem_rst
    );

    if_stage: entity work.if_stage
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_jmp_en => s_mem_jmp_en,
        i_jmp_addr => s_mem_alu_result(63 downto 1),
        o_pc => s_if_pc
    );

    o_imem_addr <= s_if_pc;

    id_stage: entity work.id_stage
    port map (
        i_clk => i_clk,
        i_rst => s_cu_id_rst,
        i_inst => i_imem_rd_data,
        i_pc => s_if_pc,
        i_reg_c_we => s_wb_reg_c_we,
        i_reg_c_index => s_wb_reg_c_index,
        i_reg_c_data => s_wb_reg_c_data,
        o_alu_opcode => s_id_alu_opcode,
        o_alu_a_operand => s_id_alu_a_operand,
        o_alu_b_operand => s_id_alu_b_operand,
        o_jmp_cond => s_id_jmp_cond,
        o_iret => s_id_iret,
        o_mem_we => s_id_mem_we,
        o_reg_b_data => s_id_reg_b_data,
        o_cr_we => s_id_cr_we,
        o_cr_index => s_id_cr_index,
        o_reg_c_we => s_id_reg_c_we,
        o_reg_c_index => s_id_reg_c_index,
        o_result_mux => s_id_result_mux
    );

    ex_stage: entity work.ex_stage
    port map (
        i_clk => i_clk,
        i_rst => s_cu_ex_rst,
        i_alu_opcode => s_id_alu_opcode,
        i_alu_a_operand => s_id_alu_a_operand,
        i_alu_b_operand => s_id_alu_b_operand,
        i_jmp_cond => s_id_jmp_cond,
        i_iret => s_id_iret,
        i_mem_we => s_id_mem_we,
        i_reg_b_data => s_id_reg_b_data,
        i_cr_we => s_id_cr_we,
        i_cr_index => s_id_cr_index,
        i_reg_c_we => s_id_reg_c_we,
        i_reg_c_index => s_id_reg_c_index,
        i_result_mux => s_id_result_mux,
        o_jmp_en => s_ex_jmp_en,
        o_iret => s_ex_iret,
        o_mem_we => s_ex_mem_we,
        o_mem_wr_data => s_ex_mem_wr_data,
        o_cr_we => s_ex_cr_we,
        o_cr_index => s_ex_cr_index,
        o_reg_c_we => s_ex_reg_c_we,
        o_reg_c_index => s_ex_reg_c_index,
        o_result_mux => s_ex_result_mux,
        o_alu_result => s_ex_alu_result
    );

    mem_stage: entity work.mem_stage
    port map (
        i_clk => i_clk,
        i_rst => s_cu_mem_rst,
        i_jmp_en => s_ex_jmp_en,
        i_iret => s_ex_iret,
        i_mem_we => s_ex_mem_we,
        i_mem_wr_data => s_ex_mem_wr_data,
        i_cr_we => s_ex_cr_we,
        i_cr_index => s_ex_cr_index,
        i_reg_c_we => s_ex_reg_c_we,
        i_reg_c_index => s_ex_reg_c_index,
        i_result_mux => s_ex_result_mux,
        i_alu_result => s_ex_alu_result,
        o_jmp_en => s_mem_jmp_en,
        o_iret => s_mem_iret,
        o_mem_we => o_dmem_we,
        o_mem_wr_data => o_dmem_wr_data,
        o_cr_we => s_mem_cr_we,
        o_cr_index => s_mem_cr_index,
        o_reg_c_we => s_mem_reg_c_we,
        o_reg_c_index => s_mem_reg_c_index,
        o_result_mux => s_mem_result_mux,
        o_alu_result => s_mem_alu_result
    );

    o_dmem_addr <= s_mem_alu_result(63 downto 3);

    wb_stage: entity work.wb_stage
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_reg_c_we => s_mem_reg_c_we,
        i_reg_c_index => s_mem_reg_c_index,
        i_result_mux => s_mem_result_mux,
        i_mem_rd_data => i_dmem_rd_data,
        i_cr_rd_data => (others => '0'), -- todo
        i_alu_result => s_mem_alu_result,
        o_reg_c_we => s_wb_reg_c_we,
        o_reg_c_index => s_wb_reg_c_index,
        o_reg_c_data => s_wb_reg_c_data
    );

end architecture rtl;
