module super6502
(
  input [7:0] cpu_data_in,
  input cpu_sync,
  input cpu_rwb,
  input pll_in,
  input button_reset,
  input pll_cpu_locked,
  input clk_50,
  input clk_2,
  input logic [15:0] cpu_addr,
  output logic [7:0] cpu_data_out,
  output logic [7:0] cpu_data_oe,
  output logic cpu_irqb,
  output logic cpu_nmib,
  output logic cpu_rdy,
  output logic cpu_resb,
  output logic pll_cpu_reset,
  output logic cpu_phi2
);

assign pll_cpu_reset = '1;

assign cpu_data_oe = {8{cpu_rwb}};
assign cpu_rdy = '1;
assign cpu_irqb = '1;
assign cpu_nmib = '1;

assign cpu_phi2 = clk_2;

always @(posedge clk_2) begin
    if (button_reset == '0) begin
        cpu_resb <= '0;
    end 
    else begin
        if (cpu_resb == '0) begin
            cpu_resb <= '1;
        end
    end
end

efx_single_port_ram boot_rom(
	.clk(clk_2),		        // clock input for one clock mode
	.addr(cpu_addr[7:0]), 		// address input
    .wclke('0),		// Write clock-enable input
    .byteen('0),		// Byteen input 
    .we('0), 		// Write-enable input
  
    .re(cpu_rwb), 		        // Read-enable input
    .rdata(cpu_data_out) 		// Read data output
);

endmodule
