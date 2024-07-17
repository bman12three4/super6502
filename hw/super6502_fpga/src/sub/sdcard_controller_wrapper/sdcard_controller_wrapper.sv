module sd_controller_wrapper(
    input                   i_clk_100,
    input                   i_rst_100,

    input   logic           i_ctrl_AWVALID,
    output  logic           o_ctrl_AWREADY,
    input   logic   [31:0]  i_ctrl_AWADDR,
    input   logic   [2:0]   i_ctrl_AWPROT,

    input   logic           i_ctrl_WVALID,
    output  logic           o_ctrl_WREADY,
    input   logic   [31:0]  i_ctrl_WDATA,
    input   logic   [3:0]   i_ctrl_WSTRB,

    output  logic           o_ctrl_BVALID,
    input   logic           i_ctrl_BREADY,
    output  logic   [1:0]   o_ctrl_BRESP,

    input   logic           i_ctrl_ARVALID,
    output  logic           o_ctrl_ARREADY,
    input   logic   [31:0]  i_ctrl_ARADDR,
    input   logic   [2:0]   i_ctrl_ARPROT,

    output  logic           o_ctrl_RVALID,
    input   logic           i_ctrl_RREADY,
    output  logic   [31:0]  o_ctrl_RDATA,
    output  logic   [1:0]   o_ctrl_RRESP,

    output  logic           o_dma_AWVALID,
    input   logic           i_dma_AWREADY,
    output  logic   [31:0]  o_dma_AWADDR,
    output  logic   [2:0]   o_dma_AWPROT,

    output  logic           o_dma_WVALID,
    input   logic           i_dma_WREADY,
    output  logic   [31:0]  o_dma_WDATA,
    output  logic   [31:0]  o_dma_WSTRB,

    input   logic           i_dma_BVALID,
    output  logic           o_dma_BREADY,
    input   logic   [1:0]   i_dma_BRESP,

    output  logic           o_dma_ARVALID,
    input   logic           i_dma_ARREADY,
    output  logic   [31:0]  o_dma_ARADDR,
    output  logic   [2:0]   o_dma_ARPROT,

    input   logic           i_dma_RVALID,
    output  logic           o_dma_RREADY,
    input   logic   [31:0]  i_dma_RDATA,
    input   logic   [1:0]   i_dma_RRESP,

    input   wire    [3:0]   sd_dat_dat_i,   //Data in from SDcard
    output  wire    [3:0]   sd_dat_out_o,   //Data out to SDcard
    output  wire            sd_dat_oe_o,    //SD Card tristate Data Output enable (Connects on the SoC TopLevel)

    input   wire            sd_cmd_dat_i,   //Command in from SDcard
    output  wire            sd_cmd_out_o,   //Command out to SDcard
    output  wire            sd_cmd_oe_o     //SD Card tristate CMD Output enable (Connects on the SoC TopLevel)
);

logic           wb_reset;
logic           wb_clock;

logic   [31:0]  wb_ctrl_data_i;
logic   [31:0]  wb_ctrl_data_o;
logic   [31:0]  wb_ctrl_addr_i; // need to do address offset either here or in xbar
logic   [3:0]   wb_ctrl_sel_i;
logic           wb_ctrl_we_i;
logic           wb_ctrl_cyc_i;
logic           wb_ctrl_stb_i;
logic           wb_ctrl_ack_o;

logic   [31:0]  wb_dma_adr_o;
logic   [3:0]   wb_dma_sel_o;
logic           wb_dma_we_o;
logic   [31:0]  wb_dma_dat_i;
logic   [31:0]  wb_dma_dat_o;
logic           wb_dma_cyc_o;
logic           wb_dma_stb_o;
logic           wb_dma_ack_i;
logic   [2:0]   wb_dma_cti_o;
logic   [1:0]	wb_dma_bte_o;


//axilite2wbsp
axilite2wbsp #(
    .C_AXI_DATA_WIDTH(32),
    .C_AXI_ADDR_WIDTH(32),
    .LGFIFO(4),
    .OPT_READONLY(0),
    .OPT_WRITEONLY(0)
) u_axilite2wbsp (
    .i_clk          (i_clk_100),
    .i_axi_reset_n  (~i_rst_100),

    .i_axi_awvalid  (i_ctrl_AWVALID),
    .o_axi_awready  (o_ctrl_AWREADY),
    .i_axi_awaddr   (i_ctrl_AWADDR),
    .i_axi_awprot   (i_ctrl_AWPROT),

    .i_axi_wvalid   (i_ctrl_AWVALID),
    .o_axi_wready   (o_ctrl_WREADY),
    .i_axi_wdata    (i_ctrl_WDATA),
    .i_axi_wstrb    (i_ctrl_WSTRB),

    .o_axi_bvalid   (o_ctrl_BVALID),
    .i_axi_bready   (i_ctrl_BREADY),
    .o_axi_bresp    (o_ctrl_BRESP),

    .i_axi_arvalid  (i_ctrl_ARVALID),
    .o_axi_arready  (o_ctrl_ARREADY),
    .i_axi_araddr   (i_ctrl_ARADDR),
    .i_axi_arprot   (i_ctrl_ARPROT),

    .o_axi_rvalid   (o_ctrl_RVALID),
    .i_axi_rready   (i_ctrl_RREADY),
    .o_axi_rdata    (o_ctrl_rdata),
    .o_axi_rresp    (o_ctrl_rresp),

    .o_reset        (wb_reset),

    .o_wb_cyc       (wb_ctrl_cyc_i),
    .o_wb_stb       (wb_ctrl_stb_i),
    .o_wb_we        (wb_ctrl_we_i),
    .o_wb_addr      (wb_ctrl_addr_i),
    .o_wb_data      (wb_ctrl_data_i),
    .o_wb_sel       (wb_ctrl_sel_i),
    .i_wb_stall     ('0),
    .i_wb_ack       (wb_ctrl_ack_o),
    .i_wb_data      (wb_ctrl_data_o),
    .i_wb_err       ('0)
);

//wb2axilite
wbm2axilite #(
    .C_AXI_ADDR_WIDTH(32)
) u_wbm2axilite (
    .i_clk          (i_clk_100),
    .i_reset        (wb_reset),

    .i_wb_cyc       (wb_dma_cyc_o),
    .i_wb_stb       (wb_dma_stb_o),
    .i_wb_we        (wb_dma_we_o),
    .i_wb_addr      (wb_dma_adr_o),
    .i_wb_data      (wb_dma_dat_o),
    .i_wb_sel       (wb_dma_sel_o),
    .o_wb_stall     (),
    .o_wb_ack       (wb_dma_ack_i),
    .o_wb_data      (wb_dma_dat_i),
    .o_wb_err       (),

    .o_axi_awvalid  (o_dma_AWVALID),
    .i_axi_awready  (i_dma_AWREADY),
    .o_axi_awaddr   (o_dma_AWADDR),
    .o_axi_awprot   (o_dma_AWPROT),

    .o_axi_wvalid   (o_dma_WVALID),
    .i_axi_wready   (i_dma_WREADY),
    .o_axi_wdata    (o_dma_WDATA),
    .o_axi_wstrb    (o_dma_WSTRB),

    .i_axi_bvalid   (i_dma_BVALID),
    .o_axi_bready   (o_dma_BREADY),
    .i_axi_bresp    (i_dma_BRESP),

    .o_axi_arvalid  (o_dma_ARVALID),
    .i_axi_arready  (i_dma_ARREADY),
    .o_axi_araddr   (o_dma_ARADDR),
    .o_axi_arprot   (o_dma_ARPROT),

    .i_axi_rvalid   (i_dma_RVALID),
    .o_axi_rready   (o_dma_RREADY),
    .i_axi_rdata    (i_dma_RDATA),
    .i_axi_rresp    (i_dma_RRESP)
);

//sdc controller
sdc_controller u_sdc_controller (
    .wb_clk_i       (i_clk_100),
    .wb_rst_i       (wb_reset),

    .wb_dat_i       (wb_ctrl_data_i),
    .wb_dat_o       (wb_ctrl_data_o),
    .wb_adr_i       (wb_ctrl_addr_i),
    .wb_sel_i       (wb_ctrl_sel_i),
    .wb_we_i        (wb_ctrl_we_i),
    .wb_cyc_i       (wb_ctrl_cyc_i),
    .wb_stb_i       (wb_ctrl_stb_i),
    .wb_ack_o       (wb_ctrl_ack_o),

    .m_wb_adr_o     (wb_dma_adr_o),
    .m_wb_sel_o     (wb_dma_sel_o),
    .m_wb_we_o      (wb_dma_we_o),
    .m_wb_dat_o     (wb_dma_dat_o),
    .m_wb_dat_i     (wb_dma_dat_i),
    .m_wb_cyc_o     (wb_dma_cyc_o),
    .m_wb_stb_o     (wb_dma_stb_o),
    .m_wb_ack_i     (wb_dma_ack_i),
    .m_wb_cti_o     (),                 // uhh, guys?
    .m_wb_bte_o     (),

    .sd_cmd_dat_i   (sd_cmd_i),
    .sd_cmd_dat_o   (sd_cmd_o),
    .sd_cmd_oe_o    (sd_cmd_oe),
    .sd_dat_dat_i   (sd_dat_i),
    .sd_dat_dat_o   (sd_dat_o),
    .sd_dat_oe_o    (sd_dat_oe),

    .card_detect    (sd_cd),
    .sd_clk_o_pad   (sd_clk)
);


endmodule