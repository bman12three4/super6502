module network_processor #(
    parameter NUM_TCP=8
)(
    input i_clk,
    input i_rst,

    axil_intf.SLAVE                     s_reg_axil,
    axil_intf.MASTER                    m_dma_axil,

    //MII Interface
    input   wire                        mii_rx_clk,
    input   wire    [3:0]               mii_rxd,
    input   wire                        mii_rx_dv,
    input   wire                        mii_rx_er,
    input   wire                        mii_tx_clk,
    output  wire    [3:0]               mii_txd,
    output  wire                        mii_tx_en,
    output  wire                        mii_tx_er,

    // MDIO Interface
    input                               i_Mdi,
    output                              o_Mdo,
    output                              o_MdoEn,
    output                              o_Mdc,

    output                              phy_rstn

);

`define PROTO_ICMP 8'h1
`define PROTO_TCP 8'h6
`define PROTO_UDP 8'h11

localparam ICMP_IDX = 0;
localparam UDP_IDX = 1;
localparam TCP_IDX = 2;

localparam MAC_DATA_WIDTH = 8;
localparam AXIS_DATA_WIDTH = 8;
localparam AXIS_KEEP_WIDTH = ((AXIS_DATA_WIDTH+7)/8);

axis_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) mac_tx_axis();
axis_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) mac_rx_axis();

ip_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) mac_tx_ip();
ip_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) mac_rx_ip();

eth_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) mac_tx_eth();
eth_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) mac_rx_eth();

ip_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) ntw_tx_ip();
ip_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) ntw_rx_ip();

ip_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) proto_rx_ip[3]();
ip_intf #(.DATA_WIDTH(MAC_DATA_WIDTH)) proto_tx_ip[3]();

ntw_top_regfile_pkg::ntw_top_regfile__in_t hwif_in;
ntw_top_regfile_pkg::ntw_top_regfile__out_t hwif_out;

ntw_top_regfile u_ntw_top_regfile (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_axil_awready                     (s_reg_axil.awready),
    .s_axil_awvalid                     (s_reg_axil.awvalid),
    .s_axil_awaddr                      (s_reg_axil.awaddr),
    .s_axil_awprot                      (s_reg_axil.awprot),
    .s_axil_wready                      (s_reg_axil.wready),
    .s_axil_wvalid                      (s_reg_axil.wvalid),
    .s_axil_wdata                       (s_reg_axil.wdata),
    .s_axil_wstrb                       (s_reg_axil.wstrb),
    .s_axil_bready                      (s_reg_axil.bready),
    .s_axil_bvalid                      (s_reg_axil.bvalid),
    .s_axil_bresp                       (s_reg_axil.bresp),
    .s_axil_arready                     (s_reg_axil.arready),
    .s_axil_arvalid                     (s_reg_axil.arvalid),
    .s_axil_araddr                      (s_reg_axil.araddr),
    .s_axil_arprot                      (s_reg_axil.arprot),
    .s_axil_rready                      (s_reg_axil.rready),
    .s_axil_rvalid                      (s_reg_axil.rvalid),
    .s_axil_rdata                       (s_reg_axil.rdata),
    .s_axil_rresp                       (s_reg_axil.rresp),

    .hwif_in                            (hwif_in),
    .hwif_out                           (hwif_out)
);

// eth wrapper
eth_wrapper #(
    .MAC_DATA_WIDTH(MAC_DATA_WIDTH)
) u_eth_wrapper (
    .rst                                (i_rst),
    .clk_sys                            (i_clk),

    .s_cpuif_req                        (hwif_out.mac.req),
    .s_cpuif_req_is_wr                  (hwif_out.mac.req_is_wr),
    .s_cpuif_addr                       (hwif_out.mac.addr),
    .s_cpuif_wr_data                    (hwif_out.mac.wr_data),
    .s_cpuif_wr_biten                   (hwif_out.mac.wr_biten),
    .s_cpuif_req_stall_wr               (),
    .s_cpuif_req_stall_rd               (),
    .s_cpuif_rd_ack                     (hwif_in.mac.rd_ack),
    .s_cpuif_rd_err                     (),
    .s_cpuif_rd_data                    (hwif_in.mac.rd_data),
    .s_cpuif_wr_ack                     (hwif_in.mac.wr_ack),
    .s_cpuif_wr_err                     (),

    // MII
    .mii_rx_clk                         (mii_rx_clk),
    .mii_rxd                            (mii_rxd),
    .mii_rx_dv                          (mii_rx_dv),
    .mii_rx_er                          (mii_rx_er),
    .mii_tx_clk                         (mii_tx_clk),
    .mii_txd                            (mii_txd),
    .mii_tx_en                          (mii_tx_en),
    .mii_tx_er                          (mii_tx_er),

    .tx_axis                            (mac_tx_axis),
    .rx_axis                            (mac_rx_axis),

    .Mdi                                (i_Mdi),
    .Mdo                                (o_Mdo),
    .MdoEn                              (o_MdoEn),
    .Mdc                                (o_Mdc)
);

eth_axis_rx #(
    .DATA_WIDTH(MAC_DATA_WIDTH)
) u_mac_eth_axis_rx (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_axis_tdata                       (mac_rx_axis.tdata),
    .s_axis_tvalid                      (mac_rx_axis.tvalid),
    .s_axis_tready                      (mac_rx_axis.tready),
    .s_axis_tlast                       (mac_rx_axis.tlast),
    .s_axis_tuser                       (mac_rx_axis.tuser),
    .s_axis_tkeep                       (mac_rx_axis.tkeep),

    .m_eth_hdr_valid                    (mac_rx_eth.eth_hdr_valid),
    .m_eth_hdr_ready                    (mac_rx_eth.eth_hdr_ready),
    .m_eth_dest_mac                     (mac_rx_eth.eth_dest_mac),
    .m_eth_src_mac                      (mac_rx_eth.eth_src_mac),
    .m_eth_type                         (mac_rx_eth.eth_type),
    .m_eth_payload_axis_tdata           (mac_rx_eth.eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep           (mac_rx_eth.eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid          (mac_rx_eth.eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready          (mac_rx_eth.eth_payload_axis_tready),
    .m_eth_payload_axis_tlast           (mac_rx_eth.eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser           (mac_rx_eth.eth_payload_axis_tuser),

    .busy                               (),
    .error_header_early_termination     () // We can add this to a register
);

eth_axis_tx #(
    .DATA_WIDTH(MAC_DATA_WIDTH)
) u_mac_eth_axis_tx (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_eth_hdr_valid                    (mac_tx_eth.eth_hdr_valid),
    .s_eth_hdr_ready                    (mac_tx_eth.eth_hdr_ready),
    .s_eth_dest_mac                     (mac_tx_eth.eth_dest_mac),
    .s_eth_src_mac                      (mac_tx_eth.eth_src_mac),
    .s_eth_type                         (mac_tx_eth.eth_type),
    .s_eth_payload_axis_tdata           (mac_tx_eth.eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep           (mac_tx_eth.eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid          (mac_tx_eth.eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready          (mac_tx_eth.eth_payload_axis_tready),
    .s_eth_payload_axis_tlast           (mac_tx_eth.eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser           (mac_tx_eth.eth_payload_axis_tuser),

    .m_axis_tdata                       (mac_tx_axis.tdata),
    .m_axis_tvalid                      (mac_tx_axis.tvalid),
    .m_axis_tready                      (mac_tx_axis.tready),
    .m_axis_tlast                       (mac_tx_axis.tlast),
    .m_axis_tuser                       (mac_tx_axis.tuser),
    .m_axis_tkeep                       (mac_tx_axis.tkeep),

    .busy                               ()
);


// this is 8 bit only, we should assert that data width is 8 at this point.

ip_complete #(
    .ARP_CACHE_ADDR_WIDTH(7),    // memory usage is 81 bits per entry
    .ARP_REQUEST_RETRY_COUNT(4),
    .ARP_REQUEST_RETRY_INTERVAL(125000000*2),   // these are defaults
    .ARP_REQUEST_TIMEOUT(125000000*30)
) u_ip_complete (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_eth_hdr_valid                    (mac_rx_eth.eth_hdr_valid),
    .s_eth_hdr_ready                    (mac_rx_eth.eth_hdr_ready),
    .s_eth_dest_mac                     (mac_rx_eth.eth_dest_mac),
    .s_eth_src_mac                      (mac_rx_eth.eth_src_mac),
    .s_eth_type                         (mac_rx_eth.eth_type),
    .s_eth_payload_axis_tdata           (mac_rx_eth.eth_payload_axis_tdata),
    .s_eth_payload_axis_tvalid          (mac_rx_eth.eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready          (mac_rx_eth.eth_payload_axis_tready),
    .s_eth_payload_axis_tlast           (mac_rx_eth.eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser           (mac_rx_eth.eth_payload_axis_tuser),

    .m_eth_hdr_valid                    (mac_tx_eth.eth_hdr_valid),
    .m_eth_hdr_ready                    (mac_tx_eth.eth_hdr_ready),
    .m_eth_dest_mac                     (mac_tx_eth.eth_dest_mac),
    .m_eth_src_mac                      (mac_tx_eth.eth_src_mac),
    .m_eth_type                         (mac_tx_eth.eth_type),
    .m_eth_payload_axis_tdata           (mac_tx_eth.eth_payload_axis_tdata),
    .m_eth_payload_axis_tvalid          (mac_tx_eth.eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready          (mac_tx_eth.eth_payload_axis_tready),
    .m_eth_payload_axis_tlast           (mac_tx_eth.eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser           (mac_tx_eth.eth_payload_axis_tuser),

    .s_ip_hdr_valid                     (ntw_tx_ip.ip_hdr_valid),
    .s_ip_hdr_ready                     (ntw_tx_ip.ip_hdr_ready),
    .s_ip_dscp                          (ntw_tx_ip.ip_dscp),
    .s_ip_ecn                           (ntw_tx_ip.ip_ecn),
    .s_ip_length                        (ntw_tx_ip.ip_length),
    .s_ip_ttl                           (ntw_tx_ip.ip_ttl),
    .s_ip_protocol                      (ntw_tx_ip.ip_protocol),
    .s_ip_source_ip                     (ntw_tx_ip.ip_source_ip),
    .s_ip_dest_ip                       (ntw_tx_ip.ip_dest_ip),
    .s_ip_payload_axis_tdata            (ntw_tx_ip.ip_payload_axis_tdata),
    .s_ip_payload_axis_tvalid           (ntw_tx_ip.ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready           (ntw_tx_ip.ip_payload_axis_tready),
    .s_ip_payload_axis_tlast            (ntw_tx_ip.ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser            (ntw_tx_ip.ip_payload_axis_tuser),

    .m_ip_hdr_valid                     (ntw_rx_ip.ip_hdr_valid),
    .m_ip_hdr_ready                     (ntw_rx_ip.ip_hdr_ready),
    .m_ip_eth_dest_mac                  (ntw_rx_ip.eth_dest_mac),
    .m_ip_eth_src_mac                   (ntw_rx_ip.eth_src_mac),
    .m_ip_eth_type                      (ntw_rx_ip.eth_type),
    .m_ip_version                       (ntw_rx_ip.ip_version),
    .m_ip_ihl                           (ntw_rx_ip.ip_ihl),
    .m_ip_dscp                          (ntw_rx_ip.ip_dscp),
    .m_ip_ecn                           (ntw_rx_ip.ip_ecn),
    .m_ip_length                        (ntw_rx_ip.ip_length),
    .m_ip_identification                (ntw_rx_ip.ip_identification),
    .m_ip_flags                         (ntw_rx_ip.ip_flags),
    .m_ip_fragment_offset               (ntw_rx_ip.ip_fragment_offset),
    .m_ip_ttl                           (ntw_rx_ip.ip_ttl),
    .m_ip_protocol                      (ntw_rx_ip.ip_protocol),
    .m_ip_header_checksum               (ntw_rx_ip.ip_header_checksum),
    .m_ip_source_ip                     (ntw_rx_ip.ip_source_ip),
    .m_ip_dest_ip                       (ntw_rx_ip.ip_dest_ip),
    .m_ip_payload_axis_tdata            (ntw_rx_ip.ip_payload_axis_tdata),
    .m_ip_payload_axis_tvalid           (ntw_rx_ip.ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready           (ntw_rx_ip.ip_payload_axis_tready),
    .m_ip_payload_axis_tlast            (ntw_rx_ip.ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser            (ntw_rx_ip.ip_payload_axis_tuser),

    .rx_busy                            (), // should go to stats register
    .tx_busy                            (), // should go to stats register
    .rx_error_header_early_termination  (), // should go to stats register
    .rx_error_payload_early_termination (), // should go to stats register
    .rx_error_invalid_header            (), // should go to stats register
    .rx_error_invalid_checksum          (), // should go to stats register
    .tx_error_payload_early_termination (), // should go to stats register
    .tx_error_arp_failed                (), // should go to stats register

    .local_mac                          (48'h020000aabbcc), // should be a register
    .local_ip                           (32'hac000002),     // should be a register
    .gateway_ip                         (32'hac000001),     // should be a register
    .subnet_mask                        (32'hffffff00),     // should be a register
    .clear_arp_cache                    ('0)                // should come from sw
);


logic ip_demux_drop;
assign ip_demux_drop = !((ntw_rx_ip.ip_protocol == `PROTO_ICMP) || (ntw_rx_ip.ip_protocol == `PROTO_UDP) || (ntw_rx_ip.ip_protocol == `PROTO_TCP));

logic [1:0] ip_demux_sel;
assign ip_demux_sel = (ntw_rx_ip.ip_protocol == `PROTO_ICMP) ? 2'h2 : (ntw_rx_ip.ip_protocol == `PROTO_UDP) ? 2'h1 : 2'h0;


ip_demux_wrapper #(
    .M_COUNT(3),
    .DATA_WIDTH(MAC_DATA_WIDTH)
) u_ip_demux (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_ip                               (ntw_rx_ip),
    .m_ip                               (proto_rx_ip),

    .enable                             ('1),
    .drop                               (ip_demux_drop),
    .select                             (ip_demux_sel)
);

assign proto_rx_ip[ICMP_IDX].ip_hdr_ready = '1;
assign proto_rx_ip[ICMP_IDX].ip_payload_axis_tready = '1;
assign proto_rx_ip[UDP_IDX].ip_hdr_ready = '1;
assign proto_rx_ip[UDP_IDX].ip_payload_axis_tready = '1;

ip_arb_mux_wrapper #(
    .S_COUNT(3),
    .DATA_WIDTH(MAC_DATA_WIDTH)
)  u_ip_arb_mux (
    .i_clk                              (i_clk),
    .i_rst                              (i_rst),

    .s_ip                               (proto_tx_ip),
    .m_ip                               (ntw_tx_ip)
);

tcp #(
    .NUM_TCP(NUM_TCP)
) tcp (
    .i_clk                              (i_clk),
    .i_rst                              (i_rst),

    .s_cpuif_req                        (hwif_out.tcp_top.req),
    .s_cpuif_req_is_wr                  (hwif_out.tcp_top.req_is_wr),
    .s_cpuif_addr                       (hwif_out.tcp_top.addr),
    .s_cpuif_wr_data                    (hwif_out.tcp_top.wr_data),
    .s_cpuif_wr_biten                   (hwif_out.tcp_top.wr_biten),
    .s_cpuif_req_stall_wr               (),
    .s_cpuif_req_stall_rd               (),
    .s_cpuif_rd_ack                     (hwif_in.tcp_top.rd_ack),
    .s_cpuif_rd_err                     (),
    .s_cpuif_rd_data                    (hwif_in.tcp_top.rd_data),
    .s_cpuif_wr_ack                     (hwif_in.tcp_top.wr_ack),
    .s_cpuif_wr_err                     (),

    .s_ip                               (proto_rx_ip[TCP_IDX]),
    .m_ip                               (proto_tx_ip[TCP_IDX]),

    .m_dma_axil                         (m_dma_axil)
);
endmodule