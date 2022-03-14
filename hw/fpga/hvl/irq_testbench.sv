module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk_50, rst_n, button_1;
logic [15:0] cpu_addr;
wire [7:0] cpu_data;
logic [7:0] cpu_data_in;
logic [7:0] cpu_data_out;
logic cpu_vpb, cpu_mlb, cpu_rwb, cpu_sync;
logic cpu_led, cpu_resb, cpu_rdy, cpu_sob, cpu_irqb;
logic cpu_phi2, cpu_be, cpu_nmib;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
logic UART_RXD, UART_TXD;

assign cpu_data = ~cpu_rwb ? cpu_data_out : 'z;
assign cpu_data_in = cpu_data;

super6502 dut(.*);

always #1 clk_50 = clk_50 === 1'b0;
always #100 dut.clk = dut.clk === 1'b0;

always @(posedge dut.clk) begin
    dut.cpu_phi2 <= ~dut.cpu_phi2;
end

logic [7:0] _tmp_data;

initial begin
    rst_n <= '0;
    cpu_addr <= 16'h7fff;
    cpu_rwb <= '1;
    button_1 <= '1;

    repeat(10) @(posedge dut.clk);
    rst_n <= '1;

    repeat(10) @(posedge dut.clk);
    
    button_1 <= '0;
    @(posedge dut.clk);
    button_1 <= '1;
    @(posedge dut.clk);

    assert(cpu_data[0] == '1)
    else begin
        $error("IRQ location should have bit 1 set!");
    end

    @(posedge dut.clk);
    _tmp_data <= cpu_data_in;
    @(posedge dut.clk);

    _tmp_data <= _tmp_data & ~8'b1;

    @(posedge dut.clk);

    cpu_data_out <= _tmp_data;
    cpu_rwb <= '0;

    @(posedge dut.clk);

    cpu_rwb <= '1;

    repeat (5) @(posedge dut.clk);

    $finish();
    

end

endmodule
