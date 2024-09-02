module tb_top(
    input   wire            clk,
    input   wire            rst,

    output  wire            s_regs_axil_awready,
    input   wire            s_regs_axil_awvalid,
    input   wire [31:0]     s_regs_axil_awaddr,
    input   wire [2:0]      s_regs_axil_awprot,
    output  wire            s_regs_axil_wready,
    input   wire            s_regs_axil_wvalid,
    input   wire [31:0]     s_regs_axil_wdata,
    input   wire [3:0]      s_regs_axil_wstrb,
    input   wire            s_regs_axil_bready,
    output  wire            s_regs_axil_bvalid,
    output  wire [1:0]      s_regs_axil_bresp,
    output  wire            s_regs_axil_arready,
    input   wire            s_regs_axil_arvalid,
    input   wire [31:0]     s_regs_axil_araddr,
    input   wire [2:0]      s_regs_axil_arprot,
    input   wire            s_regs_axil_rready,
    output  wire            s_regs_axil_rvalid,
    output  wire [31:0]     s_regs_axil_rdata,
    output  wire [1:0]      s_regs_axil_rresp,

    input   wire            m_dma_axil_awready,
    output  wire            m_dma_axil_awvalid,
    output  wire [31:0]     m_dma_axil_awaddr,
    output  wire [2:0]      m_dma_axil_awprot,
    input   wire            m_dma_axil_wready,
    output  wire            m_dma_axil_wvalid,
    output  wire [31:0]     m_dma_axil_wdata,
    output  wire [3:0]      m_dma_axil_wstrb,
    output  wire            m_dma_axil_bready,
    input   wire            m_dma_axil_bvalid,
    input   wire [1:0]      m_dma_axil_bresp,
    input   wire            m_dma_axil_arready,
    output  wire            m_dma_axil_arvalid,
    output  wire [31:0]     m_dma_axil_araddr,
    output  wire [2:0]      m_dma_axil_arprot,
    output  wire            m_dma_axil_rready,
    input   wire            m_dma_axil_rvalid,
    input   wire [31:0]     m_dma_axil_rdata,
    input   wire [1:0]      m_dma_axil_rresp,

    //MII Interface
    input   wire            mii_rx_clk,
    input   wire    [3:0]   mii_rxd,
    input   wire            mii_rx_dv,
    input   wire            mii_rx_er,
    input   wire            mii_tx_clk,
    output  wire    [3:0]   mii_txd,
    output  wire            mii_tx_en,
    output  wire            mii_tx_er
);

axil_intf regs_axil();
axil_intf dma_axil();

assign dma_axil.awready     = m_dma_axil_awready;
assign m_dma_axil_awvalid   = dma_axil.awvalid;
assign m_dma_axil_awaddr    = dma_axil.awaddr;
assign m_dma_axil_awprot    = dma_axil.awprot;
assign dma_axil.wready      = m_dma_axil_wready;
assign m_dma_axil_wvalid    = dma_axil.wvalid;
assign m_dma_axil_wdata     = dma_axil.wdata;
assign m_dma_axil_wstrb     = dma_axil.wstrb;
assign m_dma_axil_bready    = dma_axil.bready;
assign dma_axil.bvalid      = m_dma_axil_bvalid;
assign dma_axil.bresp       = m_dma_axil_bresp;
assign dma_axil.arready     = m_dma_axil_arready;
assign m_dma_axil_arvalid   = dma_axil.arvalid;
assign m_dma_axil_araddr    = dma_axil.araddr;
assign m_dma_axil_arprot    = dma_axil.arprot;
assign m_dma_axil_rready    = dma_axil.rready;
assign dma_axil.rvalid      = m_dma_axil_rvalid;
assign dma_axil.rdata       = m_dma_axil_rdata;
assign dma_axil.rresp       = m_dma_axil_rresp;

assign s_regs_axil_awready  = regs_axil.awready;
assign regs_axil.awvalid    = s_regs_axil_awvalid;
assign regs_axil.awaddr     = s_regs_axil_awaddr;
assign regs_axil.awprot     = s_regs_axil_awprot;
assign s_regs_axil_wready   = regs_axil.wready;
assign regs_axil.wvalid     = s_regs_axil_wvalid;
assign regs_axil.wdata      = s_regs_axil_wdata;
assign regs_axil.wstrb      = s_regs_axil_wstrb;
assign regs_axil.bready     = s_regs_axil_bready;
assign s_regs_axil_bvalid   = regs_axil.bvalid;
assign s_regs_axil_bresp    = regs_axil.bresp;
assign s_regs_axil_arready  = regs_axil.arready;
assign regs_axil.arvalid    = s_regs_axil_arvalid;
assign regs_axil.araddr     = s_regs_axil_araddr;
assign regs_axil.arprot     = s_regs_axil_arprot;
assign regs_axil.rready     = s_regs_axil_rready;
assign s_regs_axil_rvalid   = regs_axil.rvalid;
assign s_regs_axil_rdata    = regs_axil.rdata;
assign s_regs_axil_rresp    = regs_axil.rresp;



network_processor #(
    .NUM_TCP(8)
) u_network_processor (
    .i_clk                  (clk),
    .i_rst                  (rst),

    .s_reg_axil             (regs_axil),
    .m_dma_axil             (dma_axil),

    .mii_rx_clk             (mii_rx_clk),
    .mii_rxd                (mii_rxd),
    .mii_rx_dv              (mii_rx_dv),
    .mii_rx_er              (mii_rx_er),
    .mii_tx_clk             (mii_tx_clk),
    .mii_txd                (mii_txd),
    .mii_tx_en              (mii_tx_en),
    .mii_tx_er              (mii_tx_er)
);

endmodule