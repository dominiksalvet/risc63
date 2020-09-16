#-------------------------------------------------------------------------------
# Copyright 2020 Dominik Salvet
# github.com/dominiksalvet/risc63
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# ENVIRONMENT
#-------------------------------------------------------------------------------

.POSIX: # this is a POSIX makefile

# directory paths
RTL_DIR = ../rtl
TEST_DIR = ../test

# GHDL configuration
GHDL = ghdl
GHDL_STD = 93
GHDL_CF_FILE = work-obj$(GHDL_STD).cf

GHDL_FLAGS = --std=$(GHDL_STD) --ieee=standard
GHDL_ELAB_FLAGS = --no-run
GHDL_TEST_FLAGS = --assert-level=note --ieee-asserts=disable
GHDL_VIEW_FLAGS = --wave=$(a).ghw

# GTKWave configuration
GTKWAVE = gtkwave

#-------------------------------------------------------------------------------
# SOURCE FILES
#-------------------------------------------------------------------------------

PKG_FILES = $(RTL_DIR)/risc63_pkg.vhdl
RTL_FILES = $(RTL_DIR)/risc63.vhdl\
            $(RTL_DIR)/control_unit.vhdl\
            $(RTL_DIR)/if/if_stage.vhdl\
            $(RTL_DIR)/id/id_stage.vhdl\
            $(RTL_DIR)/id/reg_file.vhdl\
            $(RTL_DIR)/id/decoder.vhdl\
            $(RTL_DIR)/id/imm_extract.vhdl\
            $(RTL_DIR)/ex/ex_stage.vhdl\
            $(RTL_DIR)/ex/alu.vhdl\
            $(RTL_DIR)/ex/adder.vhdl\
            $(RTL_DIR)/ex/picker.vhdl\
            $(RTL_DIR)/ex/jmp_test.vhdl\
            $(RTL_DIR)/mem/mem_stage.vhdl\
            $(RTL_DIR)/mem/control_regs.vhdl\
            $(RTL_DIR)/wb/wb_stage.vhdl
TEST_FILES = $(TEST_DIR)/risc63_tb.vhdl\
             $(TEST_DIR)/reg_file_tb.vhdl\
             $(TEST_DIR)/decoder_tb.vhdl\
             $(TEST_DIR)/adder_tb.vhdl\
             $(TEST_DIR)/picker_tb.vhdl

#-------------------------------------------------------------------------------
# GENERAL TARGETS
#-------------------------------------------------------------------------------

elab: import
	for file in $(RTL_FILES) $(TEST_FILES); do\
		entity_name="$$(basename "$$file" .vhdl)" &&\
		$(GHDL) -m $(GHDL_FLAGS) "$$entity_name" &&\
		$(GHDL) -r $(GHDL_FLAGS) "$$entity_name" $(GHDL_ELAB_FLAGS) || exit;\
	done

test: import
	for file in $(TEST_FILES); do\
		entity_name="$$(basename "$$file" .vhdl)" &&\
		$(GHDL) -m $(GHDL_FLAGS) "$$entity_name" &&\
		$(GHDL) -r $(GHDL_FLAGS) "$$entity_name" $(GHDL_TEST_FLAGS) || exit;\
	done

import: $(GHDL_CF_FILE)

clean:
	find . -type f ! -name makefile -exec rm {} +

#-------------------------------------------------------------------------------
# SELECTIVE TARGETS
#-------------------------------------------------------------------------------

elab_a: make_a
	$(GHDL) -r $(GHDL_FLAGS) $(a) $(GHDL_ELAB_FLAGS)

test_a: make_a
	$(GHDL) -r $(GHDL_FLAGS) $(a) $(GHDL_TEST_FLAGS)

view_a: make_a
	$(GHDL) -r $(GHDL_FLAGS) $(a) $(GHDL_VIEW_FLAGS)
	$(GTKWAVE) $(a).ghw

#-------------------------------------------------------------------------------
# OTHER TARGETS
#-------------------------------------------------------------------------------

make_a: check_a import
	$(GHDL) -m $(GHDL_FLAGS) $(a)

check_a:
	test "$$a"

$(GHDL_CF_FILE): $(PKG_FILES) $(RTL_FILES) $(TEST_FILES)
	$(GHDL) -i $(GHDL_FLAGS) $?
