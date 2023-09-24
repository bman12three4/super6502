SRCS=$(shell find src/ -type f -name "*.*v")
SRCS+=$(shell find ../ip/ -type f -name "*.*v" -not \( -name "*tmpl*" \))
SRCS+=$(shell find ../src/ -type f -name "*.*v")

INC=$(shell find include/ -type f)

TEST_PROGRAM=../../../sw/test_code/simple_mem_test/simple_mem_test.hex

#TODO implement something like sources.list

TOP_MODULE=sim_top
TARGET=sim_top
INIT_MEM=init_hex.mem
FLAGS=-DSIM

all: $(INIT_MEM)
	iverilog -g2005-sv $(FLAGS) -s $(TOP_MODULE) -o $(TARGET) $(INC) $(SRCS)

$(INIT_MEM):
	cp $(TEST_PROGRAM) ./init_hex.mem

.PHONY: clean
clean:
	rm -rf $(TARGET)
	rm $(INIT_MEM)