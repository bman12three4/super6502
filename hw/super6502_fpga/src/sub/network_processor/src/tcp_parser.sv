module tcp_parser(
    input wire          i_clk,
    input wire          i_rst,

    ip_intf.SLAVE       s_ip
);

assign s_ip.ip_hdr_ready = '1;
assign s_ip.ip_payload_axis_tready = '1;

endmodule