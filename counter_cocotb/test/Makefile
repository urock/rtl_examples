TOPLEVEL_LANG=verilog
WPWD=$(shell pwd)
COCOTB=/home/urock/data/cocotb
PYTHONPATH := $(WPWD):$(PYTHONPATH)

TOPLEVEL=counter
MODULE=counter_tb

VERILOG_SOURCES=$(WPWD)/../rtl/counter.v

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim