module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk;
logic rst;

logic load;
logic [39:0] data_in;

logic [6:0] crc_out;
logic valid;

crc7 dut(.*);

always #1 clk = clk === 1'b0;

task create_sd_packet(logic [5:0] cmd, logic [31:0] data, output logic [47:0] _packet);
    @(posedge clk);
    data_in <= {1'b0, 1'b1, cmd, data};
    load <= '1;
    @(posedge clk);
    load <= '0;

    while (~valid) begin
        //$display("Working %b", dut.data);
        @(posedge clk);
    end

    _packet = {1'b0, 1'b1, cmd, data, crc_out, 1'b1};
endtask

logic [47:0] packet;

initial begin
    rst <= '1;
    repeat(5) @(posedge clk);
    rst <= '0;

    create_sd_packet(6'h0, 32'h0, packet);
    $display("Result: %x", packet);
    assert(packet == 48'h400000000095) else
        $error("Bad crc7. Got %x expected %x", packet, 48'h400000000095);

    create_sd_packet(6'd8, 32'h1aa, packet);
    $display("Result: %x", packet);
    assert(packet == 48'h48000001aa87) else
        $error("Bad crc7. Got %x expected %x", packet, 48'h48000001aa87);

    create_sd_packet(6'd55, 32'h0, packet);
    $display("Result: %x", packet);
    assert(packet == 48'h770000000065) else
        $error("Bad crc7. Got %x expected %x", packet, 48'h770000000065);
        
    create_sd_packet(6'd41, 32'h40180000, packet);
    $display("Result: %x", packet);
    assert(packet == 48'h694018000019) else
        $error("Bad crc7. Got %x expected %x", packet, 48'h694018000019);

    $finish();
end

endmodule
