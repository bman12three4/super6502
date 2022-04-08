module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk;
logic clk_50;
logic rst;

logic [3:0] addr;
logic [7:0] data;
logic cs;

logic i_sd_cmd;
logic o_sd_cmd;

logic i_sd_data;
logic o_sd_dat;

sd_controller dut(.*);

always #1 clk_50 = clk_50 === 1'b0;
always #100 clk = clk === 1'b0;

task write_reg(logic [3:0] _addr, logic [7:0] _data);
    @(negedge clk);
    cs <= '1;
    addr <= _addr;
    data <= _data;
    @(posedge clk);
    cs <= '0;
    @(negedge clk);
endtask

task verify_cmd(logic [5:0] cmd, logic [31:0] arg, logic [47:0] verify);
    write_reg(0, arg[7:0]);
    write_reg(1, arg[15:8]);
    write_reg(2, arg[23:16]);
    write_reg(3, arg[31:24]);
    write_reg(4, cmd);

    @(posedge clk);
    @(posedge clk);

    while (dut.state.macro == dut.TXCMD) begin
        assert(o_sd_cmd == verify[47-dut.state.count]) else begin
            $error("cmd output error: Expected %h:%b, got %h:%b", 
                47-dut.state.count, verify[47-dut.state.count],
                47-dut.state.count, o_sd_cmd);
        end
        @(negedge clk);
    end
endtask

localparam cmd0 = 48'h400000000095;
localparam cmd8 = 48'h48000001aa87;
localparam cmd55 = 48'h770000000065;
localparam cmd41 = 48'h694018000019;

initial begin
    rst <= '1;
    repeat(5) @(posedge clk);
    rst <= '0;

    verify_cmd(0, 0, cmd0);
    verify_cmd(8, 'h1aa, cmd8);
    verify_cmd('d55, 0, cmd55);
    verify_cmd('d41, 'h40180000, cmd41);

    $finish();
end

endmodule