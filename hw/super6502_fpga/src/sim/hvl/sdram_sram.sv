module sdram_controller (
    input i_aresetn,
    input i_sysclk,
    input i_sdrclk,
    input i_tACclk,

    output o_pll_reset,
    input i_pll_locked,

    output o_sdr_state,

    input i_AXI4_AWVALID,
    output o_AXI4_AWREADY,
    input [23:0] i_AXI4_AWADDR,
    input i_AXI4_WVALID,
    output o_AXI4_WREADY,
    input [31:0] i_AXI4_WDATA,
    input [3:0] i_AXI4_WSTRB,
    output o_AXI4_BVALID,
    input i_AXI4_BREADY,
    input i_AXI4_ARVALID,
    output o_AXI4_ARREADY,
    input [23:0] i_AXI4_ARADDR,
    output o_AXI4_RVALID,
    input i_AXI4_RREADY,
    output [31:0] o_AXI4_RDATA,

    input i_AXI4_WLAST,
    output o_AXI4_RLAST,
    input [3:0] i_AXI4_AWID,
    input [2:0] i_AXI4_AWSIZE,
    input [3:0] i_AXI4_ARID,
    input [7:0] i_AXI4_ARLEN,
    input [2:0] i_AXI4_ARSIZE,
    input [1:0] i_AXI4_ARBURST,
    input [7:0] i_AXI4_AWLEN,
    output [3:0] o_AXI4_RID,
    output [3:0] o_AXI4_BID,

    output [1:0] o_sdr_CKE,
    output [1:0] o_sdr_n_CS,
    output [1:0] o_sdr_n_RAS,
    output [1:0] o_sdr_n_CAS,
    output [1:0] o_sdr_n_WE,
    output [3:0] o_sdr_BA,
    output [25:0] o_sdr_ADDR,
    output [31:0] o_sdr_DATA,
    output [31:0] o_sdr_DATA_oe,
    input [31:0] i_sdr_DATA,
    output [3:0] o_sdr_DQM
);

assign o_sdr_state	= '1;

assign o_AXI4_RLAST 	= '0;
assign o_AXI4_RID 	= '0;
assign o_AXI4_BID 	= '0;

assign o_sdr_CKE 	= '0;
assign o_sdr_n_CS 	= '0;
assign o_sdr_n_RAS 	= '0;
assign o_sdr_n_CAS 	= '0;
assign o_sdr_n_WE 	= '0;
assign o_sdr_BA 	= '0;
assign o_sdr_ADDR 	= '0;
assign o_sdr_DATA 	= '0;
assign o_sdr_DATA_oe 	= '0;
assign o_sdr_DQM 	= '0;


axi4_lite_ram #(
    .RAM_SIZE(25),
    .ZERO_INIT(1)
) u_sdram_emu (
    .i_clk(i_sysclk),
    .i_rst(~i_aresetn),

    .o_AWREADY(o_AXI4_AWREADY),
    .o_WREADY(o_AXI4_WREADY),

    .o_BVALID(o_AXI4_BVALID),
    .i_BREADY(i_AXI4_BREADY),
    .o_BRESP(o_BRESP),

    .i_ARVALID(i_AXI4_ARVALID),
    .o_ARREADY(o_AXI4_ARREADY),
    .i_ARADDR(i_AXI4_ARADDR),
    .i_ARPROT('0),
    
    .o_RVALID(o_AXI4_RVALID),
    .i_RREADY(i_AXI4_RREADY),
    .o_RDATA(o_AXI4_RDATA),
    .o_RRESP(o_AXI4_RRESP),

    .i_AWVALID(i_AXI4_AWVALID),
    .i_AWADDR(i_AXI4_AWADDR),
    .i_AWPROT('0),

    .i_WVALID(i_AXI4_WVALID),
    .i_WDATA(i_AXI4_WDATA),
    .i_WSTRB(i_AXI4_WSTRB)
);


endmodule
