module network_processor #(
    parameter NUM_TCP=8
)(
    input i_clk,
    input i_rst,

    output  logic                       s_reg_axil_awready,
    input   wire                        s_reg_axil_awvalid,
    input   wire [8:0]                  s_reg_axil_awaddr,
    input   wire [2:0]                  s_reg_axil_awprot,
    output  logic                       s_reg_axil_wready,
    input   wire                        s_reg_axil_wvalid,
    input   wire [31:0]                 s_reg_axil_wdata,
    input   wire [3:0]                  s_reg_axil_wstrb,
    input   wire                        s_reg_axil_bready,
    output  logic                       s_reg_axil_bvalid,
    output  logic [1:0]                 s_reg_axil_bresp,
    output  logic                       s_reg_axil_arready,
    input   wire                        s_reg_axil_arvalid,
    input   wire [8:0]                  s_reg_axil_araddr,
    input   wire [2:0]                  s_reg_axil_arprot,
    input   wire                        s_reg_axil_rready,
    output  logic                       s_reg_axil_rvalid,
    output  logic [31:0]                s_reg_axil_rdata,
    output  logic [1:0]                 s_reg_axil_rresp,

    // axil for m2s/s2m dma (can be combined into 1 or separate)

    // axil for ring buffer managers

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

localparam MAC_DATA_WIDTH = 8;
localparam AXIS_DATA_WIDTH = 8;
localparam AXIS_KEEP_WIDTH = ((AXIS_DATA_WIDTH+7)/8);

logic   [AXIS_DATA_WIDTH-1:0]           mac_tx_axis_tdata;
logic                                   mac_tx_axis_tvalid;
logic                                   mac_tx_axis_tready;
logic                                   mac_tx_axis_tlast;
logic                                   mac_tx_axis_tuser;
logic   [AXIS_KEEP_WIDTH-1:0]           mac_tx_axis_tkeep;

logic   [AXIS_DATA_WIDTH-1:0]           mac_rx_axis_tdata;
logic                                   mac_rx_axis_tvalid;
logic                                   mac_rx_axis_tready;
logic                                   mac_rx_axis_tlast;
logic                                   mac_rx_axis_tuser;
logic   [AXIS_KEEP_WIDTH-1:0]           mac_rx_axis_tkeep;

logic                                   mac_tx_eth_hdr_valid;
logic                                   mac_tx_eth_hdr_ready;
logic   [47:0]                          mac_tx_eth_dest_mac;
logic   [47:0]                          mac_tx_eth_src_mac;
logic   [15:0]                          mac_tx_eth_type;
logic   [AXIS_DATA_WIDTH-1:0]           mac_tx_eth_payload_axis_tdata;
logic   [AXIS_KEEP_WIDTH-1:0]           mac_tx_eth_payload_axis_tkeep;
logic                                   mac_tx_eth_payload_axis_tvalid;
logic                                   mac_tx_eth_payload_axis_tready;
logic                                   mac_tx_eth_payload_axis_tlast;
logic                                   mac_tx_eth_payload_axis_tuser;

logic                                   mac_rx_eth_hdr_valid;
logic                                   mac_rx_eth_hdr_ready;
logic   [47:0]                          mac_rx_eth_dest_mac;
logic   [47:0]                          mac_rx_eth_src_mac;
logic   [15:0]                          mac_rx_eth_type;
logic   [AXIS_DATA_WIDTH-1:0]           mac_rx_eth_payload_axis_tdata;
logic   [AXIS_KEEP_WIDTH-1:0]           mac_rx_eth_payload_axis_tkeep;
logic                                   mac_rx_eth_payload_axis_tvalid;
logic                                   mac_rx_eth_payload_axis_tready;
logic                                   mac_rx_eth_payload_axis_tlast;
logic                                   mac_rx_eth_payload_axis_tuser;


// tx is less because IP adds it automatically.
logic                                   tx_ip_hdr_valid;
logic                                   tx_ip_hdr_ready;
logic   [5:0]                           tx_ip_dscp;
logic   [1:0]                           tx_ip_ecn;
logic   [15:0]                          tx_ip_length;
logic   [7:0]                           tx_ip_ttl;
logic   [7:0]                           tx_ip_protocol;
logic   [31:0]                          tx_ip_source_ip;
logic   [31:0]                          tx_ip_dest_ip;
logic   [7:0]                           tx_ip_payload_axis_tdata;
logic                                   tx_ip_payload_axis_tvalid;
logic                                   tx_ip_payload_axis_tready;
logic                                   tx_ip_payload_axis_tlast;
logic                                   tx_ip_payload_axis_tuser;

logic                                   tcp_rx_ip_hdr_valid;
logic                                   tcp_rx_ip_hdr_ready;
logic   [47:0]                          tcp_rx_ip_eth_dest_mac;
logic   [47:0]                          tcp_rx_ip_eth_src_mac;
logic   [15:0]                          tcp_rx_ip_eth_type;
logic   [3:0]                           tcp_rx_ip_version;
logic   [3:0]                           tcp_rx_ip_ihl;
logic   [5:0]                           tcp_rx_ip_dscp;
logic   [1:0]                           tcp_rx_ip_ecn;
logic   [15:0]                          tcp_rx_ip_length;
logic   [15:0]                          tcp_rx_ip_identification;
logic   [2:0]                           tcp_rx_ip_flags;
logic   [12:0]                          tcp_rx_ip_fragment_offset;
logic   [7:0]                           tcp_rx_ip_ttl;
logic   [7:0]                           tcp_rx_ip_protocol;
logic   [15:0]                          tcp_rx_ip_header_checksum;
logic   [31:0]                          tcp_rx_ip_source_ip;
logic   [31:0]                          tcp_rx_ip_dest_ip;
logic   [7:0]                           tcp_rx_ip_payload_axis_tdata;
logic                                   tcp_rx_ip_payload_axis_tvalid;
logic                                   tcp_rx_ip_payload_axis_tready;
logic                                   tcp_rx_ip_payload_axis_tlast;
logic                                   tcp_rx_ip_payload_axis_tuser;

// tx is less because IP adds it automatically.
logic                                   tcp_tx_ip_hdr_valid;
logic                                   tcp_tx_ip_hdr_ready;
logic   [5:0]                           tcp_tx_ip_dscp;
logic   [1:0]                           tcp_tx_ip_ecn;
logic   [15:0]                          tcp_tx_ip_length;
logic   [7:0]                           tcp_tx_ip_ttl;
logic   [7:0]                           tcp_tx_ip_protocol;
logic   [31:0]                          tcp_tx_ip_source_ip;
logic   [31:0]                          tcp_tx_ip_dest_ip;
logic   [7:0]                           tcp_tx_ip_payload_axis_tdata;
logic                                   tcp_tx_ip_payload_axis_tvalid;
logic                                   tcp_tx_ip_payload_axis_tready;
logic                                   tcp_tx_ip_payload_axis_tlast;
logic                                   tcp_tx_ip_payload_axis_tuser;

logic                                   udp_ip_hdr_valid;
logic                                   udp_ip_hdr_ready;
logic   [47:0]                          udp_ip_eth_dest_mac;
logic   [47:0]                          udp_ip_eth_src_mac;
logic   [15:0]                          udp_ip_eth_type;
logic   [3:0]                           udp_ip_version;
logic   [3:0]                           udp_ip_ihl;
logic   [5:0]                           udp_ip_dscp;
logic   [1:0]                           udp_ip_ecn;
logic   [15:0]                          udp_ip_length;
logic   [15:0]                          udp_ip_identification;
logic   [2:0]                           udp_ip_flags;
logic   [12:0]                          udp_ip_fragment_offset;
logic   [7:0]                           udp_ip_ttl;
logic   [7:0]                           udp_ip_protocol;
logic   [15:0]                          udp_ip_header_checksum;
logic   [31:0]                          udp_ip_source_ip;
logic   [31:0]                          udp_ip_dest_ip;
logic   [7:0]                           udp_ip_payload_axis_tdata;
logic                                   udp_ip_payload_axis_tvalid;
logic                                   udp_ip_payload_axis_tready;
logic                                   udp_ip_payload_axis_tlast;
logic                                   udp_ip_payload_axis_tuser;

// tx is less because IP adds it automatically.
logic                                   udp_tx_ip_hdr_valid;
logic                                   udp_tx_ip_hdr_ready;
logic   [5:0]                           udp_tx_ip_dscp;
logic   [1:0]                           udp_tx_ip_ecn;
logic   [15:0]                          udp_tx_ip_length;
logic   [7:0]                           udp_tx_ip_ttl;
logic   [7:0]                           udp_tx_ip_protocol;
logic   [31:0]                          udp_tx_ip_source_ip;
logic   [31:0]                          udp_tx_ip_dest_ip;
logic   [7:0]                           udp_tx_ip_payload_axis_tdata;
logic                                   udp_tx_ip_payload_axis_tvalid;
logic                                   udp_tx_ip_payload_axis_tready;
logic                                   udp_tx_ip_payload_axis_tlast;
logic                                   udp_tx_ip_payload_axis_tuser;

logic                                   icmp_ip_hdr_valid;
logic                                   icmp_ip_hdr_ready;
logic   [47:0]                          icmp_ip_eth_dest_mac;
logic   [47:0]                          icmp_ip_eth_src_mac;
logic   [15:0]                          icmp_ip_eth_type;
logic   [3:0]                           icmp_ip_version;
logic   [3:0]                           icmp_ip_ihl;
logic   [5:0]                           icmp_ip_dscp;
logic   [1:0]                           icmp_ip_ecn;
logic   [15:0]                          icmp_ip_length;
logic   [15:0]                          icmp_ip_identification;
logic   [2:0]                           icmp_ip_flags;
logic   [12:0]                          icmp_ip_fragment_offset;
logic   [7:0]                           icmp_ip_ttl;
logic   [7:0]                           icmp_ip_protocol;
logic   [15:0]                          icmp_ip_header_checksum;
logic   [31:0]                          icmp_ip_source_ip;
logic   [31:0]                          icmp_ip_dest_ip;
logic   [7:0]                           icmp_ip_payload_axis_tdata;
logic                                   icmp_ip_payload_axis_tvalid;
logic                                   icmp_ip_payload_axis_tready;
logic                                   icmp_ip_payload_axis_tlast;
logic                                   icmp_ip_payload_axis_tuser;

// tx is less because IP adds it automatically.
logic                                   icmp_tx_ip_hdr_valid;
logic                                   icmp_tx_ip_hdr_ready;
logic   [5:0]                           icmp_tx_ip_dscp;
logic   [1:0]                           icmp_tx_ip_ecn;
logic   [15:0]                          icmp_tx_ip_length;
logic   [7:0]                           icmp_tx_ip_ttl;
logic   [7:0]                           icmp_tx_ip_protocol;
logic   [31:0]                          icmp_tx_ip_source_ip;
logic   [31:0]                          icmp_tx_ip_dest_ip;
logic   [7:0]                           icmp_tx_ip_payload_axis_tdata;
logic                                   icmp_tx_ip_payload_axis_tvalid;
logic                                   icmp_tx_ip_payload_axis_tready;
logic                                   icmp_tx_ip_payload_axis_tlast;
logic                                   icmp_tx_ip_payload_axis_tuser;

ntw_top_regfile_pkg::ntw_top_regfile__in_t hwif_in;
ntw_top_regfile_pkg::ntw_top_regfile__out_t hwif_out;

ntw_top_regfile u_ntw_top_regfile (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_axil_awready                     (s_reg_axil_awready),
    .s_axil_awvalid                     (s_reg_axil_awvalid),
    .s_axil_awaddr                      (s_reg_axil_awaddr),
    .s_axil_awprot                      (s_reg_axil_awprot),
    .s_axil_wready                      (s_reg_axil_wready),
    .s_axil_wvalid                      (s_reg_axil_wvalid),
    .s_axil_wdata                       (s_reg_axil_wdata),
    .s_axil_wstrb                       (s_reg_axil_wstrb),
    .s_axil_bready                      (s_reg_axil_bready),
    .s_axil_bvalid                      (s_reg_axil_bvalid),
    .s_axil_bresp                       (s_reg_axil_bresp),
    .s_axil_arready                     (s_reg_axil_arready),
    .s_axil_arvalid                     (s_reg_axil_arvalid),
    .s_axil_araddr                      (s_reg_axil_araddr),
    .s_axil_arprot                      (s_reg_axil_arprot),
    .s_axil_rready                      (s_reg_axil_rready),
    .s_axil_rvalid                      (s_reg_axil_rvalid),
    .s_axil_rdata                       (s_reg_axil_rdata),
    .s_axil_rresp                       (s_reg_axil_rresp),

    .hwif_in                            (hwif_in),
    .hwif_out                           (hwif_out)
);

// eth wrapper
eth_wrapper #(
    .MAC_DATA_WIDTH(MAC_DATA_WIDTH)
) u_eth_wrapper (
    .rst                                (i_rst),
    .clk_sys                            (i_clk),

    // MII
    .mii_rx_clk                         (mii_rx_clk),
    .mii_rxd                            (mii_rxd),
    .mii_rx_dv                          (mii_rx_dv),
    .mii_rx_er                          (mii_rx_er),
    .mii_tx_clk                         (mii_tx_clk),
    .mii_txd                            (mii_txd),
    .mii_tx_en                          (mii_tx_en),
    .mii_tx_er                          (mii_tx_er),

    .tx_axis_tdata                      (mac_tx_axis_tdata),
    .tx_axis_tvalid                     (mac_tx_axis_tvalid),
    .tx_axis_tready                     (mac_tx_axis_tready),
    .tx_axis_tlast                      (mac_tx_axis_tlast),
    .tx_axis_tuser                      (mac_tx_axis_tuser),
    .tx_axis_tkeep                      (mac_tx_axis_tkeep),

    .rx_axis_tdata                      (mac_rx_axis_tdata),
    .rx_axis_tvalid                     (mac_rx_axis_tvalid),
    .rx_axis_tready                     (mac_rx_axis_tready),
    .rx_axis_tlast                      (mac_rx_axis_tlast),
    .rx_axis_tuser                      (mac_rx_axis_tuser),
    .rx_axis_tkeep                      (mac_rx_axis_tkeep),

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

    .s_axis_tdata                       (mac_rx_axis_tdata),
    .s_axis_tvalid                      (mac_rx_axis_tvalid),
    .s_axis_tready                      (mac_rx_axis_tready),
    .s_axis_tlast                       (mac_rx_axis_tlast),
    .s_axis_tuser                       (mac_rx_axis_tuser),
    .s_axis_tkeep                       (mac_rx_axis_tkeep),

    .m_eth_hdr_valid                    (mac_rx_eth_hdr_valid),
    .m_eth_hdr_ready                    (mac_rx_eth_hdr_ready),
    .m_eth_dest_mac                     (mac_rx_eth_dest_mac),
    .m_eth_src_mac                      (mac_rx_eth_src_mac),
    .m_eth_type                         (mac_rx_eth_type),
    .m_eth_payload_axis_tdata           (mac_rx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep           (mac_rx_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid          (mac_rx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready          (mac_rx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast           (mac_rx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser           (mac_rx_eth_payload_axis_tuser),

    .busy                               (),
    .error_header_early_termination     () // We can add this to a register
);

eth_axis_tx #(
    .DATA_WIDTH(MAC_DATA_WIDTH)
) u_mac_eth_axis_tx (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_eth_hdr_valid                    (mac_tx_eth_hdr_valid),
    .s_eth_hdr_ready                    (mac_tx_eth_hdr_ready),
    .s_eth_dest_mac                     (mac_tx_eth_dest_mac),
    .s_eth_src_mac                      (mac_tx_eth_src_mac),
    .s_eth_type                         (mac_tx_eth_type),
    .s_eth_payload_axis_tdata           (mac_tx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep           (mac_tx_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid          (mac_tx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready          (mac_tx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast           (mac_tx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser           (mac_tx_eth_payload_axis_tuser),

    .m_axis_tdata                       (mac_tx_axis_tdata),
    .m_axis_tvalid                      (mac_tx_axis_tvalid),
    .m_axis_tready                      (mac_tx_axis_tready),
    .m_axis_tlast                       (mac_tx_axis_tlast),
    .m_axis_tuser                       (mac_tx_axis_tuser),
    .m_axis_tkeep                       (mac_tx_axis_tkeep),

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

    .s_eth_hdr_valid                    (mac_rx_eth_hdr_valid),
    .s_eth_hdr_ready                    (mac_rx_eth_hdr_ready),
    .s_eth_dest_mac                     (mac_rx_eth_dest_mac),
    .s_eth_src_mac                      (mac_rx_eth_src_mac),
    .s_eth_type                         (mac_rx_eth_type),
    .s_eth_payload_axis_tdata           (mac_rx_eth_payload_axis_tdata),
    .s_eth_payload_axis_tvalid          (mac_rx_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready          (mac_rx_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast           (mac_rx_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser           (mac_rx_eth_payload_axis_tuser),

    .m_eth_hdr_valid                    (mac_tx_eth_hdr_valid),
    .m_eth_hdr_ready                    (mac_tx_eth_hdr_ready),
    .m_eth_dest_mac                     (mac_tx_eth_dest_mac),
    .m_eth_src_mac                      (mac_tx_eth_src_mac),
    .m_eth_type                         (mac_tx_eth_type),
    .m_eth_payload_axis_tdata           (mac_tx_eth_payload_axis_tdata),
    .m_eth_payload_axis_tvalid          (mac_tx_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready          (mac_tx_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast           (mac_tx_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser           (mac_tx_eth_payload_axis_tuser),

    .s_ip_hdr_valid                     (tx_ip_hdr_valid),
    .s_ip_hdr_ready                     (tx_ip_hdr_ready),
    .s_ip_dscp                          (tx_ip_dscp),
    .s_ip_ecn                           (tx_ip_ecn),
    .s_ip_length                        (tx_ip_length),
    .s_ip_ttl                           (tx_ip_ttl),
    .s_ip_protocol                      (tx_ip_protocol),
    .s_ip_source_ip                     (tx_ip_source_ip),
    .s_ip_dest_ip                       (tx_ip_dest_ip),
    .s_ip_payload_axis_tdata            (tx_ip_payload_axis_tdata),
    .s_ip_payload_axis_tvalid           (tx_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready           (tx_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast            (tx_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser            (tx_ip_payload_axis_tuser),

    .m_ip_hdr_valid                     (rx_ip_hdr_valid),
    .m_ip_hdr_ready                     (rx_ip_hdr_ready),
    .m_ip_eth_dest_mac                  (rx_ip_eth_dest_mac),
    .m_ip_eth_src_mac                   (rx_ip_eth_src_mac),
    .m_ip_eth_type                      (rx_ip_eth_type),
    .m_ip_version                       (rx_ip_version),
    .m_ip_ihl                           (rx_ip_ihl),
    .m_ip_dscp                          (rx_ip_dscp),
    .m_ip_ecn                           (rx_ip_ecn),
    .m_ip_length                        (rx_ip_length),
    .m_ip_identification                (rx_ip_identification),
    .m_ip_flags                         (rx_ip_flags),
    .m_ip_fragment_offset               (rx_ip_fragment_offset),
    .m_ip_ttl                           (rx_ip_ttl),
    .m_ip_protocol                      (rx_ip_protocol),
    .m_ip_header_checksum               (rx_ip_header_checksum),
    .m_ip_source_ip                     (rx_ip_source_ip),
    .m_ip_dest_ip                       (rx_ip_dest_ip),
    .m_ip_payload_axis_tdata            (rx_ip_payload_axis_tdata),
    .m_ip_payload_axis_tvalid           (rx_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready           (rx_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast            (rx_ip_payload_axis_tlast),
    .m_ip_payload_axis_tuser            (rx_ip_payload_axis_tuser),

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


ip_demux #(
    .M_COUNT(3),
    .DATA_WIDTH(MAC_DATA_WIDTH)
) u_ip_demux (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_ip_hdr_valid                     (rx_ip_hdr_valid),
    .s_ip_hdr_ready                     (rx_ip_hdr_ready),
    .s_eth_dest_mac                     (rx_ip_eth_dest_mac),
    .s_eth_src_mac                      (rx_ip_eth_src_mac),
    .s_eth_type                         (rx_ip_eth_type),
    .s_ip_version                       (rx_ip_version),
    .s_ip_ihl                           (rx_ip_ihl),
    .s_ip_dscp                          (rx_ip_dscp),
    .s_ip_ecn                           (rx_ip_ecn),
    .s_ip_length                        (rx_ip_length),
    .s_ip_identification                (rx_ip_identification),
    .s_ip_flags                         (rx_ip_flags),
    .s_ip_fragment_offset               (rx_ip_fragment_offset),
    .s_ip_ttl                           (rx_ip_ttl),
    .s_ip_protocol                      (rx_ip_protocol),
    .s_ip_header_checksum               (rx_ip_header_checksum),
    .s_ip_source_ip                     (rx_ip_source_ip),
    .s_ip_dest_ip                       (rx_ip_dest_ip),
    .s_ip_payload_axis_tdata            (rx_ip_payload_axis_tdata),
    .s_ip_payload_axis_tvalid           (rx_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready           (rx_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast            (rx_ip_payload_axis_tlast),
    .s_ip_payload_axis_tuser            (rx_ip_payload_axis_tuser),

    .m_ip_hdr_valid                     ({icmp_ip_hdr_valid,            udp_ip_hdr_valid,             tcp_tx_ip_hdr_valid}),
    .m_ip_hdr_ready                     ({icmp_ip_hdr_ready,            udp_ip_hdr_ready,             tcp_tx_ip_hdr_ready}),
    .m_eth_dest_mac                     ({icmp_ip_eth_dest_mac,         udp_ip_eth_dest_mac,          tcp_tx_ip_eth_dest_mac}),
    .m_eth_src_mac                      ({icmp_ip_eth_src_mac,          udp_ip_eth_src_mac,           tcp_tx_ip_eth_src_mac}),
    .m_eth_type                         ({icmp_ip_eth_type,             udp_ip_eth_type,              tcp_tx_ip_eth_type}),
    .m_ip_version                       ({icmp_ip_version,              udp_ip_version,               tcp_tx_ip_version}),
    .m_ip_ihl                           ({icmp_ip_ihl,                  udp_ip_ihl,                   tcp_tx_ip_ihl}),
    .m_ip_dscp                          ({icmp_ip_dscp,                 udp_ip_dscp,                  tcp_tx_ip_dscp}),
    .m_ip_ecn                           ({icmp_ip_ecn,                  udp_ip_ecn,                   tcp_tx_ip_ecn}),
    .m_ip_length                        ({icmp_ip_length,               udp_ip_length,                tcp_tx_ip_length}),
    .m_ip_identification                ({icmp_ip_identification,       udp_ip_identification,        tcp_tx_ip_identification}),
    .m_ip_flags                         ({icmp_ip_flags,                udp_ip_flags,                 tcp_tx_ip_flags}),
    .m_ip_fragment_offset               ({icmp_ip_fragment_offset,      udp_ip_fragment_offset,       tcp_tx_ip_fragment_offset}),
    .m_ip_ttl                           ({icmp_ip_ttl,                  udp_ip_ttl,                   tcp_tx_ip_ttl}),
    .m_ip_protocol                      ({icmp_ip_protocol,             udp_ip_protocol,              tcp_tx_ip_protocol}),
    .m_ip_header_checksum               ({icmp_ip_header_checksum,      udp_ip_header_checksum,       tcp_tx_ip_header_checksum}),
    .m_ip_source_ip                     ({icmp_ip_source_ip,            udp_ip_source_ip,             tcp_tx_ip_source_ip}),
    .m_ip_dest_ip                       ({icmp_ip_dest_ip,              udp_ip_dest_ip,               tcp_tx_ip_dest_ip}),
    .m_ip_payload_axis_tdata            ({icmp_ip_payload_axis_tdata,   udp_ip_payload_axis_tdata,    tcp_tx_ip_payload_axis_tdata}),
    .m_ip_payload_axis_tkeep            (),
    .m_ip_payload_axis_tvalid           ({icmp_ip_payload_axis_tvalid,  udp_ip_payload_axis_tvalid,   tcp_tx_ip_payload_axis_tvalid}),
    .m_ip_payload_axis_tready           ({icmp_ip_payload_axis_tready,  udp_ip_payload_axis_tready,   tcp_tx_ip_payload_axis_tready}),
    .m_ip_payload_axis_tlast            ({icmp_ip_payload_axis_tlast,   udp_ip_payload_axis_tlast,    tcp_tx_ip_payload_axis_tlast}),
    .m_ip_payload_axis_tid              (),
    .m_ip_payload_axis_tdest            (),
    .m_ip_payload_axis_tuser            ({icmp_ip_payload_axis_tuser,   udp_ip_payload_axis_tuser,    tcp_tx_ip_payload_axis_tuser}),
    .enable                             ('1),
    .drop                               (ip_demux_drop),
    .select                             (ip_demux_sel)
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
    .s_cpuif_wr_err                     ()
);
endmodule