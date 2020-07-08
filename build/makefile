#-------------------------------------------------------------------------------
# Copyright 2020 Dominik Salvet
# github.com/dominiksalvet/risc63
#-------------------------------------------------------------------------------

.POSIX: # this is a POSIX makefile

#-------------------------------------------------------------------------------
# ENVIRONMENT
#-------------------------------------------------------------------------------

# directory paths
RTL_DIR = ../rtl
TEST_DIR = ../test

# GHDL configuration
GHDL = ghdl
GHDL_STD = 93
GHDL_FLAGS = --std=$(GHDL_STD) --ieee=standard
GHDL_CF_FILE = work-obj$(GHDL_STD).cf

# GTKWave configuration
GTKWAVE = gtkwave

#-------------------------------------------------------------------------------
# SOURCE FILES
#-------------------------------------------------------------------------------

PKG_FILES = $(RTL_DIR)/risc63_pkg.vhdl
RTL_FILES = $(RTL_DIR)/if/if_stage.vhdl\
            $(RTL_DIR)/id/id_stage.vhdl\
            $(RTL_DIR)/id/reg_file.vhdl\
            $(RTL_DIR)/id/decoder.vhdl\
            $(RTL_DIR)/id/imm_extract.vhdl\
            $(RTL_DIR)/ex/ex_stage.vhdl\
            $(RTL_DIR)/ex/alu.vhdl\
            $(RTL_DIR)/ex/adder.vhdl\
            $(RTL_DIR)/ex/picker.vhdl\
            $(RTL_DIR)/ex/jmp_test.vhdl
TEST_FILES = $(TEST_DIR)/reg_file_tb.vhdl\
             $(TEST_DIR)/picker_tb.vhdl

#-------------------------------------------------------------------------------
# GLOBAL TARGETS
#-------------------------------------------------------------------------------

all: import
	for file in $(RTL_FILES) $(TEST_FILES); do\
		entity_name="$$(basename "$$file" .vhdl)" &&\
		$(GHDL) -m $(GHDL_FLAGS) "$$entity_name" || exit;\
	done

test: import
	for file in $(TEST_FILES); do\
		entity_name="$$(basename "$$file" .vhdl)" &&\
		$(GHDL) -m $(GHDL_FLAGS) "$$entity_name" &&\
		$(GHDL) -r $(GHDL_FLAGS) "$$entity_name" || exit;\
	done

import: $(GHDL_CF_FILE)

$(GHDL_CF_FILE): $(PKG_FILES) $(RTL_FILES) $(TEST_FILES)
	$(GHDL) -i $(GHDL_FLAGS) $?

clean:
	find . -type f ! -name makefile -exec rm {} +

#-------------------------------------------------------------------------------
# SELECTIVE TARGETS
#-------------------------------------------------------------------------------

build_a: check_a import
	$(GHDL) -m $(GHDL_FLAGS) $(a)

test_a: build_a
	$(GHDL) -r $(GHDL_FLAGS) $(a)

view_a: build_a
	$(GHDL) -r $(GHDL_FLAGS) $(a) --vcd=$(a).vcd
	$(GTKWAVE) $(a).vcd

check_a:
	test "$$a"
