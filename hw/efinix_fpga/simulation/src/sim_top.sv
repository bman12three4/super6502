`timescale 1ns/1ps

module sim_top();

`include "include/super6502_sdram_controller_define.vh"

logic r_sysclk, r_sdrclk, r_clk_50, r_clk_cpu;

// clk_100
initial begin
    r_sysclk <= '1;
    forever begin
        #5 r_sysclk <= ~r_sysclk;
    end
end

// clk_200
initial begin
    r_sdrclk <= '1;
    forever begin
        #2.5 r_sdrclk <= ~r_sdrclk;
    end
end

// clk_50
initial begin
    r_clk_50 <= '1;
    forever begin
        #10 r_clk_50 <= ~r_clk_50;
    end
end

// clk_cpu
initial begin
    r_clk_cpu <= '1;
    forever begin
        #125 r_clk_cpu <= ~r_clk_cpu;
    end
end

initial begin
    #275000 $finish();
end

initial begin
    $dumpfile("sim_top.vcd");
    $dumpvars(0,sim_top);
end

logic button_reset;

initial begin
    button_reset <= '0;
    repeat(10) @(r_clk_cpu);
    button_reset <= '1;
    repeat(1000000) @(r_clk_cpu);
    $finish();
end

logic w_cpu_reset;
logic [15:0] w_cpu_addr;
logic [7:0] w_cpu_data_from_cpu, w_cpu_data_from_dut;
logic w_cpu_rdy;
logic w_cpu_we;
logic w_cpu_phi2;

//TODO: this
cpu_65c02 u_cpu(
    .phi2(w_cpu_phi2),
    .reset(~w_cpu_reset),
    .AB(w_cpu_addr),
    .RDY(w_cpu_rdy),
    .IRQ('0),
    .NMI('0),
    .DI_s1(w_cpu_data_from_dut),
    .DO(w_cpu_data_from_cpu),
    .WE(w_cpu_we)
);

logic w_dut_uart_rx, w_dut_uart_tx;

sim_uart u_sim_uart(
    .clk_50(r_clk_50),
    .reset(~w_cpu_reset),
    .rx_i(w_dut_uart_tx),
    .tx_o(w_dut_uart_rx)
);

logic w_sd_cs;
logic w_spi_clk;
logic w_spi_mosi;
logic w_spi_miso;

sd_card_emu u_sd_card_emu(
    .rst(~w_cpu_reset),
    .clk(w_spi_clk),
    .cs(w_sd_cs),
    .mosi(w_spi_mosi),
    .miso(w_spi_miso)
);


super6502 u_dut(
    .i_sysclk(r_sysclk),
    .i_sdrclk(r_sdrclk),
    .i_tACclk(~r_sdrclk),
    .clk_50(r_clk_50),
    .clk_cpu(r_clk_cpu),
    .button_reset(button_reset),
    .cpu_resb(w_cpu_reset),
    .cpu_addr(w_cpu_addr),
    .cpu_data_out(w_cpu_data_from_dut),
    .cpu_data_in(w_cpu_data_from_cpu),
    .cpu_rwb(~w_cpu_we),
    .cpu_rdy(w_cpu_rdy),
    .cpu_phi2(w_cpu_phi2),

    .uart_rx(w_dut_uart_rx),
    .uart_tx(w_dut_uart_tx),

    .sd_cs(w_sd_cs),
    .spi_clk(w_spi_clk),
    .spi_mosi(w_spi_mosi),
    .spi_miso(w_spi_miso),

    .o_sdr_CKE(w_sdr_CKE),
    .o_sdr_n_CS(w_sdr_n_CS),
    .o_sdr_n_WE(w_sdr_n_WE),
    .o_sdr_n_RAS(w_sdr_n_RAS),
    .o_sdr_n_CAS(w_sdr_n_CAS),
    .o_sdr_BA(w_sdr_BA),
    .o_sdr_ADDR(w_sdr_ADDR),
    .i_sdr_DATA(w_sdr_DQ),
    .o_sdr_DATA(w_sdr_DATA),
    .o_sdr_DATA_oe(w_sdr_DATA_oe),
    .o_sdr_DQM(w_sdr_DQM)
);

wire	w_sdr_CKE;
wire	w_sdr_n_CS;
wire	w_sdr_n_WE;
wire	w_sdr_n_RAS;
wire	w_sdr_n_CAS;
wire	[BA_WIDTH				-1:0]w_sdr_BA;
wire	[ROW_WIDTH				-1:0]w_sdr_ADDR;
wire	[DQ_GROUP	*DQ_WIDTH	-1:0]w_sdr_DATA;
wire	[DQ_GROUP	*DQ_WIDTH	-1:0]w_sdr_DATA_oe;
wire	[DQ_GROUP				-1:0]w_sdr_DQM;
wire	[DQ_GROUP	*DQ_WIDTH	-1:0]w_sdr_DQ;

genvar i, j;
generate
    for (i=0; i<DQ_GROUP*DQ_WIDTH; i=i+1)
    begin: DQ_map
        assign	w_sdr_DQ[i]	=	(w_sdr_DATA_oe[i])?
                                    w_sdr_DATA[i]:1'bz;
    end

    for (j=0; j<DQ_GROUP; j=j+1)
    begin : mem_inst
        generic_sdr inst_sdr
        (
            .Dq(w_sdr_DQ[((j+1)*(DQ_WIDTH))-1:((j)*DQ_WIDTH)]),
            .Addr(w_sdr_ADDR[ROW_WIDTH-1:0]),
            .Ba(w_sdr_BA[BA_WIDTH-1:0]),
            .Clk(~r_sdrclk),
            .Cke(w_sdr_CKE),
            .Cs_n(w_sdr_n_CS),
            .Ras_n(w_sdr_n_RAS),
            .Cas_n(w_sdr_n_CAS),
            .We_n(w_sdr_n_WE),
            .Dqm(w_sdr_DQM[j])
        );
    end
endgenerate

endmodule
