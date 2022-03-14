module testbench();

timeunit 10ns;

timeprecision 1ns;

logic [15:0] addr;
logic ram_cs;
logic rom_cs;
logic hex_cs;
logic uart_cs;
logic irq_cs;

int cs_count = ram_cs + rom_cs + hex_cs + uart_cs;

addr_decode dut(.*);

initial begin : TEST_VECTORS

    for (int i = 0; i < 2**16; i++) begin
        addr <= i;
        #1
        assert(cs_count < 2)
        else
            $error("Multiple chip selects present!");
        if (i < 16'h7ff0) begin
            assert(ram_cs == '1)
            else
                $error("Bad CS! addr=%4x should have ram_cs!", addr);
        end
        if (i >= 16'h7ff0 && i < 16'h7ff4) begin
            assert(hex_cs == '1)
            else
                $error("Bad CS! addr=%4x should have hex_cs!", addr);
        end
        if (i >= 16'h7ff4 && i < 16'h7ff6) begin
            assert(uart_cs == '1)
            else
                $error("Bad CS! addr=%4x should have uart_cs!", addr);
        end
        if (i == 16'h7fff) begin
            assert(irq_cs == '1)
            else
                $error("Bad CS! addr=%4x should have irq_cs!", addr);
        end
        if (i >= 2**15) begin
            assert(rom_cs == '1)
            else
                $error("Bad CS! addr=%4x should have rom_cs!", addr);
        end
    end

end
endmodule
