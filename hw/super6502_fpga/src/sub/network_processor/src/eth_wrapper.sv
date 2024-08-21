module eth_wrapper #(
    parameter MAC_DATA_WIDTH=8,
    parameter MAC_KEEP_WIDTH = ((MAC_DATA_WIDTH+7)/8)
)(
    input  wire                       rst,
    input  wire                       clk_sys,

    /*
     * AXI input
     */
    input  wire [MAC_DATA_WIDTH-1:0]  tx_axis_tdata,
    input  wire [MAC_KEEP_WIDTH-1:0]  tx_axis_tkeep,
    input  wire                       tx_axis_tvalid,
    output wire                       tx_axis_tready,
    input  wire                       tx_axis_tlast,
    input  wire                       tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [MAC_DATA_WIDTH-1:0]  rx_axis_tdata,
    output wire [MAC_KEEP_WIDTH-1:0]  rx_axis_tkeep,
    output wire                       rx_axis_tvalid,
    input  wire                       rx_axis_tready,
    output wire                       rx_axis_tlast,
    output wire                       rx_axis_tuser,

    /*
     * MII interface
     */
    input  wire                       mii_rx_clk,
    input  wire [3:0]                 mii_rxd,
    input  wire                       mii_rx_dv,
    input  wire                       mii_rx_er,
    input  wire                       mii_tx_clk,
    output wire [3:0]                 mii_txd,
    output wire                       mii_tx_en,
    output wire                       mii_tx_er,


    /*
     * CPUIF interface
     */
    input  wire                       s_cpuif_req,
    input  wire                       s_cpuif_req_is_wr,
    input  wire [4:0]                 s_cpuif_addr,
    input  wire [31:0]                s_cpuif_wr_data,
    input  wire [31:0]                s_cpuif_wr_biten,
    output wire                       s_cpuif_req_stall_wr,
    output wire                       s_cpuif_req_stall_rd,
    output wire                       s_cpuif_rd_ack,
    output wire                       s_cpuif_rd_err,
    output wire [31:0]                s_cpuif_rd_data,
    output wire                       s_cpuif_wr_ack,
    output wire                       s_cpuif_wr_err,

    // MDIO Interface
    input  wire                       Mdi,
    output wire                       Mdo,
    output wire                       MdoEn,
    output wire                       Mdc,


    output wire                       phy_rstn
);

assign Mdo = '0;
assign MdoEn = '0;
assign Mdc = '0;

mac_regs_pkg::mac_regs__in_t hwif_in;
mac_regs_pkg::mac_regs__out_t hwif_out;

mac_regs u_mac_regs(
    .clk(clk_sys),
    .rst(rst),

    .s_cpuif_req            (s_cpuif_req),
    .s_cpuif_req_is_wr      (s_cpuif_req_is_wr),
    .s_cpuif_addr           (s_cpuif_addr),
    .s_cpuif_wr_data        (s_cpuif_wr_data),
    .s_cpuif_wr_biten       (s_cpuif_wr_biten),
    .s_cpuif_req_stall_wr   (s_cpuif_req_stall_wr),
    .s_cpuif_req_stall_rd   (s_cpuif_req_stall_rd),
    .s_cpuif_rd_ack         (s_cpuif_rd_ack),
    .s_cpuif_rd_err         (s_cpuif_rd_err),
    .s_cpuif_rd_data        (s_cpuif_rd_data),
    .s_cpuif_wr_ack         (s_cpuif_wr_ack),
    .s_cpuif_wr_err         (s_cpuif_wr_err),

    .hwif_in                (hwif_in),
    .hwif_out               (hwif_out)
);

assign phy_rstn = hwif_out.ctrl.phy_rstn.value;

eth_mac_mii_fifo #(
    .TARGET("GENERIC"),
    .AXIS_DATA_WIDTH(MAC_DATA_WIDTH),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_DEPTH(4096),
    .TX_FIFO_RAM_PIPELINE(1),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(4096),
    .RX_FIFO_RAM_PIPELINE(1),
    .RX_FRAME_FIFO(1)
) u_mac (
    .rst                (reset),
    .logic_clk          (clk_100),
    .logic_rst          (reset),

    .tx_axis_tdata      (tx_axis_tdata),
    .tx_axis_tkeep      (tx_axis_tkeep),
    .tx_axis_tvalid     (tx_axis_tvalid),
    .tx_axis_tready     (tx_axis_tready),
    .tx_axis_tlast      (tx_axis_tlast),
    .tx_axis_tuser      ('0),

    .rx_axis_tdata      (rx_axis_tdata),
    .rx_axis_tkeep      (rx_axis_tkeep),
    .rx_axis_tvalid     (rx_axis_tvalid),
    .rx_axis_tready     (rx_axis_tready),
    .rx_axis_tlast      (rx_axis_tlast),
    .rx_axis_tuser      (rx_axis_tuser),

    .mii_rx_clk         (mii_rx_clk),
    .mii_rxd            (mii_rxd_mux),
    .mii_rx_dv          (mii_rx_dv_mux),
    .mii_rx_er          (mii_rx_er_mux),
    .mii_tx_clk         (mii_tx_clk),
    .mii_txd            (mii_txd),
    .mii_tx_en          (mii_tx_en),
    .mii_tx_er          (mii_tx_er),

    .tx_error_underflow (hwif_in.stats.tx_error_underflow.hwset),
    .tx_fifo_overflow   (hwif_in.stats.tx_fifo_overflow.hwset),
    .tx_fifo_bad_frame  (hwif_in.stats.tx_fifo_bad_frame.hwset),
    .tx_fifo_good_frame (hwif_in.stats.tx_fifo_good_frame.hwset),
    .rx_error_bad_frame (hwif_in.stats.rx_error_bad_frame.hwset),
    .rx_error_bad_fcs   (hwif_in.stats.rx_error_bad_fcs.hwset),
    .rx_fifo_overflow   (hwif_in.stats.rx_fifo_overflow.hwset),
    .rx_fifo_bad_frame  (hwif_in.stats.rx_fifo_bad_frame.hwset),
    .rx_fifo_good_frame (hwif_in.stats.rx_fifo_good_frame.hwset),

    .cfg_ifg            (hwif_out.ctrl.ifg.value),
    .cfg_tx_enable      (hwif_out.ctrl.tx_en.value),   // this should be configurable w/ regfile
    .cfg_rx_enable      (hwif_out.ctrl.rx_en.value)
);

endmodule