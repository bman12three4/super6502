SRCS=$(shell find src/ -type f -name "*.*v")
TBS=$(shell find tbs/ -type f -name "*.*v")
SRCS+=$(shell find ../ip/ -type f -name "*.*v" -not \( -name "*tmpl*" \))
SRCS+=$(shell find ../src/ -type f -name "*.*v")

INC=$(shell find include/ -type f)

TEST_PROGRAM_NAME?=loop_test
TEST_FOLDER?=$(REPO_TOP)/sw/test_code/$(TEST_PROGRAM_NAME)
TEST_PROGRAM?=$(REPO_TOP)/sw/test_code/$(TEST_PROGRAM_NAME)/$(TEST_PROGRAM_NAME).hex

STANDALONE_TB= interrupt_controller_tb mapper_code_tb mapper_tb rtc_tb

#TODO implement something like sources.list

TOP_MODULE=sim_top
TARGET=sim_top
INIT_MEM=init_hex.mem
SD_IMAGE=fs.fat
FLAGS=-DSIM -DRTL_SIM

SD_IMAGE_PATH?=$(REPO_TOP)/sw/script/$(SD_IMAGE)

all: sim

.PHONY: sim
sim: $(TARGET)
	vvp -i $(TARGET) -fst

.PHONY: full_sim
full_sim: $(TARGET) $(SD_IMAGE)
	vvp -i $(TARGET) -fst

$(STANDALONE_TB): $(SRCS) $(TBS)
	iverilog -g2005-sv $(FLAGS) -s $@ -o $@ $(INC) $(SRCS) tbs/$@.sv

# mapper_code_tb: $(SRCS) $(TBS) $(INIT_MEM)
# 	iverilog -g2005-sv $(FLAGS) -s $@ -o $@ $(INC) $(SRCS) $(TBS)


$(TARGET): $(INIT_MEM) $(SRCS)
	iverilog -g2005-sv $(FLAGS) -s $(TOP_MODULE) -o $(TARGET) $(INC) $(SRCS)

$(INIT_MEM):
# Make kernel
	$(MAKE) -C $(REPO_TOP)/sw/kernel
	$(MAKE) -C $(TEST_FOLDER)
	cp $(TEST_PROGRAM) ./init_hex.mem

# The script that makes this file uses relative paths
$(SD_IMAGE):
	sh $(REPO_TOP)/sw/script/create_verilog_image.sh
	cp $(SD_IMAGE_PATH) $(SD_IMAGE)

.PHONY: clean
clean:
	rm -rf $(TARGET)
	rm -rf $(INIT_MEM)
	rm -rf $(SD_IMAGE)
	rm -rf $(STANDALONE_TB)
	rm -rf *.vcd
