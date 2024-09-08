module tcp_dest_decap (
    input               i_clk,
    input               i_rst,
    
    ip_intf.SLAVE       s_ip,
    ip_intf.MASTER      m_ip,

    output wire [15:0]  o_tcp_dest,
    output wire         o_tcp_dest_valid
);


logic [15:0] tcp_dest, tcp_dest_next;
logic [31:0] pipe, pipe_next;
logic [3:0] pipe_valid, pipe_valid_next;
logic [3:0] pipe_last, pipe_last_next;


enum logic [1:0] {PORTS, PASSTHROUGH} state, state_next;
logic [1:0] counter, counter_next;


// We don't need the mac addresses or the ethertype.
assign m_ip.eth_src_mac = '0;
assign m_ip.eth_dest_mac = '0;
assign m_ip.eth_type = '0;

assign o_tcp_dest = tcp_dest;

skidbuffer #(
    .DW(160)
) u_tcp_ip_hdr_skidbuffer (
    .i_clk      (i_clk),
    .i_reset    (i_rst),

    .i_valid    (s_ip.ip_hdr_valid),
    .o_ready    (s_ip.ip_hdr_ready),
    .i_data     ({
        s_ip.ip_version,
        s_ip.ip_ihl,
        s_ip.ip_dscp,
        s_ip.ip_ecn,
        s_ip.ip_length,
        s_ip.ip_identification,
        s_ip.ip_flags,
        s_ip.ip_fragment_offset,
        s_ip.ip_ttl,
        s_ip.ip_protocol,
        s_ip.ip_header_checksum,
        s_ip.ip_source_ip,
        s_ip.ip_dest_ip
    }),
    .o_valid    (m_ip.ip_hdr_valid),
    .i_ready    (m_ip.ip_hdr_ready),
    .o_data     ({
        m_ip.ip_version,
        m_ip.ip_ihl,
        m_ip.ip_dscp,
        m_ip.ip_ecn,
        m_ip.ip_length,
        m_ip.ip_identification,
        m_ip.ip_flags,
        m_ip.ip_fragment_offset,
        m_ip.ip_ttl,
        m_ip.ip_protocol,
        m_ip.ip_header_checksum,
        m_ip.ip_source_ip,
        m_ip.ip_dest_ip
    })
);

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        tcp_dest <= '0;
        pipe <= '0;
        pipe_valid <= '0;
        pipe_last <= '0;
        state <= PORTS;
        counter <= '0;
    end else begin
        tcp_dest <= tcp_dest_next;
        pipe <= pipe_next;
        pipe_valid <= pipe_valid_next;
        pipe_last <= pipe_last_next;
        state <= state_next;
        counter <= counter_next;
    end
end

always_comb begin
    tcp_dest_next = tcp_dest;
    state_next = state;
    pipe_next = pipe;
    pipe_valid_next = pipe_valid;
    pipe_last_next = pipe_last;
    counter_next = pipe;

    s_ip.ip_payload_axis_tready = '0;

    case (state)
        PORTS: begin
            s_ip.ip_payload_axis_tready = 1;
            o_tcp_dest_valid = '0;

            if (s_ip.ip_payload_axis_tvalid) begin
                counter_next = counter + 1;
                pipe_valid_next = {pipe_valid[2:0], 1'b1};
                pipe_next = {pipe_next[23:0], s_ip.ip_payload_axis_tdata};
                if (counter == 2'h3) begin
                    state_next = PASSTHROUGH;
                    tcp_dest_next = pipe_next[15:0];
                end
            end
        end

        PASSTHROUGH: begin
            // match ready except if we have seen last, then just finish it out.
            pipe_valid_next = {pipe_valid[2:0], s_ip.ip_payload_axis_tvalid};
            pipe_last_next = {pipe_last[2:0], s_ip.ip_payload_axis_tlast};
            pipe_next = {pipe_next[23:0], s_ip.ip_payload_axis_tdata};

            s_ip.ip_payload_axis_tready = m_ip.ip_payload_axis_tready;
            m_ip.ip_payload_axis_tvalid = pipe_valid[3];
            m_ip.ip_payload_axis_tlast = pipe_last[3];
            m_ip.ip_payload_axis_tdata = pipe[31:24];

            o_tcp_dest_valid = '1;
        end
    endcase
end

endmodule