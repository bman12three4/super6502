module ip_pipeline_register_wrapper(
    input logic clk,
    input logic rst,

    ip_intf.SLAVE s_ip,
    ip_intf.MASTER m_ip
);

assign m_ip.ip_hdr_valid        = s_ip.ip_hdr_valid;
assign s_ip.ip_hdr_ready        = m_ip.ip_hdr_ready;
assign m_ip.eth_dest_mac        = s_ip.eth_dest_mac;
assign m_ip.eth_src_mac         = s_ip.eth_src_mac;
assign m_ip.eth_type            = s_ip.eth_type;
assign m_ip.ip_version          = s_ip.ip_version;
assign m_ip.ip_ihl              = s_ip.ip_ihl;
assign m_ip.ip_dscp             = s_ip.ip_dscp;
assign m_ip.ip_ecn              = s_ip.ip_ecn;
assign m_ip.ip_length           = s_ip.ip_length;
assign m_ip.ip_identification   = s_ip.ip_identification;
assign m_ip.ip_flags            = s_ip.ip_flags;
assign m_ip.ip_fragment_offset  = s_ip.ip_fragment_offset;
assign m_ip.ip_ttl              = s_ip.ip_ttl;
assign m_ip.ip_protocol         = s_ip.ip_protocol;
assign m_ip.ip_header_checksum  = s_ip.ip_header_checksum;
assign m_ip.ip_source_ip        = s_ip.ip_source_ip;
assign m_ip.ip_dest_ip          = s_ip.ip_dest_ip;

axis_pipeline_register #(
    .DATA_WIDTH(s_ip.DATA_WIDTH),
    .KEEP_WIDTH(s_ip.KEEP_WIDTH),
    .ID_ENABLE(1),
    .ID_WIDTH(s_ip.ID_WIDTH),
    .DEST_ENABLE(1),
    .DEST_WIDTH(s_ip.DEST_WIDTH),
    .USER_WIDTH(s_ip.USER_WIDTH)
) u_reg (
    .clk(clk),
    .rst(rst),

    .s_axis_tdata   (s_ip.ip_payload_axis_tdata),
    .s_axis_tkeep   (s_ip.ip_payload_axis_tkeep),
    .s_axis_tvalid  (s_ip.ip_payload_axis_tvalid),
    .s_axis_tready  (s_ip.ip_payload_axis_tready),
    .s_axis_tlast   (s_ip.ip_payload_axis_tlast),
    .s_axis_tid     (s_ip.ip_payload_axis_tid),
    .s_axis_tdest   (s_ip.ip_payload_axis_tdest),
    .s_axis_tuser   (s_ip.ip_payload_axis_tuser),

    .m_axis_tdata   (m_ip.ip_payload_axis_tdata),
    .m_axis_tkeep   (m_ip.ip_payload_axis_tkeep),
    .m_axis_tvalid  (m_ip.ip_payload_axis_tvalid),
    .m_axis_tready  (m_ip.ip_payload_axis_tready),
    .m_axis_tlast   (m_ip.ip_payload_axis_tlast),
    .m_axis_tid     (m_ip.ip_payload_axis_tid),
    .m_axis_tdest   (m_ip.ip_payload_axis_tdest),
    .m_axis_tuser   (m_ip.ip_payload_axis_tuser)
);

endmodule