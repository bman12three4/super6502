TARGETS= timer interrupt_controller spi_controller
TB=$(patsubst %, %_tb.sv, $(TARGETS))

all: $(TARGETS)

timer: timer_tb.sv
	iverilog -g2005-sv -s sim -o $@ $@_tb.sv ../$@.sv

spi_controller: spi_controller_tb.sv
	iverilog -g2005-sv -s sim -o $@ $@_tb.sv ../$@.sv

interrupt_controller: interrupt_controller_tb.sv
	iverilog -g2005-sv -s sim -o $@ $@_tb.sv ../$@.sv

.PHONY: clean

clean:
	rm -f $(TARGETS)
	rm -f *.vcd
	rm -f *.vvp