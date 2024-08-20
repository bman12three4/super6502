module tcp_stream #(
    parameter DATA_WIDTH = 8,
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
    parameter DEST_WIDTH = 8,
    parameter USER_WIDTH = 1
)(
    input wire clk,
    input wire rst,

    input wire s_cpuif_req,
    input wire s_cpuif_req_is_wr,
    input wire [4:0] s_cpuif_addr,
    input wire [31:0] s_cpuif_wr_data,
    input wire [31:0] s_cpuif_wr_biten,
    output wire s_cpuif_req_stall_wr,
    output wire s_cpuif_req_stall_rd,
    output wire s_cpuif_rd_ack,
    output wire s_cpuif_rd_err,
    output wire [31:0] s_cpuif_rd_data,
    output wire s_cpuif_wr_ack,
    output wire s_cpuif_wr_err,

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

// regs
tcp_stream_regs_pkg::tcp_stream_regs__in_t hwif_in;
tcp_stream_regs_pkg::tcp_stream_regs__out_t hwif_out;


tcp_stream_regs u_tcp_stream_regs (
    .clk                    (clk),
    .rst                    (rst),

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

// tcp state manager

// tx buffer

// tx control

// packet generator

// parser

// rx control

// rx buffer

endmodule