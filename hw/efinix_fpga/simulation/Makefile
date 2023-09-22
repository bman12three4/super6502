SRCS=$(shell find src/ -type f -name "*.*v")
SRCS+=$(shell find ../ip/ -type f -name "*.*v" -not \( -name "*tmpl*" \))
SRCS+=$(shell find ../src/ -type f -name "*.*v")

INC=$(shell find include/ -type f)

#TODO implement something like sources.list

TOP_MODULE=sim_top
TARGET=sim_top

all: 
	iverilog -g2005-sv -s $(TOP_MODULE) -o $(TARGET) $(INC) $(SRCS)

.PHONY: clean
clean:
	rm -rf $(TARGET)