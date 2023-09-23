`timescale 1ns/1ps

module sim_top();

logic r_sysclk, r_sdrclk, r_clk_50, r_clk_2;

// clk_100
initial begin
	r_sysclk <= '0;
	forever begin
		#5 r_sysclk <= ~r_sysclk;
	end
end

// clk_200
initial begin
	r_sdrclk <= '0;
	forever begin
		#2.5 r_sdrclk <= ~r_sdrclk;
	end
end

// clk_50
initial begin
	r_clk_50 <= '0;
	forever begin
		#10 r_clk_50 <= ~r_clk_50;
	end
end

// clk_2
initial begin
	r_clk_2 <= '0;
	forever begin
		#250 r_clk_2 <= ~r_clk_2;
	end
end

initial begin
    $dumpfile("sim_top.vcd");
    $dumpvars(0,sim_top);
end

logic button_reset;

initial begin
	button_reset <= '0;
	repeat(10) @(r_clk_2);
	button_reset <= '1;
	repeat(2000) @(r_clk_2);
	$finish();
end

logic w_cpu_reset;
logic [15:0] w_cpu_addr;
logic [7:0] w_cpu_data_from_cpu, w_cpu_data_from_dut;
logic cpu_rwb;
logic w_cpu_phi2;

//TODO: this
cpu_65c02 u_cpu(
	.phi2(w_cpu_phi2),
	.reset(~w_cpu_reset),
	.AB(w_cpu_addr),
	.RDY('1),
	.IRQ('0),
	.NMI('0),
	.DI_s1(w_cpu_data_from_dut),
	// .DO(w_cpu_data_from_cpu),
	.WE(cpu_rwb)
);


// Having the super6502 causes an infinite loop,
// but just the rom works. Need to whittle down
// which block is causing it.
// rom #(.DATA_WIDTH(8), .ADDR_WIDTH(12)) u_rom(
//     .addr(w_cpu_addr[11:0]),
//     .clk(r_clk_2),
//     .data(w_cpu_data_from_dut)
// );

//TODO: also this
super6502 u_dut(
	.i_sysclk(r_sysclk),
	.i_sdrclk(r_sdrclk),
	.i_tACclk(r_sdrclk),
	.clk_50(r_clk_50),
	.clk_2(r_clk_2),
	.button_reset(button_reset),
	.cpu_resb(w_cpu_reset),
	.cpu_addr(w_cpu_addr),
	.cpu_data_out(w_cpu_data_from_dut),
	// .cpu_data_in(w_cpu_data_from_cpu),
	.cpu_rwb(~cpu_rwb),
	.cpu_phi2(w_cpu_phi2)
);


endmodule