`timescale 1ns/1ps

module sim_top();

`include "include/sdram_controller_define.vh"

localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 32;

logic clk_100, clk_200, clk_50, clk_cpu;

// clk_100
initial begin
    clk_100 <= '1;
    forever begin
        #5 clk_100 <= ~clk_100;
    end
end

// clk_200
initial begin
    clk_200 <= '1;
    forever begin
        #2.5 clk_200 <= ~clk_200;
    end
end

// clk_50
initial begin
    clk_50 <= '1;
    forever begin
        #10 clk_50 <= ~clk_50;
    end
end

// clk_cpu
// 2MHz
initial begin
    clk_cpu <= '1;
    forever begin
        // #62.5 clk_cpu <= ~clk_cpu;
        #500 clk_cpu <= ~clk_cpu;
    end
end


initial begin
    $dumpfile("sim_top.vcd");
    $dumpvars(0,sim_top);
end

logic button_reset;

logic           w_cpu0_reset;
logic [15:0]    w_cpu0_addr;
logic [7:0]     w_cpu0_data_from_cpu;
logic [7:0]     w_cpu0_data_from_dut;
logic           w_cpu0_rdy;
logic           w_cpu0_irqb;
logic           w_cpu0_we;
logic           w_cpu0_sync;
logic           w_clk_phi2;

cpu_65c02 u_cpu0 (
    .phi2   (w_clk_phi2),
    .reset  (~w_cpu0_reset),
    .AB     (w_cpu0_addr),
    .RDY    (w_cpu0_rdy),
    .IRQ    (~w_cpu0_irqb),
    .NMI    ('0),
    .DI_s1  (w_cpu0_data_from_dut),
    .DO     (w_cpu0_data_from_cpu),
    .WE     (w_cpu0_we),
    .SYNC   (w_cpu0_sync)
);

logic                                   w_sdr_CKE;
logic                                   w_sdr_n_CS;
logic                                   w_sdr_n_WE;
logic                                   w_sdr_n_RAS;
logic                                   w_sdr_n_CAS;
logic   [BA_WIDTH				-1:0]   w_sdr_BA;
logic   [ROW_WIDTH				-1:0]   w_sdr_ADDR;
logic   [DQ_GROUP	*DQ_WIDTH	-1:0]   w_sdr_DATA;
logic   [DQ_GROUP	*DQ_WIDTH	-1:0]   w_sdr_DATA_oe;
logic   [DQ_GROUP				-1:0]   w_sdr_DQM;
wire    [DQ_GROUP	*DQ_WIDTH	-1:0]   w_sdr_DQ;
// ^ Has to be wire because of tristate/inout stuff

genvar i, j;
generate
    for (i=0; i<DQ_GROUP*DQ_WIDTH; i=i+1)
    begin: DQ_map
        assign	w_sdr_DQ[i]	=	(w_sdr_DATA_oe[i]) ? w_sdr_DATA[i] : 1'bz;
    end

    for (j=0; j<DQ_GROUP; j=j+1)
    begin : mem_inst
        generic_sdr inst_sdr
        (
            .Dq(w_sdr_DQ[((j+1)*(DQ_WIDTH))-1:((j)*DQ_WIDTH)]),
            .Addr(w_sdr_ADDR[ROW_WIDTH-1:0]),
            .Ba(w_sdr_BA[BA_WIDTH-1:0]),
            .Clk(~clk_200),
            .Cke(w_sdr_CKE),
            .Cs_n(w_sdr_n_CS),
            .Ras_n(w_sdr_n_RAS),
            .Cas_n(w_sdr_n_CAS),
            .We_n(w_sdr_n_WE),
            .Dqm(w_sdr_DQM[j])
        );
    end
endgenerate


// potential sd card sim here?

logic i_sd_cmd;
logic o_sd_cmd;
logic o_sd_cmd_oe;
logic i_sd_dat;
logic o_sd_dat;
logic i_sd_dat_oe;
logic o_sd_clk;
logic o_sd_cs;

super6502_fpga u_dut (
    .i_sysclk               (clk_100),
    .i_sdrclk               (clk_200),
    .i_tACclk               (~clk_200),
    .clk_cpu                (clk_cpu),

    .button_reset           (button_reset),

    .o_cpu0_reset           (w_cpu0_reset),
    .i_cpu0_addr            (w_cpu0_addr),
    .i_cpu0_data_from_cpu   (w_cpu0_data_from_cpu),
    .o_cpu0_data_from_dut   (w_cpu0_data_from_dut),
    .o_cpu0_rdy             (w_cpu0_rdy),
    .o_cpu0_irqb            (w_cpu0_irqb),
    .i_cpu0_rwb             (~w_cpu0_we),
    .i_cpu0_sync            (w_cpu0_sync),
    .o_clk_phi2             (w_clk_phi2),

    .o_sdr_CKE              (w_sdr_CKE),
    .o_sdr_n_CS             (w_sdr_n_CS),
    .o_sdr_n_WE             (w_sdr_n_WE),
    .o_sdr_n_RAS            (w_sdr_n_RAS),
    .o_sdr_n_CAS            (w_sdr_n_CAS),
    .o_sdr_BA               (w_sdr_BA),
    .o_sdr_ADDR             (w_sdr_ADDR),
    .i_sdr_DATA             (w_sdr_DQ),
    .o_sdr_DATA             (w_sdr_DATA),
    .o_sdr_DATA_oe          (w_sdr_DATA_oe),
    .o_sdr_DQM              (w_sdr_DQM),

    .i_sd_cmd               (i_sd_cmd),
    .o_sd_cmd               (o_sd_cmd),
    .o_sd_cmd_oe            (o_sd_cmd_oe),
    .i_sd_dat               (i_sd_dat),
    .o_sd_dat               (o_sd_dat),
    .o_sd_dat_oe            (o_sd_dat_oe),
    .o_sd_clk               (o_sd_clk),
    .o_sd_cs                (o_sd_cs)
);

sd_card_emu u_sd_card_emu(
    .clk(o_sd_clk),
    .rst(~button_reset),
    .i_cmd(o_sd_cmd),
    .o_cmd(i_sd_cmd),
    .i_dat(o_sd_dat),
    .o_dat(i_sd_dat)
);

initial begin
    button_reset <= '1;
    repeat(10) @(clk_cpu);
    button_reset <= '0;
    repeat(10) @(clk_cpu);
    button_reset <= '1;
    repeat(4000) @(posedge clk_cpu);
    $finish();
end

endmodule