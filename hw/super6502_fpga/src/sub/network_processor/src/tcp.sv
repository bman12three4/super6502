module tcp #(
    parameter NUM_TCP=8,
    parameter DATA_WIDTH=8
)(
    input i_clk,
    input i_rst,

    input  wire                         s_cpuif_req,
    input  wire                         s_cpuif_req_is_wr,
    input  wire [8:0]                   s_cpuif_addr,
    input  wire [31:0]                  s_cpuif_wr_data,
    input  wire [31:0]                  s_cpuif_wr_biten,
    output wire                         s_cpuif_req_stall_wr,
    output wire                         s_cpuif_req_stall_rd,
    output wire                         s_cpuif_rd_ack,
    output wire                         s_cpuif_rd_err,
    output wire [31:0]                  s_cpuif_rd_data,
    output wire                         s_cpuif_wr_ack,
    output wire                         s_cpuif_wr_err,

    /*
     * IP input
     */
    ip_intf.SLAVE                       s_ip,

    /*
    * IP output
    */
    ip_intf.MASTER                      m_ip,

    /*
    * AXI DMA Interface
    */
    axil_intf.MASTER                    m_dma_axil
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
localparam ID_WIDTH = 8;

ip_intf #(.DATA_WIDTH(8)) tcp_tx_ip();
ip_intf #(.DATA_WIDTH(8)) tcp_stream_tx_ip [NUM_TCP]();
ip_intf #(.DATA_WIDTH(8)) tcp_rx_ip [NUM_TCP]();
ip_intf #(.DATA_WIDTH(8)) tcp_stream_rx_ip [NUM_TCP]();

axis_intf #(.DATA_WIDTH(8)) tcp_stream_rx_axis [NUM_TCP]();

axil_intf m2s_stream_axil[NUM_TCP]();
axil_intf s2m_stream_axil[NUM_TCP]();


//m2s dma

wire    [NUM_TCP-1:0]       xbar_s_m2s_axi_arvalid;
wire    [NUM_TCP-1:0]       xbar_s_m2s_axi_arready;
wire    [NUM_TCP*32-1:0]    xbar_s_m2s_axi_araddr;
wire    [NUM_TCP*3-1:0]     xbar_s_m2s_axi_arprot;
wire    [NUM_TCP-1:0]       xbar_s_m2s_axi_rvalid;
wire    [NUM_TCP-1:0]       xbar_s_m2s_axi_rready;
wire    [NUM_TCP*32-1:0]    xbar_s_m2s_axi_rdata;
wire    [NUM_TCP*2-1:0]     xbar_s_m2s_axi_rresp;

wire    [NUM_TCP-1:0]       xbar_s_s2m_axi_arvalid;
wire    [NUM_TCP-1:0]       xbar_s_s2m_axi_arready;
wire    [NUM_TCP*32-1:0]    xbar_s_s2m_axi_araddr;
wire    [NUM_TCP*3-1:0]     xbar_s_s2m_axi_arprot;
wire    [NUM_TCP-1:0]       xbar_s_s2m_axi_rvalid;
wire    [NUM_TCP-1:0]       xbar_s_s2m_axi_rready;
wire    [NUM_TCP*32-1:0]    xbar_s_s2m_axi_rdata;
wire    [NUM_TCP*2-1:0]     xbar_s_s2m_axi_rresp;

axilxbar #(
    .NM(NUM_TCP*2),
    .NS(1),
    .SLAVE_ADDR(
        {32'h0, 32'hffffffff}   // full address space
    )
) u_m2s_xbar (
    .S_AXI_ACLK         (i_clk),
    .S_AXI_ARESETN      (~i_rst),

    // No write channel
    .S_AXI_AWVALID      ('0),
    .S_AXI_AWREADY      (),
    .S_AXI_AWADDR       ('0),
    .S_AXI_AWPROT       ('0),
    .S_AXI_WVALID       ('0),
    .S_AXI_WREADY       (),
    .S_AXI_WDATA        ('0),
    .S_AXI_WSTRB        ('0),
    .S_AXI_BVALID       (),
    .S_AXI_BREADY       ('0),
    .S_AXI_BRESP        (),

    .S_AXI_ARVALID      ({xbar_s_m2s_axi_arvalid,   xbar_s_s2m_axi_arvalid  }),
    .S_AXI_ARREADY      ({xbar_s_m2s_axi_arready,   xbar_s_s2m_axi_arready  }),
    .S_AXI_ARADDR       ({xbar_s_m2s_axi_araddr,    xbar_s_s2m_axi_araddr   }),
    .S_AXI_ARPROT       ({xbar_s_m2s_axi_arprot,    xbar_s_s2m_axi_arprot   }),
    .S_AXI_RVALID       ({xbar_s_m2s_axi_rvalid,    xbar_s_s2m_axi_rvalid   }),
    .S_AXI_RREADY       ({xbar_s_m2s_axi_rready,    xbar_s_s2m_axi_rready   }),
    .S_AXI_RDATA        ({xbar_s_m2s_axi_rdata,     xbar_s_s2m_axi_rdata    }),
    .S_AXI_RRESP        ({xbar_s_m2s_axi_rresp,     xbar_s_s2m_axi_rresp    }),

    .M_AXI_AWADDR       (),
    .M_AXI_AWPROT       (),
    .M_AXI_AWVALID      (),
    .M_AXI_AWREADY      ('0),
    .M_AXI_WDATA        (),
    .M_AXI_WSTRB        (),
    .M_AXI_WVALID       (),
    .M_AXI_WREADY       ('0),
    .M_AXI_BRESP        ('0),
    .M_AXI_BVALID       ('0),
    .M_AXI_BREADY       (),

    .M_AXI_ARADDR       (m_dma_axil.araddr),
    .M_AXI_ARPROT       (m_dma_axil.arprot),
    .M_AXI_ARVALID      (m_dma_axil.arvalid),
    .M_AXI_ARREADY      (m_dma_axil.arready),
    .M_AXI_RDATA        (m_dma_axil.rdata),
    .M_AXI_RRESP        (m_dma_axil.rresp),
    .M_AXI_RVALID       (m_dma_axil.rvalid),
    .M_AXI_RREADY       (m_dma_axil.rready)
);

generate
    for (genvar i = 0; i < NUM_TCP; i++) begin
        assign xbar_s_m2s_axi_arvalid[i] = m2s_stream_axil[i].arvalid;
        assign m2s_stream_axil[i].arready = xbar_s_m2s_axi_arready[i];
        assign xbar_s_m2s_axi_araddr[32*i+:32] = m2s_stream_axil[i].araddr;
        assign xbar_s_m2s_axi_arprot[3*i+:3] = m2s_stream_axil[i].arprot;
        assign m2s_stream_axil[i].rvalid = xbar_s_m2s_axi_rvalid[i];
        assign xbar_s_m2s_axi_rready[i] = m2s_stream_axil[i].rready;
        assign m2s_stream_axil[i].rdata = xbar_s_m2s_axi_rdata[32*i+:32];
        assign m2s_stream_axil[i].rresp = xbar_s_m2s_axi_rresp[2*i+:2];

        assign xbar_s_s2m_axi_arvalid[i] = s2m_stream_axil[i].arvalid;
        assign s2m_stream_axil[i].arready = xbar_s_s2m_axi_arready[i];
        assign xbar_s_s2m_axi_araddr[32*i+:32] = s2m_stream_axil[i].araddr;
        assign xbar_s_s2m_axi_arprot[3*i+:3] = s2m_stream_axil[i].arprot;
        assign s2m_stream_axil[i].rvalid = xbar_s_s2m_axi_rvalid[i];
        assign xbar_s_s2m_axi_rready[i] = s2m_stream_axil[i].rready;
        assign s2m_stream_axil[i].rdata = xbar_s_s2m_axi_rdata[32*i+:32];
        assign s2m_stream_axil[i].rresp = xbar_s_s2m_axi_rresp[2*i+:2];
    end
endgenerate


//s2m dma


// tx_stream arb mux (ip)
ip_arb_mux_wrapper #(
    .S_COUNT(NUM_TCP),
    .DATA_WIDTH(DATA_WIDTH)
) u_tx_stream_arb_mux (
    .i_clk    (i_clk),
    .i_rst    (i_rst),

    .s_ip   (tcp_stream_tx_ip),
    .m_ip   (tcp_tx_ip)
);


// rx_stream demux (ip)


generate

    for (genvar i = 0; i < NUM_TCP; i++) begin : TCP_STREAMS
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
            .clk                        (i_clk),
            .rst                        (i_rst),

            // This is the hacky decoder alex was telling me about
            .s_cpuif_req                (req),
            .s_cpuif_req_is_wr          (req_is_wr),
            .s_cpuif_addr               (addr),
            .s_cpuif_wr_data            (wr_data),
            .s_cpuif_wr_biten           (wr_biten),
            .s_cpuif_req_stall_wr       (),
            .s_cpuif_req_stall_rd       (),
            .s_cpuif_rd_ack             (tcp_hwif_in.tcp_streams[i].rd_ack),
            .s_cpuif_rd_err             (),
            .s_cpuif_rd_data            (tcp_hwif_in.tcp_streams[i].rd_data),
            .s_cpuif_wr_ack             (tcp_hwif_in.tcp_streams[i].wr_ack),
            .s_cpuif_wr_err             (),

            .s_ip_rx                    (tcp_stream_rx_ip[i]),
            .m_ip_tx                    (tcp_stream_tx_ip[i]),

            .m_m2s_axil                 (m2s_stream_axil[i]),
            .m_s2m_axil                 (s2m_stream_axil[i])
        );
    end
endgenerate

endmodule