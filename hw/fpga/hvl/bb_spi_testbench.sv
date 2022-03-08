module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk, rst, spi_cs;
logic [7:0] data_in, data_out;
logic rw;
logic SPI_SSn, SPI_MOSI, SPI_SCLK, SPI_MISO;
logic SPI_slave_IRQ;


bb_spi_controller dut(.*);

always #5 clk = clk === 1'b0;

task write_byte(input logic [8:0] wdata);
    for (int i = 0; i < 8; i++) begin
        write_bit(8'b0 + (wdata[i] << 2));
        write_bit(8'b1 + (wdata[i] << 2));
    end
    write_bit(8'b0);
endtask

task write_bit(input logic [8:0] wdata);
    @(negedge clk);
    spi_cs <= '1;
    data_in <= wdata;
    rw <= '0;
    @(posedge clk);
endtask

task read(output logic [8:0] rdata);
    @(negedge clk);
    spi_cs <= '1;
    rdata <= data_out;
    rw <= '1;
    @(posedge clk);
endtask

always @(posedge SPI_SCLK) begin
    assert(SPI_MOSI == data_in[2]) else begin
        $error("SPI_MOSI data error");
    end
end

initial begin : TEST_VECTORS
    SPI_slave_IRQ <= '0;
    SPI_MISO <= '0;

    rst <= '1;
    repeat(5) @(posedge clk);
    rst <= '0;
    @(posedge clk);
    
    write_byte(8'ha5);

    repeat(5) @(posedge clk);

    SPI_slave_IRQ <= '1;
    @(posedge clk);
    @(posedge clk);
    assert (data_out[4] == '1) else begin
        $error("IRQ expected");
    end

    repeat(5) @(posedge clk);

    $finish();

end

endmodule
