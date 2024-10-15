RTL_SRCS_LIST=$(REPO_TOP)/hw/super6502_fpga/sources.list
SIM_SRCS_LIST=tb/sources.list

RTL_SOURCES=$(shell rtl-manifest $(RTL_SRCS_LIST))
SIM_SOURCES=$(shell rtl-manifest $(SIM_SRCS_LIST))

VERILOG_SOURCES= $(INTF_SOURCES) $(RTL_SOURCES) $(SIM_SOURCES)

TOPLEVEL_LANG ?= verilog

SIM ?= verilator

EXTRA_ARGS += --trace --trace-fst --trace-structs -Wno-fatal -Wno-PINMISSING


TOPLEVEL = tb_top

GPI_IMPL := vpi

export PYTHONPATH := $(PWD)/tests:$(PYTHONPATH)
export TOPLEVEL_LANG
MODULE=scapy_irl_test

include $(shell cocotb-config --makefiles)/Makefile.sim