module tcp_packet_generator (
    input  wire             i_clk,
    input  wire             i_rst

    axis_intf.SLAVE         s_axis_data,

    input  wire [31:0]      i_seq_number,
    input  wire [31:0]      i_ack_number,
    input  wire [15:0]      i_source_port,
    input  wire [15:0]      i_dest_port,
    input  wire [7:0]       i_flags,
    input  wire [15:0]      i_window_size
    input  wire             i_hdr_valid

    ip_intf.MASTER          m_ip
);

endmodule