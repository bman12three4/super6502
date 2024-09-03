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

    ip_intf.SLAVE s_ip_rx,
    ip_intf.MASTER m_ip_tx,

    axil_intf.MASTER m_m2s_axil,
    axil_intf.MASTER m_s2m_axil
);

axis_intf m2s_axis();
axis_intf s2m_axis();

axis_intf m2s_post_saf_axis();

// regs
tcp_stream_regs_pkg::tcp_stream_regs__in_t hwif_in;
tcp_stream_regs_pkg::tcp_stream_regs__out_t hwif_out;

tcp_pkg::tx_ctrl_t tx_ctrl;
logic tx_ctrl_valid;
logic tx_ctrl_ack;

logic [31:0]         w_tx_seq_number;
logic [31:0]         w_tx_ack_number;
logic [7:0]          w_tx_flags;
logic [15:0]         w_tx_window_size;
logic                w_tx_hdr_valid;

tcp_pkg::rx_msg_t rx_msg;



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
    .i_tx_ctrl_ack              (tx_ctrl_ack)
);


// tx buffer
axis_fifo #(
    .DEPTH(4096),
    .DATA_WIDTH(DATA_WIDTH),
    .FRAME_FIFO(1)
) m2s_saf_fifo (
    .clk                        (clk),
    .rst                        (rst),

    .s_axis_tdata               (m2s_axis.tdata),
    .s_axis_tkeep               (m2s_axis.tkeep),
    .s_axis_tvalid              (m2s_axis.tvalid),
    .s_axis_tready              (m2s_axis.tready),
    .s_axis_tlast               (m2s_axis.tlast),
    .s_axis_tid                 (m2s_axis.tid),
    .s_axis_tdest               (m2s_axis.tdest),
    .s_axis_tuser               (m2s_axis.tuser),

    .m_axis_tdata               (m2s_post_saf_axis.tdata),
    .m_axis_tkeep               (m2s_post_saf_axis.tkeep),
    .m_axis_tvalid              (m2s_post_saf_axis.tvalid),
    .m_axis_tready              (m2s_post_saf_axis.tready),
    .m_axis_tlast               (m2s_post_saf_axis.tlast),
    .m_axis_tid                 (m2s_post_saf_axis.tid),
    .m_axis_tdest               (m2s_post_saf_axis.tdest),
    .m_axis_tuser               (m2s_post_saf_axis.tuser),

    .pause_req                  ('0),
    .pause_ack                  (),

    .status_depth               (),
    .status_depth_commit        (),
    .status_overflow            (),
    .status_bad_frame           (),
    .status_good_frame          ()
);

// tx control
tcp_tx_ctrl u_tcp_tx_ctrl (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .i_tx_ctrl                  (tx_ctrl),
    .i_tx_ctrl_valid            (tx_ctrl_valid),
    .o_tx_ctrl_ack              (tx_ctrl_ack),

    .o_seq_number               (w_tx_seq_number),
    .o_ack_number               (w_tx_ack_number),
    .o_flags                    (w_tx_flags),
    .o_window_size              (w_tx_window_size),
    .o_hdr_valid                (w_tx_hdr_valid)
);

// packet generator
tcp_packet_generator u_tcp_packet_generator (
    .i_clk                      (clk),
    .i_rst                      (rst),

    .s_axis_data                (m2s_post_saf_axis),

    .i_seq_number               (w_tx_seq_number),
    .i_ack_number               (w_tx_ack_number),
    .i_source_port              (hwif_out.source_port.d.value),
    .i_dest_port                (hwif_out.dest_port.d.value),
    .i_flags                    (w_tx_flags),
    .i_window_size              (w_tx_window_size),
    .i_hdr_valid                (w_tx_hdr_valid),
    .i_src_ip                   (hwif_out.source_ip.d.value),
    .i_dst_ip                   (hwif_out.dest_ip.d.value),

    .m_ip                       (m_ip_tx)
);

// parser

// rx control

// rx buffer

endmodule