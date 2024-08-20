module tcp #(
    parameter NUM_TCP=8,
    parameter DATA_WIDTH=8
)(
    input i_clk,
    input i_rst,

    input  wire                         s_cpuif_req,
    input  wire                         s_cpuif_req_is_wr,
    input  wire [4:0]                   s_cpuif_addr,
    input  wire [31:0]                  s_cpuif_wr_data,
    input  wire [31:0]                  s_cpuif_wr_biten,
    output wire                         s_cpuif_req_stall_wr,
    output wire                         s_cpuif_req_stall_rd,
    output wire                         s_cpuif_rd_ack,
    output wire                         s_cpuif_rd_err,
    output wire [31:0]                  s_cpuif_rd_data,
    output wire                         s_cpuif_wr_ack,
    output wire                         s_cpuif_wr_err,

    /*
     * IP input
     */
    input  wire                         s_ip_hdr_valid,
    output wire                         s_ip_hdr_ready,
    input  wire [47:0]                  s_ip_eth_dest_mac,
    input  wire [47:0]                  s_ip_eth_src_mac,
    input  wire [15:0]                  s_ip_eth_type,
    input  wire [3:0]                   s_ip_version,
    input  wire [3:0]                   s_ip_ihl,
    input  wire [5:0]                   s_ip_dscp,
    input  wire [1:0]                   s_ip_ecn,
    input  wire [15:0]                  s_ip_length,
    input  wire [15:0]                  s_ip_identification,
    input  wire [2:0]                   s_ip_flags,
    input  wire [12:0]                  s_ip_fragment_offset,
    input  wire [7:0]                   s_ip_ttl,
    input  wire [7:0]                   s_ip_protocol,
    input  wire [15:0]                  s_ip_header_checksum,
    input  wire [31:0]                  s_ip_source_ip,
    input  wire [31:0]                  s_ip_dest_ip,
    input  wire [7:0]                   s_ip_payload_axis_tdata,
    input  wire                         s_ip_payload_axis_tvalid,
    output wire                         s_ip_payload_axis_tready,
    input  wire                         s_ip_payload_axis_tlast,
    input  wire                         s_ip_payload_axis_tuser,

    /*
    * IP output
    */
    output wire                         m_ip_hdr_valid,
    input  wire                         m_ip_hdr_ready,
    output wire [5:0]                   m_ip_dscp,
    output wire [1:0]                   m_ip_ecn,
    output wire [15:0]                  m_ip_length,
    output wire [7:0]                   m_ip_ttl,
    output wire [7:0]                   m_ip_protocol,
    output wire [31:0]                  m_ip_source_ip,
    output wire [31:0]                  m_ip_dest_ip,
    output wire [7:0]                   m_ip_payload_axis_tdata,
    output wire                         m_ip_payload_axis_tvalid,
    input  wire                         m_ip_payload_axis_tready,
    output wire                         m_ip_payload_axis_tlast,
    output wire                         m_ip_payload_axis_tuser,

    /*
    * AXI DMA Interface
    */
    input  wire                         m_dma_axil_awready,
    output wire                         m_dma_axil_awvalid,
    output wire [31:0]                  m_dma_axil_awaddr,
    output wire [2:0]                   m_dma_axil_awprot,
    input  wire                         m_dma_axil_wready,
    output wire                         m_dma_axil_wvalid,
    output wire [31:0]                  m_dma_axil_wdata,
    output wire [3:0]                   m_dma_axil_wstrb,
    output wire                         m_dma_axil_bready,
    input  wire                         m_dma_axil_bvalid,
    input  wire [1:0]                   m_dma_axil_bresp,
    input  wire                         m_dma_axil_arready,
    output wire                         m_dma_axil_arvalid,
    output wire [31:0]                  m_dma_axil_araddr,
    output wire [2:0]                   m_dma_axil_arprot,
    output wire                         m_dma_axil_rready,
    input  wire                         m_dma_axil_rvalid,
    input  wire [31:0]                  m_dma_axil_rdata,
    input  wire [1:0]                   m_dma_axil_rresp,

    /*
    * AXI Ring buffer Interface
    */
    input  wire                         m_rb_axil_awready,
    output wire                         m_rb_axil_awvalid,
    output wire [31:0]                  m_rb_axil_awaddr,
    output wire [2:0]                   m_rb_axil_awprot,
    input  wire                         m_rb_axil_wready,
    output wire                         m_rb_axil_wvalid,
    output wire [31:0]                  m_rb_axil_wdata,
    output wire [3:0]                   m_rb_axil_wstrb,
    output wire                         m_rb_axil_bready,
    input  wire                         m_rb_axil_bvalid,
    input  wire [1:0]                   m_rb_axil_bresp,
    input  wire                         m_rb_axil_arready,
    output wire                         m_rb_axil_arvalid,
    output wire [31:0]                  m_rb_axil_araddr,
    output wire [2:0]                   m_rb_axil_arprot,
    output wire                         m_rb_axil_rready,
    input  wire                         m_rb_axil_rvalid,
    input  wire [31:0]                  m_rb_axil_rdata,
    input  wire [1:0]                   m_rb_axil_rresp
);

tcp_top_regfile_pkg::tcp_top_regfile__in_t tcp_hwif_in;
tcp_top_regfile_pkg::tcp_top_regfile__out_t tcp_hwif_out;


tcp_top_regfile u_tcp_top_regfile (
    .clk            (i_clk),
    .rst            (i_rst),

    .s_cpuif_req            (s_cpuif_req),
    .s_cpuif_req_is_wr      (s_cpuif_req_is_wr),
    .s_cpuif_addr           (s_cpuif_addr),
    .s_cpuif_wr_data        (s_cpuif_wr_data),
    .s_cpuif_wr_biten       (s_cpuif_wr_biten),
    .s_cpuif_req_stall_wr   (),
    .s_cpuif_req_stall_rd   (),
    .s_cpuif_rd_ack         (s_cpuif_rd_ack),
    .s_cpuif_rd_err         (),
    .s_cpuif_rd_data        (s_cpuif_rd_data),
    .s_cpuif_wr_ack         (s_cpuif_wr_ack),
    .s_cpuif_wr_err         (),

    .hwif_in        (tcp_hwif_in),
    .hwif_out       (tcp_hwif_out)
);

localparam KEEP_WIDTH = ((DATA_WIDTH+7)/8);
localparam USER_WIDTH = 1;
localparam DEST_WIDTH = 8;
localparam ID_WIDTH = 8;

logic [DATA_WIDTH-1:0]          m2s_tx_axis_tdata;
logic [KEEP_WIDTH-1:0]          m2s_tx_axis_tkeep;
logic                           m2s_tx_axis_tvalid;
logic                           m2s_tx_axis_tready;
logic                           m2s_tx_axis_tlast;
logic [DEST_WIDTH-1:0]          m2s_tx_axis_tdest;
logic [USER_WIDTH-1:0]          m2s_tx_axis_tuser;

logic [DATA_WIDTH-1:0]          s2m_rx_axis_tdata;
logic [KEEP_WIDTH-1:0]          s2m_rx_axis_tkeep;
logic                           s2m_rx_axis_tvalid;
logic                           s2m_rx_axis_tready;
logic                           s2m_rx_axis_tlast;
logic [DEST_WIDTH-1:0]          s2m_rx_axis_tdest;
logic [USER_WIDTH-1:0]          s2m_rx_axis_tuser;

logic [NUM_TCP*DATA_WIDTH-1:0]      stream_tx_axis_tdata;
logic [NUM_TCP*KEEP_WIDTH-1:0]      stream_tx_axis_tkeep;
logic [NUM_TCP-1:0]                 stream_tx_axis_tvalid;
logic [NUM_TCP-1:0]                 stream_tx_axis_tready;
logic [NUM_TCP-1:0]                 stream_tx_axis_tlast;
logic [NUM_TCP*DEST_WIDTH-1:0]      stream_tx_axis_tdest;
logic [NUM_TCP*USER_WIDTH-1:0]      stream_tx_axis_tuser;

logic [NUM_TCP*DATA_WIDTH-1:0]      stream_rx_axis_tdata;
logic [NUM_TCP*KEEP_WIDTH-1:0]      stream_rx_axis_tkeep;
logic [NUM_TCP-1:0]                 stream_rx_axis_tvalid;
logic [NUM_TCP-1:0]                 stream_rx_axis_tready;
logic [NUM_TCP-1:0]                 stream_rx_axis_tlast;
logic [NUM_TCP*DEST_WIDTH-1:0]      stream_rx_axis_tdest;
logic [NUM_TCP*USER_WIDTH-1:0]      stream_rx_axis_tuser;

logic [NUM_TCP-1:0]             tcp_rx_ip_hdr_valid;
logic [NUM_TCP-1:0]             tcp_rx_ip_hdr_ready;
logic [NUM_TCP*48-1:0]          tcp_rx_eth_dest_mac;
logic [NUM_TCP*48-1:0]          tcp_rx_eth_src_mac;
logic [NUM_TCP*16-1:0]          tcp_rx_eth_type;
logic [NUM_TCP*4-1:0]           tcp_rx_ip_version;
logic [NUM_TCP*4-1:0]           tcp_rx_ip_ihl;
logic [NUM_TCP*6-1:0]           tcp_rx_ip_dscp;
logic [NUM_TCP*2-1:0]           tcp_rx_ip_ecn;
logic [NUM_TCP*16-1:0]          tcp_rx_ip_length;
logic [NUM_TCP*16-1:0]          tcp_rx_ip_identification;
logic [NUM_TCP*3-1:0]           tcp_rx_ip_flags;
logic [NUM_TCP*13-1:0]          tcp_rx_ip_fragment_offset;
logic [NUM_TCP*8-1:0]           tcp_rx_ip_ttl;
logic [NUM_TCP*8-1:0]           tcp_rx_ip_protocol;
logic [NUM_TCP*16-1:0]          tcp_rx_ip_header_checksum;
logic [NUM_TCP*32-1:0]          tcp_rx_ip_source_ip;
logic [NUM_TCP*32-1:0]          tcp_rx_ip_dest_ip;
logic [NUM_TCP*DATA_WIDTH-1:0]  tcp_rx_ip_payload_axis_tdata;
logic [NUM_TCP*KEEP_WIDTH-1:0]  tcp_rx_ip_payload_axis_tkeep;
logic [NUM_TCP-1:0]             tcp_rx_ip_payload_axis_tvalid;
logic [NUM_TCP-1:0]             tcp_rx_ip_payload_axis_tready;
logic [NUM_TCP-1:0]             tcp_rx_ip_payload_axis_tlast;
logic [NUM_TCP*ID_WIDTH-1:0]    tcp_rx_ip_payload_axis_tid;
logic [NUM_TCP*DEST_WIDTH-1:0]  tcp_rx_ip_payload_axis_tdest;
logic [NUM_TCP*USER_WIDTH-1:0]  tcp_rx_ip_payload_axis_tuser;

logic [NUM_TCP-1:0]             tcp_tx_ip_hdr_valid;
logic [NUM_TCP-1:0]             tcp_tx_ip_hdr_ready;
logic [NUM_TCP*6-1:0]           tcp_tx_ip_dscp;
logic [NUM_TCP*2-1:0]           tcp_tx_ip_ecn;
logic [NUM_TCP*16-1:0]          tcp_tx_ip_length;
logic [NUM_TCP*8-1:0]           tcp_tx_ip_ttl;
logic [NUM_TCP*8-1:0]           tcp_tx_ip_protocol;
logic [NUM_TCP*32-1:0]          tcp_tx_ip_source_ip;
logic [NUM_TCP*32-1:0]          tcp_tx_ip_dest_ip;
logic [NUM_TCP*DATA_WIDTH-1:0]  tcp_tx_ip_payload_axis_tdata;
logic [NUM_TCP-1:0]             tcp_tx_ip_payload_axis_tvalid;
logic [NUM_TCP-1:0]             tcp_tx_ip_payload_axis_tready;
logic [NUM_TCP-1:0]             tcp_tx_ip_payload_axis_tlast;
logic [NUM_TCP*USER_WIDTH-1:0]  tcp_tx_ip_payload_axis_tuser;


// ring buffer manager

//m2s dma

// axis demux
axis_demux #(
    .M_COUNT(NUM_TCP),
    .DATA_WIDTH(DATA_WIDTH),
    .DEST_ENABLE(1),
    .TDEST_ROUTE(1)
) u_stream_tx_demux (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_axis_tdata                       (m2s_tx_axis_tdata),
    .s_axis_tkeep                       (m2s_tx_axis_tkeep),
    .s_axis_tvalid                      (m2s_tx_axis_tvalid),
    .s_axis_tready                      (m2s_tx_axis_tready),
    .s_axis_tlast                       (m2s_tx_axis_tlast),
    .s_axis_tid                         ('0),
    .s_axis_tdest                       (m2s_tx_axis_tdest),
    .s_axis_tuser                       (m2s_tx_axis_tuser),

    .m_axis_tdata                       (stream_tx_axis_tdata),
    .m_axis_tkeep                       (stream_tx_axis_tkeep),
    .m_axis_tvalid                      (stream_tx_axis_tvalid),
    .m_axis_tready                      (stream_tx_axis_tready),
    .m_axis_tlast                       (stream_tx_axis_tlast),
    .m_axis_tid                         (),
    .m_axis_tdest                       (stream_tx_axis_tdest),
    .m_axis_tuser                       (stream_tx_axis_tuser),

    .enable                             ('1),
    .drop                               ('0),
    .select                             ('0)    // route selected by tdest
);

//s2m dma

// axis mux
axis_arb_mux #(
    .S_COUNT(NUM_TCP),
    .DATA_WIDTH(DATA_WIDTH),
    .DEST_ENABLE(1)
) u_stream_rx_arb_mux (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_axis_tdata                       (stream_rx_axis_tdata),
    .s_axis_tkeep                       (stream_rx_axis_tkeep),
    .s_axis_tvalid                      (stream_rx_axis_tvalid),
    .s_axis_tready                      (stream_rx_axis_tready),
    .s_axis_tlast                       (stream_rx_axis_tlast),
    .s_axis_tid                         ('0),
    .s_axis_tdest                       (stream_rx_axis_tdest),
    .s_axis_tuser                       (stream_rx_axis_tuser),

    .m_axis_tdata                       (s2m_rx_axis_tdata),
    .m_axis_tkeep                       (s2m_rx_axis_tkeep),
    .m_axis_tvalid                      (s2m_rx_axis_tvalid),
    .m_axis_tready                      (s2m_rx_axis_tready),
    .m_axis_tlast                       (s2m_rx_axis_tlast),
    .m_axis_tid                         (),
    .m_axis_tdest                       (s2m_rx_axis_tdest),
    .m_axis_tuser                       (s2m_rx_axis_tuser)
);

// tx_stream arb mux (ip)
ip_arb_mux #(
    .S_COUNT(NUM_TCP),
    .DATA_WIDTH(DATA_WIDTH)
) u_tx_stream_arb_mux (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_ip_hdr_valid                     (tcp_tx_ip_hdr_valid),
    .s_ip_hdr_ready                     (tcp_tx_ip_hdr_ready),
    .s_eth_dest_mac                     ('0),
    .s_eth_src_mac                      ('0),
    .s_eth_type                         ('0),
    .s_ip_version                       ('0),
    .s_ip_ihl                           ('0),
    .s_ip_dscp                          (tcp_tx_ip_dscp),
    .s_ip_ecn                           (tcp_tx_ip_ecn),
    .s_ip_length                        (tcp_tx_ip_length),
    .s_ip_identification                ('0),
    .s_ip_flags                         ('0),
    .s_ip_fragment_offset               ('0),
    .s_ip_ttl                           (tcp_tx_ip_ttl),
    .s_ip_protocol                      (tcp_tx_ip_protocol),
    .s_ip_header_checksum               ('0),
    .s_ip_source_ip                     (tcp_tx_ip_source_ip),
    .s_ip_dest_ip                       (tcp_tx_ip_dest_ip),
    .s_ip_payload_axis_tdata            (tcp_tx_ip_payload_axis_tdata),
    .s_ip_payload_axis_tkeep            ('1),
    .s_ip_payload_axis_tvalid           (tcp_tx_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready           (tcp_tx_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast            (tcp_tx_ip_payload_axis_tlast),
    .s_ip_payload_axis_tid              ('0),
    .s_ip_payload_axis_tdest            ('0),
    .s_ip_payload_axis_tuser            (tcp_tx_ip_payload_axis_tuser),

    .m_ip_hdr_valid                     (m_ip_hdr_valid),
    .m_ip_hdr_ready                     (m_ip_hdr_ready),
    .m_eth_dest_mac                     (),
    .m_eth_src_mac                      (),
    .m_eth_type                         (),
    .m_ip_version                       (),
    .m_ip_ihl                           (),
    .m_ip_dscp                          (m_ip_dscp),
    .m_ip_ecn                           (m_ip_ecn),
    .m_ip_length                        (m_ip_length),
    .m_ip_identification                (),
    .m_ip_flags                         (),
    .m_ip_fragment_offset               (),
    .m_ip_ttl                           (m_ip_ttl),
    .m_ip_protocol                      (m_ip_protocol),
    .m_ip_header_checksum               (),
    .m_ip_source_ip                     (m_ip_source_ip),
    .m_ip_dest_ip                       (m_ip_dest_ip),
    .m_ip_payload_axis_tdata            (m_ip_payload_axis_tdata),
    .m_ip_payload_axis_tkeep            (),
    .m_ip_payload_axis_tvalid           (m_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready           (m_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast            (m_ip_payload_axis_tlast),
    .m_ip_payload_axis_tid              (),
    .m_ip_payload_axis_tdest            (),
    .m_ip_payload_axis_tuser            (m_ip_payload_axis_tuser)
);


// rx_stream demux (ip)


generate

    for (genvar i = 0; i < NUM_TCP; i++) begin
        logic req;
        logic req_is_wr;
        logic [5:0] addr;
        logic [31:0] wr_data;
        logic [31:0] wr_biten;

        assign req = tcp_hwif_out.tcp_streams[i].req;
        assign req_is_wr = tcp_hwif_out.tcp_streams[i].req_is_wr;
        assign addr = tcp_hwif_out.tcp_streams[i].addr;
        assign wr_data = tcp_hwif_out.tcp_streams[i].wr_data;
        assign wr_biten = tcp_hwif_out.tcp_streams[i].wr_biten;

        tcp_stream u_tcp_stream (
            .clk                        (i_clk),
            .rst                        (i_rst),

            // This is the hacky decoder alex was telling me about
            .s_cpuif_req                (req),
            .s_cpuif_req_is_wr          (req_is_wr),
            .s_cpuif_addr               (addr),
            .s_cpuif_wr_data            (wr_data),
            .s_cpuif_wr_biten           (wr_biten),
            .s_cpuif_req_stall_wr       (),
            .s_cpuif_req_stall_rd       (),
            .s_cpuif_rd_ack             (tcp_hwif_in.tcp_streams[i].rd_ack),
            .s_cpuif_rd_err             (),
            .s_cpuif_rd_data            (tcp_hwif_in.tcp_streams[i].rd_data),
            .s_cpuif_wr_ack             (tcp_hwif_in.tcp_streams[i].wr_ack),
            .s_cpuif_wr_err             (),

            .s_ip_hdr_valid             (tcp_rx_ip_hdr_valid[i]),
            .s_ip_hdr_ready             (tcp_rx_ip_hdr_ready[i]),
            .s_ip_eth_dest_mac          (tcp_rx_eth_dest_mac[i*48+:48]),
            .s_ip_eth_src_mac           (tcp_rx_eth_src_mac[i*48+:48]),
            .s_ip_eth_type              (tcp_rx_eth_type[i*16+:16]),
            .s_ip_version               (tcp_rx_ip_version[i*4+:4]),
            .s_ip_ihl                   (tcp_rx_ip_ihl[i*4+:4]),
            .s_ip_dscp                  (tcp_rx_ip_dscp[i*6+:6]),
            .s_ip_ecn                   (tcp_rx_ip_ecn),
            .s_ip_length                (tcp_rx_ip_length),
            .s_ip_identification        (tcp_rx_ip_identification),
            .s_ip_flags                 (tcp_rx_ip_flags),
            .s_ip_fragment_offset       (tcp_rx_ip_fragment_offset),
            .s_ip_ttl                   (tcp_rx_ip_ttl),
            .s_ip_protocol              (tcp_rx_ip_protocol),
            .s_ip_header_checksum       (tcp_rx_ip_header_checksum),
            .s_ip_source_ip             (tcp_rx_ip_source_ip),
            .s_ip_dest_ip               (tcp_rx_ip_dest_ip),
            .s_ip_payload_axis_tdata    (tcp_rx_ip_payload_axis_tdata),
            .s_ip_payload_axis_tvalid   (tcp_rx_ip_payload_axis_tvalid),
            .s_ip_payload_axis_tready   (tcp_rx_ip_payload_axis_tready),
            .s_ip_payload_axis_tlast    (tcp_rx_ip_payload_axis_tlast),
            .s_ip_payload_axis_tuser    (tcp_rx_ip_payload_axis_tuser),

            .m_ip_hdr_valid             (tcp_tx_ip_hdr_valid),
            .m_ip_hdr_ready             (tcp_tx_ip_hdr_ready),
            .m_ip_dscp                  (tcp_tx_ip_dscp),
            .m_ip_ecn                   (tcp_tx_ip_ecn),
            .m_ip_length                (tcp_tx_ip_length),
            .m_ip_ttl                   (tcp_tx_ip_ttl),
            .m_ip_protocol              (tcp_tx_ip_protocol),
            .m_ip_source_ip             (tcp_tx_ip_source_ip),
            .m_ip_dest_ip               (tcp_tx_ip_dest_ip),
            .m_ip_payload_axis_tdata    (tcp_tx_ip_payload_axis_tdata),
            .m_ip_payload_axis_tvalid   (tcp_tx_ip_payload_axis_tvalid),
            .m_ip_payload_axis_tready   (tcp_tx_ip_payload_axis_tready),
            .m_ip_payload_axis_tlast    (tcp_tx_ip_payload_axis_tlast),
            .m_ip_payload_axis_tuser    (tcp_tx_ip_payload_axis_tuser)
        );
    end
endgenerate

endmodule