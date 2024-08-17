module network_processor #(
    parameter NUM_TCP=8
)(
    input i_clk,
    input i_rst,

    // our crossbar is all axi, so having this be apb means
    // we have to convert it anyway
    output logic s_axil_awready,
    input wire s_axil_awvalid,
    input wire [8:0] s_axil_awaddr,
    input wire [2:0] s_axil_awprot,
    output logic s_axil_wready,
    input wire s_axil_wvalid,
    input wire [31:0] s_axil_wdata,
    input wire [3:0]s_axil_wstrb,
    input wire s_axil_bready,
    output logic s_axil_bvalid,
    output logic [1:0] s_axil_bresp,
    output logic s_axil_arready,
    input wire s_axil_arvalid,
    input wire [8:0] s_axil_araddr,
    input wire [2:0] s_axil_arprot,
    input wire s_axil_rready,
    output logic s_axil_rvalid,
    output logic [31:0] s_axil_rdata,
    output logic [1:0] s_axil_rresp
);

tcp_top_regfile_pkg::tcp_top_regfile__in_t tcp_hwif_in;
tcp_top_regfile_pkg::tcp_top_regfile__out_t tcp_hwif_out;


tcp_top_regfile u_tcp_top_regfile (
    .clk            (i_clk),
    .rst            (i_rst),

    .s_axil_awready (s_axil_awready),
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awaddr  (s_axil_awaddr),
    .s_axil_awprot  (s_axil_awprot),
    .s_axil_wready  (s_axil_wready),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wstrb   (s_axil_wstrb),
    .s_axil_bready  (s_axil_bready),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_arready (s_axil_arready),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_araddr  (s_axil_araddr),
    .s_axil_arprot  (s_axil_arprot),
    .s_axil_rready  (s_axil_rready),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),

    .hwif_in        (tcp_hwif_in),
    .hwif_out       (tcp_hwif_out)
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
            .s_cpuif_wr_err         ()
        );
    end
endgenerate

endmodule