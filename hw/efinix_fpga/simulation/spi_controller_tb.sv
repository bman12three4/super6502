module sim();

timeunit 10ns;
timeprecision 1ns;

logic clk_50;

logic i_clk;
logic i_rst;

logic i_cs;
logic i_rwb;
logic [1:0] i_addr;
logic [7:0] i_data;
logic [7:0] o_data;

logic o_spi_cs;
logic o_spi_clk;
logic o_spi_mosi;
logic i_spi_miso;

spi_controller dut(.*);

always #1 clk_50 = clk_50 === 1'b0;
always #100 i_clk = i_clk === 1'b0;

task write_reg(input logic [2:0] _addr, input logic [7:0] _data);
    @(negedge i_clk);
    i_cs <= '1;
    i_addr <= _addr;
    i_rwb <= '0;
    i_data <= '1;
    @(posedge i_clk);
    i_data <= _data;
    @(negedge i_clk);
    i_cs <= '0;
    i_rwb <= '1;
endtask

task read_reg(input logic [2:0] _addr, output logic [7:0] _data);
    @(negedge i_clk);
    i_cs <= '1;
    i_addr <= _addr;
    i_rwb <= '1;
    i_data <= '1;
    @(posedge i_clk);
    _data <= o_data;
    @(negedge i_clk);
    i_cs <= '0;
    i_rwb <= '1;
endtask

initial
begin
    $dumpfile("spi_controller.vcd");
    $dumpvars(0,sim);
end

initial begin
    i_rst <= '1;
    repeat(5) @(posedge i_clk);
    i_rst <= '0;

    repeat(5) @(posedge i_clk);

    $finish();
end

endmodule