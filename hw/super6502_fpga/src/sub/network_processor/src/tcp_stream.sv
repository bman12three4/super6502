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
    input wire [5:0] s_cpuif_addr,
    input wire [31:0] s_cpuif_wr_data,
    input wire [31:0] s_cpuif_wr_biten,
    output wire s_cpuif_req_stall_wr,
    output wire s_cpuif_req_stall_rd,
    output wire s_cpuif_rd_ack,
    output wire s_cpuif_rd_err,
    output wire [31:0] s_cpuif_rd_data,
    output wire s_cpuif_wr_ack,
    output wire s_cpuif_wr_err,

    output logic [15:0] o_tcp_port,

    ip_intf.SLAVE s_ip_rx,
    ip_intf.MASTER m_ip_tx,

    axil_intf.MASTER m_m2s_axil,
    axil_intf.MASTER m_s2m_axil
);

axis_intf m2s_axis();
axis_intf s2m_axis();

axis_intf m2s_post_saf_axis();
axis_intf s2m_pre_saf_axis();

axis_intf m_tx_ctrl_axis_data();

// regs
tcp_stream_regs_pkg::tcp_stream_regs__in_t hwif_in;
tcp_stream_regs_pkg::tcp_stream_regs__out_t hwif_out;

tcp_pkg::tx_ctrl_t tx_ctrl;
logic tx_ctrl_valid;
logic tx_ctrl_ack;

tcp_pkg::rx_msg_t rx_msg;
logic rx_msg_valid;
logic rx_msg_ack;

logic [15:0]         w_saf_pkt_len;
logic [15:0]         w_tx_ip_len;
logic [31:0]         w_tx_seq_number;
logic [31:0]         w_tx_ack_number;
logic [7:0]          w_tx_flags;
logic [15:0]         w_tx_window_size;
logic                w_tx_hdr_valid;
logic                w_tx_packet_done;

logic [31:0]         w_rx_seq_number;
logic [31:0]         w_rx_ack_number;
logic [7:0]          w_rx_flags;
logic [15:0]         w_rx_window_size;
logic                w_rx_hdr_valid;


assign o_tcp_port = hwif_out.source_port.d.value;


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

m2s_dma #(
    .AXIS_DATA_WIDTH(DATA_WIDTH)
) u_m2s_dma (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .s_cpuif_req                (hwif_out.m2s_dma_regs.req),
    .s_cpuif_req_is_wr          (hwif_out.m2s_dma_regs.req_is_wr),
    .s_cpuif_addr               (hwif_out.m2s_dma_regs.addr),
    .s_cpuif_wr_data            (hwif_out.m2s_dma_regs.wr_data),
    .s_cpuif_wr_biten           (hwif_out.m2s_dma_regs.wr_biten),
    .s_cpuif_req_stall_wr       (),
    .s_cpuif_req_stall_rd       (),
    .s_cpuif_rd_ack             (hwif_in.m2s_dma_regs.rd_ack),
    .s_cpuif_rd_err             (),
    .s_cpuif_rd_data            (hwif_in.m2s_dma_regs.rd_data),
    .s_cpuif_wr_ack             (hwif_in.m2s_dma_regs.wr_ack),
    .s_cpuif_wr_err             (),

    .m_axil                     (m_m2s_axil),
    .m_axis                     (m2s_axis)
);


// tcp state manager
tcp_state_manager u_tcp_state_manager (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .i_enable                   (hwif_out.control.enable.value),

    .i_open                     (hwif_out.control.open.value),
    .o_open_clr                 (hwif_in.control.open.hwclr),
    .i_close                    (hwif_out.control.close.value),
    .o_close_clr                (hwif_in.control.close.hwclr),

    .o_tx_ctrl                  (tx_ctrl),
    .o_tx_ctrl_valid            (tx_ctrl_valid),
    .i_tx_ctrl_ack              (tx_ctrl_ack),

    .i_rx_msg                   (rx_msg),
    .i_rx_msg_valid             (rx_msg_valid),
    .o_rx_msg_ack               (rx_msg_ack)
);


// tx buffer
axis_saf_fifo #(
    .DATA_DEPTH_L2(12),
    .CTRL_DEPTH_L2(7),
    .DATA_MEM("distributed"),
    .CTRL_MEM("distributed")
) m2s_saf_fifo (
    .sclk       (clk),
    .srst       (rst),
    .s_axis     (m2s_axis),

    .mclk       (clk),
    .mrst       (rst),
    .m_axis     (m2s_post_saf_axis),

    .o_len      (w_saf_pkt_len),
    .o_rx_pkt   (),
    .o_tx_pkt   (),
    .o_drop     ()
);


// tx control
tcp_tx_ctrl u_tcp_tx_ctrl (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .i_tx_ctrl                  (tx_ctrl),
    .i_tx_ctrl_valid            (tx_ctrl_valid),
    .o_tx_ctrl_ack              (tx_ctrl_ack),

    .o_ip_len                   (w_tx_ip_len),
    .o_seq_number               (w_tx_seq_number),
    // .o_ack_number               (w_tx_ack_number),
    .o_flags                    (w_tx_flags),
    .o_window_size              (w_tx_window_size),
    .o_hdr_valid                (w_tx_hdr_valid),

    .s_axis_len                 (w_saf_pkt_len),
    .s_axis                     (m2s_post_saf_axis),
    .m_axis                     (m_tx_ctrl_axis_data),

    .i_packet_done              (w_tx_packet_done)
);

// packet generator
tcp_packet_generator u_tcp_packet_generator (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .s_axis_data                (m_tx_ctrl_axis_data),

    .i_ip_len                   (w_tx_ip_len),
    .i_seq_number               (w_tx_seq_number),
    .i_ack_number               (w_tx_ack_number),
    .i_source_port              (hwif_out.source_port.d.value),
    .i_dest_port                (hwif_out.dest_port.d.value),
    .i_flags                    (w_tx_flags),
    .i_window_size              (w_tx_window_size),
    .i_hdr_valid                (w_tx_hdr_valid),
    .i_src_ip                   (hwif_out.source_ip.d.value),
    .i_dst_ip                   (hwif_out.dest_ip.d.value),

    .o_packet_done              (w_tx_packet_done),

    .m_ip                       (m_ip_tx)
);

// parser
tcp_parser u_tcp_parser (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .s_ip                       (s_ip_rx),
    .m_axis                     (s2m_pre_saf_axis),

    .o_seq_number               (w_rx_seq_number),
    .o_ack_number               (w_rx_ack_number),
    .o_flags                    (w_rx_flags),
    .o_window_size              (w_rx_window_size),
    .o_hdr_valid                (w_rx_hdr_valid)
);

// rx control
tcp_rx_ctrl u_tcp_rx_ctrl (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .o_rx_msg                   (rx_msg),
    .o_rx_msg_valid             (rx_msg_valid),
    .i_rx_msg_ack               (rx_msg_ack),

    .i_seq_number               (w_rx_seq_number),
    .i_ack_number               (w_rx_ack_number),
    .i_flags                    (w_rx_flags),
    .i_window_size              (w_rx_window_size),
    .i_hdr_valid                (w_rx_hdr_valid),

    .o_ack_number               (w_tx_ack_number)
);

// rx buffer

endmodule