module ip_demux_wrapper #(
    parameter M_COUNT = 4,
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    parameter ID_ENABLE = 0,
    parameter ID_WIDTH = 8,
    parameter DEST_ENABLE = 0,
    parameter DEST_WIDTH = 8,
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1
)
(
    input  wire                          clk,
    input  wire                          rst,

    ip_intf.SLAVE s_ip,
    ip_intf.MASTER m_ip [M_COUNT],

    input  wire                          enable,
    input  wire                          drop,
    input  wire [$clog2(M_COUNT)-1:0]    select
);

logic [M_COUNT-1:0]            m_ip_hdr_valid;
logic [M_COUNT-1:0]            m_ip_hdr_ready;
logic [M_COUNT*48-1:0]         m_eth_dest_mac;
logic [M_COUNT*48-1:0]         m_eth_src_mac;
logic [M_COUNT*16-1:0]         m_eth_type;
logic [M_COUNT*4-1:0]          m_ip_version;
logic [M_COUNT*4-1:0]          m_ip_ihl;
logic [M_COUNT*6-1:0]          m_ip_dscp;
logic [M_COUNT*2-1:0]          m_ip_ecn;
logic [M_COUNT*16-1:0]         m_ip_length;
logic [M_COUNT*16-1:0]         m_ip_identification;
logic [M_COUNT*3-1:0]          m_ip_flags;
logic [M_COUNT*13-1:0]         m_ip_fragment_offset;
logic [M_COUNT*8-1:0]          m_ip_ttl;
logic [M_COUNT*8-1:0]          m_ip_protocol;
logic [M_COUNT*16-1:0]         m_ip_header_checksum;
logic [M_COUNT*32-1:0]         m_ip_source_ip;
logic [M_COUNT*32-1:0]         m_ip_dest_ip;
logic [M_COUNT*DATA_WIDTH-1:0] m_ip_payload_axis_tdata;
logic [M_COUNT*KEEP_WIDTH-1:0] m_ip_payload_axis_tkeep;
logic [M_COUNT-1:0]            m_ip_payload_axis_tvalid;
logic [M_COUNT-1:0]            m_ip_payload_axis_tready;
logic [M_COUNT-1:0]            m_ip_payload_axis_tlast;
logic [M_COUNT*ID_WIDTH-1:0]   m_ip_payload_axis_tid;
logic [M_COUNT*DEST_WIDTH-1:0] m_ip_payload_axis_tdest;
logic [M_COUNT*USER_WIDTH-1:0] m_ip_payload_axis_tuser;


generate
    for (genvar i = 0; i < M_COUNT; i++) begin
        assign m_ip[i].ip_hdr_valid             = m_ip_hdr_valid[i];
        assign m_ip_hdr_ready[i]                = m_ip[i].ip_hdr_ready;
        assign m_ip[i].eth_dest_mac             = m_eth_dest_mac[i*48+:48];
        assign m_ip[i].eth_src_mac              = m_eth_src_mac[i*48+:48];
        assign m_ip[i].eth_type                 = m_eth_type[i*16+:16];
        assign m_ip[i].ip_version               = m_ip_version[i*4+:4];
        assign m_ip[i].ip_ihl                   = m_ip_ihl[i*4+:4];
        assign m_ip[i].ip_dscp                  = m_ip_dscp[i*6+:6];
        assign m_ip[i].ip_ecn                   = m_ip_ecn[i*2+:2];
        assign m_ip[i].ip_length                = m_ip_length[i*16+:16];
        assign m_ip[i].ip_identification        = m_ip_identification[i*16+:16];
        assign m_ip[i].ip_flags                 = m_ip_flags[i*3+:3];
        assign m_ip[i].ip_fragment_offset       = m_ip_fragment_offset[i*13+:13];
        assign m_ip[i].ip_ttl                   = m_ip_ttl[i*8+:8];
        assign m_ip[i].ip_protocol              = m_ip_protocol[i*8+:8];
        assign m_ip[i].ip_header_checksum       = m_ip_header_checksum[i*16+:16];
        assign m_ip[i].ip_source_ip             = m_ip_source_ip[i*32+:32];
        assign m_ip[i].ip_dest_ip               = m_ip_dest_ip[i*32+:32];
        assign m_ip[i].ip_payload_axis_tdata    = m_ip_payload_axis_tdata[i*DATA_WIDTH+:DATA_WIDTH];
        assign m_ip[i].ip_payload_axis_tkeep    = m_ip_payload_axis_tkeep[i*KEEP_WIDTH+:KEEP_WIDTH];
        assign m_ip[i].ip_payload_axis_tvalid   = m_ip_payload_axis_tvalid[i*KEEP_WIDTH+:KEEP_WIDTH];
        assign m_ip_payload_axis_tready[i]      = m_ip[i].ip_payload_axis_tready;
        assign m_ip[i].ip_payload_axis_tlast    = m_ip_payload_axis_tlast[i];
        assign m_ip[i].ip_payload_axis_tid      = m_ip_payload_axis_tid[i*ID_WIDTH+:ID_WIDTH];
        assign m_ip[i].ip_payload_axis_tdest    = m_ip_payload_axis_tdest[i*DEST_WIDTH+:DEST_WIDTH];
        assign m_ip[i].ip_payload_axis_tuser    = m_ip_payload_axis_tuser[i*USER_WIDTH+:USER_WIDTH];
    end
endgenerate

ip_demux #(
    .M_COUNT(M_COUNT),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH)
) u_ip_demux (
    .clk                                (clk),
    .rst                                (rst),

    .s_ip_hdr_valid                     (s_ip.ip_hdr_valid              ),
    .s_ip_hdr_ready                     (s_ip.ip_hdr_ready              ),
    .s_eth_dest_mac                     (s_ip.eth_dest_mac              ),
    .s_eth_src_mac                      (s_ip.eth_src_mac               ),
    .s_eth_type                         (s_ip.eth_type                  ),
    .s_ip_version                       (s_ip.ip_version                ),
    .s_ip_ihl                           (s_ip.ip_ihl                    ),
    .s_ip_dscp                          (s_ip.ip_dscp                   ),
    .s_ip_ecn                           (s_ip.ip_ecn                    ),
    .s_ip_length                        (s_ip.ip_length                 ),
    .s_ip_identification                (s_ip.ip_identification         ),
    .s_ip_flags                         (s_ip.ip_flags                  ),
    .s_ip_fragment_offset               (s_ip.ip_fragment_offset        ),
    .s_ip_ttl                           (s_ip.ip_ttl                    ),
    .s_ip_protocol                      (s_ip.ip_protocol               ),
    .s_ip_header_checksum               (s_ip.ip_header_checksum        ),
    .s_ip_source_ip                     (s_ip.ip_source_ip              ),
    .s_ip_dest_ip                       (s_ip.ip_dest_ip                ),
    .s_ip_payload_axis_tdata            (s_ip.ip_payload_axis_tdata     ),
    .s_ip_payload_axis_tkeep            (s_ip.ip_payload_axis_tkeep     ),
    .s_ip_payload_axis_tvalid           (s_ip.ip_payload_axis_tvalid    ),
    .s_ip_payload_axis_tready           (s_ip.ip_payload_axis_tready    ),
    .s_ip_payload_axis_tlast            (s_ip.ip_payload_axis_tlast     ),
    .s_ip_payload_axis_tid              (s_ip.ip_payload_axis_tid       ),
    .s_ip_payload_axis_tdest            (s_ip.ip_payload_axis_tdest     ),
    .s_ip_payload_axis_tuser            (s_ip.ip_payload_axis_tuser     ),

    .m_ip_hdr_valid                     (m_ip_hdr_valid                 ),
    .m_ip_hdr_ready                     (m_ip_hdr_ready                 ),
    .m_eth_dest_mac                     (m_eth_dest_mac                 ),
    .m_eth_src_mac                      (m_eth_src_mac                  ),
    .m_eth_type                         (m_eth_type                     ),
    .m_ip_version                       (m_ip_version                   ),
    .m_ip_ihl                           (m_ip_ihl                       ),
    .m_ip_dscp                          (m_ip_dscp                      ),
    .m_ip_ecn                           (m_ip_ecn                       ),
    .m_ip_length                        (m_ip_length                    ),
    .m_ip_identification                (m_ip_identification            ),
    .m_ip_flags                         (m_ip_flags                     ),
    .m_ip_fragment_offset               (m_ip_fragment_offset           ),
    .m_ip_ttl                           (m_ip_ttl                       ),
    .m_ip_protocol                      (m_ip_protocol                  ),
    .m_ip_header_checksum               (m_ip_header_checksum           ),
    .m_ip_source_ip                     (m_ip_source_ip                 ),
    .m_ip_dest_ip                       (m_ip_dest_ip                   ),
    .m_ip_payload_axis_tdata            (m_ip_payload_axis_tdata        ),
    .m_ip_payload_axis_tkeep            (m_ip_payload_axis_tkeep        ),
    .m_ip_payload_axis_tvalid           (m_ip_payload_axis_tvalid       ),
    .m_ip_payload_axis_tready           (m_ip_payload_axis_tready       ),
    .m_ip_payload_axis_tlast            (m_ip_payload_axis_tlast        ),
    .m_ip_payload_axis_tid              (m_ip_payload_axis_tid          ),
    .m_ip_payload_axis_tdest            (m_ip_payload_axis_tdest        ),
    .m_ip_payload_axis_tuser            (m_ip_payload_axis_tuser        ),

    .enable                             (enable),
    .drop                               (drop),
    .select                             (select)
);

endmodule