module tcp #(
    parameter NUM_TCP=8,
    parameter DATA_WIDTH=8
)(
    input i_clk,
    input i_rst,

    input  wire                         m_cpuif_req,
    input  wire                         m_cpuif_req_is_wr,
    input  wire [4:0]                   m_cpuif_addr,
    input  wire [31:0]                  m_cpuif_wr_data,
    input  wire [31:0]                  m_cpuif_wr_biten,
    output wire                         m_cpuif_req_stall_wr,
    output wire                         m_cpuif_req_stall_rd,
    output wire                         m_cpuif_rd_ack,
    output wire                         m_cpuif_rd_err,
    output wire [31:0]                  m_cpuif_rd_data,
    output wire                         m_cpuif_wr_ack,
    output wire                         m_cpuif_wr_err

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
    input  wire                         s_ip_payload_axis_tvalid
    output wire                         s_ip_payload_axis_tready
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
    output wire                         m_ip_payload_axis_tvalid
    input  wire                         m_ip_payload_axis_tready
    output wire                         m_ip_payload_axis_tlast,
    output wire                         m_ip_payload_axis_tuser
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


//m2s dma

//s2m dma

// tx_stream demux (ip)

// rx_stream arb (ip)


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
            .clk                    (i_clk),
            .rst                    (i_rst),

            // This is the hacky decoder alex was telling me about
            .s_cpuif_req            (req),
            .s_cpuif_req_is_wr      (req_is_wr),
            .s_cpuif_addr           (addr),
            .s_cpuif_wr_data        (wr_data),
            .s_cpuif_wr_biten       (wr_biten),
            .s_cpuif_req_stall_wr   (),
            .s_cpuif_req_stall_rd   (),
            .s_cpuif_rd_ack         (tcp_hwif_in.tcp_streams[i].rd_ack),
            .s_cpuif_rd_err         (),
            .s_cpuif_rd_data        (tcp_hwif_in.tcp_streams[i].rd_data),
            .s_cpuif_wr_ack         (tcp_hwif_in.tcp_streams[i].wr_ack),
            .s_cpuif_wr_err         (),
        );
    end
endgenerate

endmodule