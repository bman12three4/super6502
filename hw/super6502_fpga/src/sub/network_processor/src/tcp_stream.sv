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

    ip_intf.SLAVE s_ip_rx,
    ip_intf.MASTER m_ip_tx,

    axil_intf.MASTER m_m2s_axil,
    axil_intf.MASTER m_s2m_axil
);

axis_intf m2s_axis();
axis_intf s2m_axis();

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

m2s_dma #(
    .AXIS_DATA_WIDTH(DATA_WIDTH)
) u_m2s_dma (
    .i_clk                      (i_clk),
    .i_rst                      (i_rst),

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

// tx buffer

// tx control

// packet generator

// parser

// rx control

// rx buffer

endmodule