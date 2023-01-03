module super6502
(
    input logic i_sysclk,       // Controller Clock (100MHz)
    input logic i_sdrclk,       // t_su and t_wd clock (200MHz)
    input logic i_tACclk,       // t_ac clock (200MHz)

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

    output logic [7:0] leds,

    output logic o_pll_reset,
    output	logic o_sdr_CKE,
    output	logic o_sdr_n_CS,
    output	logic o_sdr_n_WE,
    output	logic o_sdr_n_RAS,
    output	logic o_sdr_n_CAS,
    output	logic [1:0] o_sdr_BA,
    output	logic [12:0] o_sdr_ADDR,
    input	logic [15:0] i_sdr_DATA,
    output	logic [15:0] o_sdr_DATA,
    output	logic [15:0] o_sdr_DATA_oe,
    output	logic [1:0] o_sdr_DQM

);

assign pll_cpu_reset = '1;
assign o_pll_reset = '1;

assign cpu_data_oe = {8{cpu_rwb}};
assign cpu_rdy = '1;
assign cpu_nmib = '1;

assign cpu_phi2 = clk_2;

logic w_sdr_init_done;

always @(posedge clk_2) begin
    if (button_reset == '0) begin
        cpu_resb <= '0;
    end 
    else begin
        if (cpu_resb == '0 && w_sdr_init_done) begin
            cpu_resb <= '1;
        end
    end
end


logic w_rom_cs;
logic w_leds_cs;
logic w_sdram_cs;
logic w_timer_cs;

addr_decode u_addr_decode(
    .i_addr(cpu_addr),
    .o_rom_cs(w_rom_cs),
    .o_leds_cs(w_leds_cs),
    .o_timer_cs(w_timer_cs),
    .o_sdram_cs(w_sdram_cs)
);

logic [7:0] w_rom_data_out;
logic [7:0] w_leds_data_out;
logic [7:0] w_timer_data_out;
logic [7:0] w_sdram_data_out;

always_comb begin
    if (w_rom_cs)
        cpu_data_out = w_rom_data_out;
    else if (w_leds_cs)
        cpu_data_out = w_leds_data_out;
    else if (w_timer_cs)
        cpu_data_out = w_timer_data_out;
    else if (w_sdram_cs)
        cpu_data_out = w_sdram_data_out;
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

logic w_timer_irqb;

timer u_timer(
    .clk(clk_2),
    .reset(~cpu_resb),
    .i_data(cpu_data_in),
    .o_data(w_timer_data_out),
    .cs(w_timer_cs),
    .rwb(cpu_rwb),
    .addr(cpu_addr[1:0]),
    .irqb(w_timer_irqb)
);

sdram_adapter u_sdram_adapter(
    .i_cpuclk(clk_2),
    .i_arst(~button_reset),
    .i_sysclk(i_sysclk),
    .i_sdrclk(i_sdrclk),
    .i_tACclk(i_tACclk),

    .i_cs(w_sdram_cs),
    .i_rwb(cpu_rwb),

    .i_addr(cpu_addr),
    .i_data(cpu_data_in),
    .o_data(w_sdram_data_out),

    .o_sdr_init_done(w_sdr_init_done),

    .o_sdr_CKE(o_sdr_CKE),
    .o_sdr_n_CS(o_sdr_n_CS),
    .o_sdr_n_RAS(o_sdr_n_RAS),
    .o_sdr_n_CAS(o_sdr_n_CAS),
    .o_sdr_n_WE(o_sdr_n_WE),
    .o_sdr_BA(o_sdr_BA),
    .o_sdr_ADDR(o_sdr_ADDR),
    .o_sdr_DATA(o_sdr_DATA),
    .o_sdr_DATA_oe(o_sdr_DATA_oe),
    .i_sdr_DATA(i_sdr_DATA),
    .o_sdr_DQM(o_sdr_DQM)
);

interrupt_controller u_interrupt_controller(
    .clk(clk_2),
    .reset(~cpu_resb),
    .i_data(cpu_data_in),
    .o_data(w_irq_data_out),
    .cs(w_irq_cs),
    .rwb(cpu_rwb),
    .irqb_master(cpu_irqb),
    .irqb0(w_timer_irqb),
    .irqb1('1),
    .irqb2('1),
    .irqb3('1),
    .irqb4('1),
    .irqb5('1),
    .irqb6('1),
    .irqb7('1)
);


endmodule
