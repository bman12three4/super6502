module tcp #(
    parameter NUM_TCP=8,
    parameter DATA_WIDTH=8
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


tcp_top_regfile u_tcp_top_regfile (
    .clk            (i_clk),
    .rst            (i_rst),

    .s_axil_awready (s_reg_axil_awready),
    .s_axil_awvalid (s_reg_axil_awvalid),
    .s_axil_awaddr  (s_reg_axil_awaddr),
    .s_axil_awprot  (s_reg_axil_awprot),
    .s_axil_wready  (s_reg_axil_wready),
    .s_axil_wvalid  (s_reg_axil_wvalid),
    .s_axil_wdata   (s_reg_axil_wdata),
    .s_axil_wstrb   (s_reg_axil_wstrb),
    .s_axil_bready  (s_reg_axil_bready),
    .s_axil_bvalid  (s_reg_axil_bvalid),
    .s_axil_bresp   (s_reg_axil_bresp),
    .s_axil_arready (s_reg_axil_arready),
    .s_axil_arvalid (s_reg_axil_arvalid),
    .s_axil_araddr  (s_reg_axil_araddr),
    .s_axil_arprot  (s_reg_axil_arprot),
    .s_axil_rready  (s_reg_axil_rready),
    .s_axil_rvalid  (s_reg_axil_rvalid),
    .s_axil_rdata   (s_reg_axil_rdata),
    .s_axil_rresp   (s_reg_axil_rresp),

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

logic [NUM_TCP*DATA_WIDTH-1:0]  tcp_tx_axis_tdata;
logic [NUM_TCP*KEEP_WIDTH-1:0]  tcp_tx_axis_tkeep;
logic [NUM_TCP-1:0]             tcp_tx_axis_tvalid;
logic [NUM_TCP-1:0]             tcp_tx_axis_tready;
logic [NUM_TCP-1:0]             tcp_tx_axis_tlast;
logic [NUM_TCP*DEST_WIDTH-1:0]  tcp_tx_axis_tdest;
logic [NUM_TCP*USER_WIDTH-1:0]  tcp_tx_axis_tuser;

logic [NUM_TCP*DATA_WIDTH-1:0]  tcp_rx_axis_tdata;
logic [NUM_TCP*KEEP_WIDTH-1:0]  tcp_rx_axis_tkeep;
logic [NUM_TCP-1:0]             tcp_rx_axis_tvalid;
logic [NUM_TCP-1:0]             tcp_rx_axis_tready;
logic [NUM_TCP-1:0]             tcp_rx_axis_tlast;
logic [NUM_TCP*DEST_WIDTH-1:0]  tcp_rx_axis_tdest;
logic [NUM_TCP*USER_WIDTH-1:0]  tcp_rx_axis_tuser;

logic [DATA_WIDTH-1:0]          s2m_rx_axis_tdata;
logic [KEEP_WIDTH-1:0]          s2m_rx_axis_tkeep;
logic                           s2m_rx_axis_tvalid;
logic                           s2m_rx_axis_tready;
logic                           s2m_rx_axis_tlast;
logic [DEST_WIDTH-1:0]          s2m_rx_axis_tdest;
logic [USER_WIDTH-1:0]          s2m_rx_axis_tuser;


//m2s dma

//s2m dma

// tx_stream demux
axis_demux   #(
    .M_COUNT(NUM_TCP),
    .DATA_WIDTH(DATA_WIDTH),
    .M_DEST_WIDTH(DEST_WIDTH),
    .DEST_ENABLE(1),
    .TDEST_ROUTE(1)
) tx_stream_demux (
    .clk            (i_clk),
    .rst            (i_rst),

    .s_axis_tdata   (m2s_tx_axis_tdata),
    .s_axis_tkeep   (m2s_tx_axis_tkeep),
    .s_axis_tvalid  (m2s_tx_axis_tvalid),
    .s_axis_tready  (m2s_tx_axis_tready),
    .s_axis_tlast   (m2s_tx_axis_tlast),
    .s_axis_tid     ('0),
    .s_axis_tdest   (m2s_tx_axis_tdest),
    .s_axis_tuser   (m2s_tx_axis_tuser),

    .m_axis_tdata   (tcp_tx_axis_tdata),
    .m_axis_tkeep   (tcp_tx_axis_tkeep),
    .m_axis_tvalid  (tcp_tx_axis_tvalid),
    .m_axis_tready  (tcp_tx_axis_tready),
    .m_axis_tlast   (tcp_tx_axis_tlast),
    .m_axis_tid     (),
    .m_axis_tdest   (tcp_tx_axis_tdest),
    .m_axis_tuser   (tcp_tx_axis_tuser),

    .enable         ('1),
    .drop           ('0),
    .select         ('0)
);

// rx_stream arb
axis_arb_mux #(
    .S_COUNT(NUM_TCP),
    .DATA_WIDTH(DATA_WIDTH),
    .DEST_ENABLE(1),
    .DEST_WIDTH(8)
) rx_stream_demux (
    .clk            (i_clk),
    .rst            (i_rst),

    .s_axis_tdata   (tcp_rx_axis_tdata),
    .s_axis_tkeep   (tcp_rx_axis_tkeep),
    .s_axis_tvalid  (tcp_rx_axis_tvalid),
    .s_axis_tready  (tcp_rx_axis_tready),
    .s_axis_tlast   (tcp_rx_axis_tlast),
    .s_axis_tid     ('0),
    .s_axis_tdest   (tcp_rx_axis_tdest),
    .s_axis_tuser   (tcp_rx_axis_tuser),

    .m_axis_tdata   (s2m_rx_axis_tdata),
    .m_axis_tkeep   (s2m_rx_axis_tkeep),
    .m_axis_tvalid  (s2m_rx_axis_tvalid),
    .m_axis_tready  (s2m_rx_axis_tready),
    .m_axis_tlast   (s2m_rx_axis_tlast),
    .m_axis_tid     (),
    .m_axis_tdest   (s2m_rx_axis_tdest),
    .m_axis_tuser   (s2m_rx_axis_tuser)
);


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

            .s_axis_tdata           (tcp_tx_axis_tdata[i*DATA_WIDTH+:DATA_WIDTH]),
            .s_axis_tkeep           (tcp_tx_axis_tkeep[i*KEEP_WIDTH+:KEEP_WIDTH]),
            .s_axis_tvalid          (tcp_tx_axis_tvalid[i]),
            .s_axis_tready          (tcp_tx_axis_tready[i]),
            .s_axis_tlast           (tcp_tx_axis_tlast[i]),
            .s_axis_tdest           (tcp_tx_axis_tdest[i*DEST_WIDTH+:DEST_WIDTH]),
            .s_axis_tuser           (tcp_tx_axis_tuser[i*USER_WIDTH+:USER_WIDTH]),

            .m_axis_tdata           (tcp_rx_axis_tdata[i*DATA_WIDTH+:DATA_WIDTH]),
            .m_axis_tkeep           (tcp_rx_axis_tkeep[i*KEEP_WIDTH+:KEEP_WIDTH]),
            .m_axis_tvalid          (tcp_rx_axis_tvalid[i]),
            .m_axis_tready          (tcp_rx_axis_tready[i]),
            .m_axis_tlast           (tcp_rx_axis_tlast[i]),
            .m_axis_tdest           (tcp_rx_axis_tdest[i*DEST_WIDTH+:DEST_WIDTH]),
            .m_axis_tuser           (tcp_rx_axis_tuser[i*USER_WIDTH+:USER_WIDTH])
        );
    end
endgenerate

endmodule