module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk_50, clk, cs;
logic rw, MM_cs;
logic [3:0] RS, MA;
logic [7:0] data_in;
logic [7:0] data_out;

logic [11:0] MO;

logic [11:0] _data_in;
assign _data_in = {4'h0, data_in};

logic [11:0] _data_out;
assign data_out = _data_out[7:0];

logic [15:0] cpu_addr;
logic [23:0] mm_address;
assign MA = cpu_addr[15:12];
assign mm_address = {MO, cpu_addr[11:0]};

memory_mapper dut(
	.data_in(_data_in),
	.data_out(_data_out),
	.*
);

always #1 clk_50 = clk_50 === 1'b0;
always #100 clk = clk === 1'b0;

task write_reg(logic [3:0] addr, logic [7:0] data);
	@(negedge clk);
	cs <= '1;
	RS <= addr;
	data_in <= data;
	rw <= '0;
	@(posedge clk);
	cs <= '0;
	rw <= '1;
	@(negedge clk);
endtask

task enable(logic [7:0] data);
	@(negedge clk);
	MM_cs <= '1;
	rw <= '0;
	data_in <= data;
	@(posedge clk);
	rw <= '1;
	MM_cs <= '0;
	@(negedge clk);
endtask

initial begin
	cpu_addr <= 16'h0abc;
	write_reg(4'h0, 8'hcc);
	$display("Address: %x", mm_address);
	assert(mm_address == 24'h000abc) else begin
		$error("Bad address before enable!");
	end

	enable(1);
	$display("Address: %x", mm_address);
	assert(mm_address == 24'h0ccabc) else begin
		$error("Bad address after enable!");
	end

	enable(0);
	$display("Address: %x", mm_address);
	assert(mm_address == 24'h000abc) else begin
		$error("Bad address after enable!");
	end
	$finish();
end

endmodule
