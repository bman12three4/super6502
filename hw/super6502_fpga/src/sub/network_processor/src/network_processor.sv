module network_processor #(
    parameter NUM_TCP=8
)(
    input i_clk,
    input i_rst,

    output  logic           s_reg_axil_awready,
    input   wire            s_reg_axil_awvalid,
    input   wire [8:0]      s_reg_axil_awaddr,
    input   wire [2:0]      s_reg_axil_awprot,
    output  logic           s_reg_axil_wready,
    input   wire            s_reg_axil_wvalid,
    input   wire [31:0]     s_reg_axil_wdata,
    input   wire [3:0]      s_reg_axil_wstrb,
    input   wire            s_reg_axil_bready,
    output  logic           s_reg_axil_bvalid,
    output  logic [1:0]     s_reg_axil_bresp,
    output  logic           s_reg_axil_arready,
    input   wire            s_reg_axil_arvalid,
    input   wire [8:0]      s_reg_axil_araddr,
    input   wire [2:0]      s_reg_axil_arprot,
    input   wire            s_reg_axil_rready,
    output  logic           s_reg_axil_rvalid,
    output  logic [31:0]    s_reg_axil_rdata,
    output  logic [1:0]     s_reg_axil_rresp
);

tcp_top_regfile_pkg::tcp_top_regfile__in_t tcp_hwif_in;
tcp_top_regfile_pkg::tcp_top_regfile__out_t tcp_hwif_out;


tcp #(
    .NUM_TCP(NUM_TCP)
) tcp (
    .i_clk            (i_clk),
    .i_rst            (i_rst),

    .s_reg_axil_awready (s_reg_axil_awready),
    .s_reg_axil_awvalid (s_reg_axil_awvalid),
    .s_reg_axil_awaddr  (s_reg_axil_awaddr),
    .s_reg_axil_awprot  (s_reg_axil_awprot),
    .s_reg_axil_wready  (s_reg_axil_wready),
    .s_reg_axil_wvalid  (s_reg_axil_wvalid),
    .s_reg_axil_wdata   (s_reg_axil_wdata),
    .s_reg_axil_wstrb   (s_reg_axil_wstrb),
    .s_reg_axil_bready  (s_reg_axil_bready),
    .s_reg_axil_bvalid  (s_reg_axil_bvalid),
    .s_reg_axil_bresp   (s_reg_axil_bresp),
    .s_reg_axil_arready (s_reg_axil_arready),
    .s_reg_axil_arvalid (s_reg_axil_arvalid),
    .s_reg_axil_araddr  (s_reg_axil_araddr),
    .s_reg_axil_arprot  (s_reg_axil_arprot),
    .s_reg_axil_rready  (s_reg_axil_rready),
    .s_reg_axil_rvalid  (s_reg_axil_rvalid),
    .s_reg_axil_rdata   (s_reg_axil_rdata),
    .s_reg_axil_rresp   (s_reg_axil_rresp)
);


endmodule