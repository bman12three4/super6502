module testbench();

timeunit 10ns;

timeprecision 1ns;

logic [15:0] addr;
logic ram_cs;
logic rom_cs;
logic io_cs;

addr_decode dut(.*);

initial begin : TEST_VECTORS

    for (int i = 0; i < 2**16; i++) begin
        addr <= i;
        #1
        if (i < 16'h7ff0) begin
            assert(ram_cs == '1)
            else
                $error("Bad CS! addr=%4x should have ram_cs!", addr);
        end
        if (i >= 16'h7ff0 && i < 16'h8000) begin
            assert(io_cs == '1)
            else
                $error("Bad CS! addr=%4x should have io_cs!", addr);
        end
        if (i >= 2**15) begin
            assert(rom_cs == '1)
            else
                $error("Bad CS! addr=%4x should have rom_cs!", addr);
        end
    end

end
endmodule
