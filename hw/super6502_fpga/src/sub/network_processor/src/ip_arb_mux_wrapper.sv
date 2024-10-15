module ip_arb_mux_wrapper #(
    parameter S_COUNT = 4,
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1,
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 0,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 1
) (
    input i_clk,
    input i_rst,

    ip_intf.SLAVE s_ip  [S_COUNT],
    ip_intf.MASTER m_ip
);

logic [S_COUNT-1:0]             s_ip_hdr_valid;
logic [S_COUNT-1:0]             s_ip_hdr_ready;
logic [S_COUNT*48-1:0]          s_eth_dest_mac;
logic [S_COUNT*48-1:0]          s_eth_src_mac;
logic [S_COUNT*16-1:0]          s_eth_type;
logic [S_COUNT*4-1:0]           s_ip_version;
logic [S_COUNT*4-1:0]           s_ip_ihl;
logic [S_COUNT*6-1:0]           s_ip_dscp;
logic [S_COUNT*2-1:0]           s_ip_ecn;
logic [S_COUNT*16-1:0]          s_ip_length;
logic [S_COUNT*16-1:0]          s_ip_identification;
logic [S_COUNT*3-1:0]           s_ip_flags;
logic [S_COUNT*13-1:0]          s_ip_fragment_offset;
logic [S_COUNT*8-1:0]           s_ip_ttl;
logic [S_COUNT*8-1:0]           s_ip_protocol;
logic [S_COUNT*16-1:0]          s_ip_header_checksum;
logic [S_COUNT*32-1:0]          s_ip_source_ip;
logic [S_COUNT*32-1:0]          s_ip_dest_ip;
logic [S_COUNT*DATA_WIDTH-1:0]  s_ip_payload_axis_tdata;
logic [S_COUNT*KEEP_WIDTH-1:0]  s_ip_payload_axis_tkeep;
logic [S_COUNT-1:0]             s_ip_payload_axis_tvalid;
logic [S_COUNT-1:0]             s_ip_payload_axis_tready;
logic [S_COUNT-1:0]             s_ip_payload_axis_tlast;
logic [S_COUNT*ID_WIDTH-1:0]    s_ip_payload_axis_tid;
logic [S_COUNT*DEST_WIDTH-1:0]  s_ip_payload_axis_tdest;
logic [S_COUNT*USER_WIDTH-1:0]  s_ip_payload_axis_tuser;

generate
    for (genvar i = 0; i < S_COUNT; i++) begin
        assign s_ip_hdr_valid[i]                                    = s_ip[i].ip_hdr_valid;
        assign s_ip[i].ip_hdr_ready                                 = s_ip_hdr_ready[i];
        assign s_eth_dest_mac[i*48+:48]                             = s_ip[i].eth_dest_mac;
        assign s_eth_src_mac[i*48+:48]                              = s_ip[i].eth_src_mac;
        assign s_eth_type[i*16+:16]                                 = s_ip[i].eth_type;
        assign s_ip_version[i*4+:4]                                 = s_ip[i].ip_version;
        assign s_ip_ihl[i*4+:4]                                     = s_ip[i].ip_ihl;
        assign s_ip_dscp[i*6+:6]                                    = s_ip[i].ip_dscp;
        assign s_ip_ecn[i*2+:2]                                     = s_ip[i].ip_ecn;
        assign s_ip_length[i*16+:16]                                = s_ip[i].ip_length;
        assign s_ip_identification[i*16+:16]                        = s_ip[i].ip_identification;
        assign s_ip_flags[i*3+:3]                                   = s_ip[i].ip_flags;
        assign s_ip_fragment_offset[i*13+:13]                       = s_ip[i].ip_fragment_offset;
        assign s_ip_ttl[i*8+:8]                                     = s_ip[i].ip_ttl;
        assign s_ip_protocol[i*8+:8]                                = s_ip[i].ip_protocol;
        assign s_ip_header_checksum[i*16+:16]                       = s_ip[i].ip_header_checksum;
        assign s_ip_source_ip[i*32+:32]                             = s_ip[i].ip_source_ip;
        assign s_ip_dest_ip[i*32+:32]                               = s_ip[i].ip_dest_ip;
        assign s_ip_payload_axis_tdata[i*DATA_WIDTH+:DATA_WIDTH]    = s_ip[i].ip_payload_axis_tdata;
        assign s_ip_payload_axis_tkeep[i*KEEP_WIDTH+:KEEP_WIDTH]    = s_ip[i].ip_payload_axis_tkeep;
        assign s_ip_payload_axis_tvalid[i*KEEP_WIDTH+:KEEP_WIDTH]   = s_ip[i].ip_payload_axis_tvalid;
        assign s_ip[i].ip_payload_axis_tready                       = s_ip_payload_axis_tready[i];
        assign s_ip_payload_axis_tlast[i]                           = s_ip[i].ip_payload_axis_tlast;
        assign s_ip_payload_axis_tid[i*ID_WIDTH+:ID_WIDTH]          = s_ip[i].ip_payload_axis_tid;
        assign s_ip_payload_axis_tdest[i*DEST_WIDTH+:DEST_WIDTH]    = s_ip[i].ip_payload_axis_tdest;
        assign s_ip_payload_axis_tuser[i*USER_WIDTH+:USER_WIDTH]    = s_ip[i].ip_payload_axis_tuser;
    end
endgenerate

ip_arb_mux #(
    .S_COUNT(S_COUNT),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
    .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
) u_arb_mux (
    .clk                                (i_clk),
    .rst                                (i_rst),

    .s_ip_hdr_valid                     (s_ip_hdr_valid                 ),
    .s_ip_hdr_ready                     (s_ip_hdr_ready                 ),
    .s_eth_dest_mac                     (s_eth_dest_mac                 ),
    .s_eth_src_mac                      (s_eth_src_mac                  ),
    .s_eth_type                         (s_eth_type                     ),
    .s_ip_version                       (s_ip_version                   ),
    .s_ip_ihl                           (s_ip_ihl                       ),
    .s_ip_dscp                          (s_ip_dscp                      ),
    .s_ip_ecn                           (s_ip_ecn                       ),
    .s_ip_length                        (s_ip_length                    ),
    .s_ip_identification                (s_ip_identification            ),
    .s_ip_flags                         (s_ip_flags                     ),
    .s_ip_fragment_offset               (s_ip_fragment_offset           ),
    .s_ip_ttl                           (s_ip_ttl                       ),
    .s_ip_protocol                      (s_ip_protocol                  ),
    .s_ip_header_checksum               (s_ip_header_checksum           ),
    .s_ip_source_ip                     (s_ip_source_ip                 ),
    .s_ip_dest_ip                       (s_ip_dest_ip                   ),
    .s_ip_payload_axis_tdata            (s_ip_payload_axis_tdata        ),
    .s_ip_payload_axis_tkeep            (s_ip_payload_axis_tkeep        ),
    .s_ip_payload_axis_tvalid           (s_ip_payload_axis_tvalid       ),
    .s_ip_payload_axis_tready           (s_ip_payload_axis_tready       ),
    .s_ip_payload_axis_tlast            (s_ip_payload_axis_tlast        ),
    .s_ip_payload_axis_tid              (s_ip_payload_axis_tid          ),
    .s_ip_payload_axis_tdest            (s_ip_payload_axis_tdest        ),
    .s_ip_payload_axis_tuser            (s_ip_payload_axis_tuser        ),

    .m_ip_hdr_valid                     (m_ip.ip_hdr_valid              ),
    .m_ip_hdr_ready                     (m_ip.ip_hdr_ready              ),
    .m_eth_dest_mac                     (m_ip.eth_dest_mac              ),
    .m_eth_src_mac                      (m_ip.eth_src_mac               ),
    .m_eth_type                         (m_ip.eth_type                  ),
    .m_ip_version                       (m_ip.ip_version                ),
    .m_ip_ihl                           (m_ip.ip_ihl                    ),
    .m_ip_dscp                          (m_ip.ip_dscp                   ),
    .m_ip_ecn                           (m_ip.ip_ecn                    ),
    .m_ip_length                        (m_ip.ip_length                 ),
    .m_ip_identification                (m_ip.ip_identification         ),
    .m_ip_flags                         (m_ip.ip_flags                  ),
    .m_ip_fragment_offset               (m_ip.ip_fragment_offset        ),
    .m_ip_ttl                           (m_ip.ip_ttl                    ),
    .m_ip_protocol                      (m_ip.ip_protocol               ),
    .m_ip_header_checksum               (m_ip.ip_header_checksum        ),
    .m_ip_source_ip                     (m_ip.ip_source_ip              ),
    .m_ip_dest_ip                       (m_ip.ip_dest_ip                ),
    .m_ip_payload_axis_tdata            (m_ip.ip_payload_axis_tdata     ),
    .m_ip_payload_axis_tkeep            (m_ip.ip_payload_axis_tkeep     ),
    .m_ip_payload_axis_tvalid           (m_ip.ip_payload_axis_tvalid    ),
    .m_ip_payload_axis_tready           (m_ip.ip_payload_axis_tready    ),
    .m_ip_payload_axis_tlast            (m_ip.ip_payload_axis_tlast     ),
    .m_ip_payload_axis_tid              (m_ip.ip_payload_axis_tid       ),
    .m_ip_payload_axis_tdest            (m_ip.ip_payload_axis_tdest     ),
    .m_ip_payload_axis_tuser            (m_ip.ip_payload_axis_tuser     )
);

endmodule