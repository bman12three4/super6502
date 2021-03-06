module testbench();

timeunit 10ns;

timeprecision 1ns;

logic [23:0] addr;
logic sdram_cs;
logic rom_cs;
logic hex_cs;
logic board_io_cs;
logic uart_cs;
logic irq_cs;
logic mm_cs2;
logic mm_cs1;
logic sd_cs;

int cs_count = sdram_cs + rom_cs + hex_cs + uart_cs + board_io_cs + mm_cs2 + mm_cs1 + sd_cs;

addr_decode dut(.*);

initial begin : TEST_VECTORS

    for (int i = 0; i < 2**24; i++) begin
        addr <= i;
        #1
        assert(cs_count < 2)
        else
            $error("Multiple chip selects present!");
        if (i < 16'h7fe0 || i >= 24'h010000) begin
            assert(sdram_cs == '1)
            else
                $error("Bad CS! addr=%4x should have sdram_cs!", addr);
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
        if (i == 16'h7ff6) begin
            assert(board_io_cs == '1)
            else
                $error("Bad CS! addr=%4x should have board_io_cs!", addr);
        end
        if (i == 16'h7ff7) begin
            assert(mm_cs2 == '1)
            else
                $error("Bad CS! addr=%4x should have mm_cs2!", addr);
        end
        if (i >= 16'h7fe0 && i < 16'h7ff0) begin
            assert(mm_cs1 == '1)
            else
                $error("Bad CS! addr=%4x should have mm_cs1!", addr);
        end
        if (i >= 24'h007ff8 && i < 24'h007ffe) begin
            assert(sd_cs == '1)
            else
            $error("Bad CS! addr=%4x should have sd_cs!", addr);
        end
        if (i == 16'h7fff) begin
            assert(irq_cs == '1)
            else
                $error("Bad CS! addr=%4x should have irq_cs!", addr);
        end
        if (i >= 2**15 && i < 24'h010000) begin
            assert(rom_cs == '1)
            else
                $error("Bad CS! addr=%4x should have rom_cs!", addr);
        end
    end

end
endmodule
