SRCS=$(shell find src/ -type f -name "*.*v")
SRCS+=$(shell find ../ip/ -type f -name "*.*v" -not \( -name "*tmpl*" \))
SRCS+=$(shell find ../src/ -type f -name "*.*v")

INC=$(shell find include/ -type f)

TEST_PROGRAM_NAME=simple_mem_test

TEST_PROGRAM=$(REPO_TOP)/sw/test_code/$(TEST_PROGRAM_NAME)/$(TEST_PROGRAM_NAME).hex

#TODO implement something like sources.list

TOP_MODULE=sim_top
TARGET=sim_top
INIT_MEM=init_hex.mem
FLAGS=-DSIM -DRTL_SIM

all: $(INIT_MEM)
	iverilog -g2005-sv $(FLAGS) -s $(TOP_MODULE) -o $(TARGET) $(INC) $(SRCS)

$(INIT_MEM):
	cp $(TEST_PROGRAM) ./init_hex.mem

.PHONY: clean
clean:
	rm -rf $(TARGET)
	rm -rf $(INIT_MEM)