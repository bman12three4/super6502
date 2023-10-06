SRCS=$(shell find src/ -type f -name "*.*v")
SRCS+=$(shell find ../ip/ -type f -name "*.*v" -not \( -name "*tmpl*" \))
SRCS+=$(shell find ../src/ -type f -name "*.*v")

INC=$(shell find include/ -type f)

TEST_PROGRAM_NAME?=loop_test
TEST_FOLDER?=$(REPO_TOP)/sw/test_code/$(TEST_PROGRAM_NAME)
TEST_PROGRAM?=$(REPO_TOP)/sw/test_code/$(TEST_PROGRAM_NAME)/$(TEST_PROGRAM_NAME).hex

SD_IMAGE_PATH?=$(REPO_TOP)/sw/script/fs.fat.hex

#TODO implement something like sources.list

TOP_MODULE=sim_top
TARGET=sim_top
INIT_MEM=init_hex.mem
SD_IMAGE=sd_image.mem
FLAGS=-DSIM -DRTL_SIM

all: sim

.PHONY: sim
sim: $(TARGET)
	vvp $(TARGET) -fst

.PHONY: full_sim
full_sim: $(TARGET) $(SD_IMAGE)
	vvp $(TARGET) -fst


$(TARGET): $(INIT_MEM) $(SRCS)
	iverilog -g2005-sv $(FLAGS) -s $(TOP_MODULE) -o $(TARGET) $(INC) $(SRCS)

$(INIT_MEM):
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
