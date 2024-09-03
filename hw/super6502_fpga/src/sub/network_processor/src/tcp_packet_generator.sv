module tcp_packet_generator (
    input  wire             i_clk,
    input  wire             i_rst,

    axis_intf.SLAVE         s_axis_data,

    input  wire [31:0]      i_seq_number,
    input  wire [31:0]      i_ack_number,
    input  wire [15:0]      i_source_port,
    input  wire [15:0]      i_dest_port,
    input  wire [7:0]       i_flags,
    input  wire [15:0]      i_window_size,
    input  wire             i_hdr_valid,

    input  wire [31:0]      i_src_ip,
    input  wire [31:0]      i_dst_ip,

    ip_intf.MASTER          m_ip
);

always_comb begin
    m_ip.ip_hdr_valid = '0;

    if (i_hdr_valid) begin
        m_ip.ip_hdr_valid   = '1;
        m_ip.ip_dscp        = '0;
        m_ip.ip_ecn         = '0;
        m_ip.ip_length      = '0;
        m_ip.ip_ttl         = '1;
        m_ip.ip_protocol    = 8'h6;
        m_ip.ip_source_ip   = i_src_ip;
        m_ip.ip_dest_ip     = i_dst_ip;
    end
end

endmodule