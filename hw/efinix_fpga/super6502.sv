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
  output logic cpu_phi2,
  
  output logic [7:0] leds
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


logic w_rom_cs;
logic w_leds_cs;

addr_decode u_addr_decode(
    .i_addr(cpu_addr),
    .o_rom_cs(w_rom_cs),
    .o_leds_cs(w_leds_cs)
);

logic [7:0] w_rom_data_out;
logic [7:0] w_leds_data_out;

always_comb begin
    if (w_rom_cs)
        cpu_data_out = w_rom_data_out;
    else if (w_leds_cs)
        cpu_data_out=  w_leds_data_out;
    else
        cpu_data_out = 'x;
end


efx_single_port_ram boot_rom(
	.clk(clk_2),		        // clock input for one clock mode
	.addr(cpu_addr[7:0]), 		// address input
    .wclke('0),		            // Write clock-enable input
    .byteen('0),		        // Byteen input 
    .we('0), 		            // Write-enable input
  
    .re(cpu_rwb & w_rom_cs),    // Read-enable input
    .rdata(w_rom_data_out) 		// Read data output
);

leds u_leds(
    .clk(clk_2),
    .i_data(cpu_data_in),
    .o_data(w_leds_data_out),
    .cs(w_leds_cs),
    .rwb(cpu_rwb),
    .o_leds(leds)
);

endmodule
