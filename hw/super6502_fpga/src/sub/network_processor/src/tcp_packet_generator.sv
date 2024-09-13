module tcp_packet_generator (
    input  wire             i_clk,
    input  wire             i_rst,

    axis_intf.SLAVE         s_axis_data,

    input  wire [31:0]      i_seq_number,
    input  wire [31:0]      i_ack_number,
    input  wire [15:0]      i_source_port,
    input  wire [15:0]      i_dest_port,
    input  wire [7:0]       i_flags,
    input  wire [15:0]      i_window_size,
    input  wire             i_hdr_valid,

    input  wire [31:0]      i_src_ip,
    input  wire [31:0]      i_dst_ip,

    output logic            o_packet_done,

    ip_intf.MASTER          m_ip
);

logic [31:0] counter, counter_next;
enum logic [1:0] {IDLE, HEADER, DATA} state, state_next;

logic [15:0] checksum;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        counter <= '0;
        state <= IDLE;
    end else begin
        counter <= counter_next;
        state <= state_next;
    end
end

always_comb begin
    m_ip.ip_hdr_valid = '0;
    m_ip.ip_payload_axis_tvalid = '0;
    m_ip.ip_payload_axis_tlast = '0;
    o_packet_done = '0;

    case (state)

        IDLE: begin
            counter_next = '0;

            if (i_hdr_valid) begin
                m_ip.ip_hdr_valid   = '1;
                m_ip.ip_dscp        = '0;
                m_ip.ip_ecn         = '0;
                m_ip.ip_length      = 16'd40;
                m_ip.ip_ttl         = '1;
                m_ip.ip_protocol    = 8'h6;
                m_ip.ip_source_ip   = i_src_ip;
                m_ip.ip_dest_ip     = i_dst_ip;

                if (m_ip.ip_hdr_ready) begin
                    state_next = HEADER;
                end
            end
        end

        HEADER: begin
            m_ip.ip_payload_axis_tvalid = '1;

            case (counter)
                0:  m_ip.ip_payload_axis_tdata = i_source_port[15:8];
                1:  m_ip.ip_payload_axis_tdata = i_source_port[7:0];
                2:  m_ip.ip_payload_axis_tdata = i_dest_port[15:8];
                3:  m_ip.ip_payload_axis_tdata = i_dest_port[7:0];
                4:  m_ip.ip_payload_axis_tdata = i_seq_number[31:24];
                5:  m_ip.ip_payload_axis_tdata = i_seq_number[23:16];
                6:  m_ip.ip_payload_axis_tdata = i_seq_number[15:8];
                7:  m_ip.ip_payload_axis_tdata = i_seq_number[7:0];
                8:  m_ip.ip_payload_axis_tdata = i_ack_number[31:24];
                9:  m_ip.ip_payload_axis_tdata = i_ack_number[23:16];
                10: m_ip.ip_payload_axis_tdata = i_ack_number[15:8];
                11: m_ip.ip_payload_axis_tdata = i_ack_number[7:0];
                12: m_ip.ip_payload_axis_tdata = {4'h5, 4'h0};
                13: m_ip.ip_payload_axis_tdata = i_flags;
                14: m_ip.ip_payload_axis_tdata = i_window_size[15:8];
                15: m_ip.ip_payload_axis_tdata = i_window_size[7:0];
                16: m_ip.ip_payload_axis_tdata = checksum[15:8];
                17: m_ip.ip_payload_axis_tdata = checksum[7:0];
                18: m_ip.ip_payload_axis_tdata = '0;
                19: begin
                    m_ip.ip_payload_axis_tdata = '1;
                    m_ip.ip_payload_axis_tlast = '1;
                end
            endcase

            if (m_ip.ip_payload_axis_tready) begin
                counter_next = counter + 1;

                if (m_ip.ip_payload_axis_tlast) begin
                    state_next = IDLE;
                    o_packet_done = '1;
                end
            end
        end
    endcase

end

endmodule