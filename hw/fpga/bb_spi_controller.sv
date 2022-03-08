module bb_spi_controller(
    input clk,
    input rst,
    
    input spi_cs,

    input logic [7:0] data_in,
    output logic [7:0] data_out,
    
    input rw,
    
    output logic SPI_SSn,
    output logic SPI_MOSI,
    output logic SPI_SCLK,
    input SPI_MISO,
    input SPI_slave_IRQ
);

logic [7:0] val;



assign data_out = val;

        
assign SPI_SCLK = val[0];
assign SPI_SSn = val[1];
assign SPI_MOSI = val[2];

always @(posedge clk) begin
    if (rst) begin
        val <= 8'h2;  //start with SS high
    end
    
    if (spi_cs & ~rw)
        val <= data_in;
        
    val[3] <= SPI_MISO;
    val[4] <= SPI_slave_IRQ;
end


endmodule
