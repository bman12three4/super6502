module axil_reg_slice(
    input clk,
    input rst,

    axil_intf.SLAVE s_axil,
    axil_intf.MASTER m_axil
);

skidbuffer #(
    .DW(s_axil.AXIL_ADDR_WIDTH)
) awskid(
    .i_clk(clk),
    .i_reset(rst),

    .i_valid(s_axil.awvalid),
    .o_ready(s_axil.awready),
    .i_data(s_axil.awaddr),
    .o_valid(m_axil.awvalid),
    .i_ready(m_axil.awready),
    .o_data(m_axil.awaddr)
);

skidbuffer #(
    .DW(s_axil.AXIL_DATA_WIDTH + s_axil.AXIL_STRB_WIDTH)
) wskid(
    .i_clk(clk),
    .i_reset(rst),

    .i_valid(s_axil.wvalid),
    .o_ready(s_axil.wready),
    .i_data({s_axil.wdata, s_axil.wstrb}),
    .o_valid(m_axil.wvalid),
    .i_ready(m_axil.wready),
    .o_data({m_axil.wdata, m_axil.wstrb})
);

skidbuffer #(
    .DW(s_axil.AXIL_ADDR_WIDTH)
) arskid(
    .i_clk(clk),
    .i_reset(rst),

    .i_valid(s_axil.arvalid),
    .o_ready(s_axil.arready),
    .i_data(s_axil.araddr),
    .o_valid(m_axil.arvalid),
    .i_ready(m_axil.arready),
    .o_data(m_axil.araddr)
);

skidbuffer #(
    .DW(s_axil.AXIL_DATA_WIDTH + 2)
) rskid(
    .i_clk(clk),
    .i_reset(rst),

    .i_valid(m_axil.rvalid),
    .o_ready(m_axil.rready),
    .i_data({m_axil.rdata, m_axil.rresp}),
    .o_valid(s_axil.rvalid),
    .i_ready(s_axil.rready),
    .o_data({s_axil.rdata, s_axil.rresp})
);
skidbuffer #(.DW(2)) bskid(
    .i_clk(clk),
    .i_reset(rst),

    .i_valid(m_axil.bvalid),
    .o_ready(m_axil.bready),
    .i_data(m_axil.bresp),
    .o_valid(s_axil.bvalid),
    .i_ready(s_axil.bready),
    .o_data(s_axil.bresp)
);

endmodule