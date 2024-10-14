module tcp_packet_generator (
    input  wire             i_clk,
    input  wire             i_rst,

    axis_intf.SLAVE         s_axis_data,

    input  wire             i_no_data,

    input  wire [15:0]      i_ip_len,
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

axis_intf #(.DATA_WIDTH(8)) pre_checksum_data();
axis_intf #(.DATA_WIDTH(8)) post_checksum_data();

logic saf_ready;

assign pre_checksum_data.tdata = s_axis_data.tdata;
assign pre_checksum_data.tkeep = s_axis_data.tkeep;
assign pre_checksum_data.tvalid = s_axis_data.tvalid & saf_ready;
assign s_axis_data.tready = pre_checksum_data.tready & saf_ready;
assign pre_checksum_data.tlast = s_axis_data.tlast;
assign pre_checksum_data.tuser = s_axis_data.tuser;

axis_saf_fifo #(
    .DATA_DEPTH_L2(11),
    .CTRL_DEPTH_L2(2)
) u_checksum_fifo (
    .sclk(i_clk),
    .srst(i_rst),
    .s_axis(pre_checksum_data),

    .mclk(i_clk),
    .mrst(i_rst),
    .m_axis(post_checksum_data)
);

logic [31:0] counter, counter_next;
enum logic [1:0] {IDLE, DATA_CHECKSUM, HEADER, DATA} state, state_next;


logic [31:0] checksum_counter, checksum_counter_next;
logic [15:0] data_checksum;
assign data_checksum = '0;

logic checksum_enable;
logic checksum_clear;
logic [31:0] checksum_data;
logic [15:0] checksum_final;

logic [31:0] data_expand, data_expand_next;
logic data_checksum_enable;
logic data_checksum_clear;
logic [31:0] data_checksum_data;
logic [15:0] data_checksum_final;

checksum_calc u_header_checksum_calc(
    .i_rst      (i_rst),
    .i_clk      (i_clk),
    .i_clear    (checksum_clear),
    .i_enable   (checksum_enable),

    .i_data     (checksum_data),
    .o_checksum (checksum_final)
);

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        counter <= '0;
        checksum_counter <= '0;
        state <= IDLE;
        data_expand <= '0;
    end else begin
        counter <= counter_next;
        checksum_counter <= checksum_counter_next;
        state <= state_next;
        data_expand <= data_expand_next;
    end
end

always_comb begin
    state_next = state;

    m_ip.ip_hdr_valid = '0;
    m_ip.ip_dscp        = '0;
    m_ip.ip_ecn         = '0;
    m_ip.ip_length      = '0;
    m_ip.ip_ttl         = '0;
    m_ip.ip_protocol    = '0;
    m_ip.ip_source_ip   = '0;
    m_ip.ip_dest_ip     = '0;

    m_ip.ip_payload_axis_tdata  = '0;
    m_ip.ip_payload_axis_tvalid = '0;
    m_ip.ip_payload_axis_tlast  = '0;
    m_ip.ip_payload_axis_tuser  = '0;
    m_ip.ip_payload_axis_tid    = '0;
    m_ip.ip_payload_axis_tdest  = '0;

    post_checksum_data.tready = '0;

    checksum_counter_next = checksum_counter;
    checksum_data = '0;

    counter_next = counter;

    o_packet_done = '0;
    checksum_clear = '0;
    checksum_enable = '0;

    saf_ready = '0;

    data_expand_next = data_expand;

    case (state)

        IDLE: begin
            counter_next = '0;
            checksum_counter_next = '0;
            checksum_clear = '1;

            if (i_hdr_valid) begin
                m_ip.ip_hdr_valid   = '1;
                m_ip.ip_dscp        = '0;
                m_ip.ip_ecn         = '0;
                m_ip.ip_length      = i_ip_len;
                m_ip.ip_ttl         = '1;
                m_ip.ip_protocol    = 8'h6;
                m_ip.ip_source_ip   = i_src_ip;
                m_ip.ip_dest_ip     = i_dst_ip;

                if (m_ip.ip_hdr_ready) begin
                    if (i_no_data) begin
                        state_next = HEADER;
                    end else begin
                        state_next = DATA_CHECKSUM;
                    end
                end
            end
        end

        DATA_CHECKSUM: begin
            saf_ready = '1;

            data_expand_next = {data_expand[23:0], pre_checksum_data.tdata};
            // data_expand_next = {pre_checksum_data.tdata, data_expand[31:8]};

            if (checksum_counter[1:0] == '1) begin
                checksum_enable = '1;
                checksum_data = data_expand_next;
            end


            if (s_axis_data.tready & s_axis_data.tvalid) begin
                checksum_counter_next = checksum_counter + 1;
                if (s_axis_data.tlast) begin
                    state_next = HEADER;
                    checksum_counter_next = '0;
                end
            end
        end

        HEADER: begin
            m_ip.ip_payload_axis_tvalid = '1;
            if (checksum_counter < 8) begin
                checksum_counter_next = checksum_counter + 1;
                checksum_enable = '1;
            end

            case (checksum_counter)
                0: checksum_data = m_ip.ip_source_ip;
                1: checksum_data = m_ip.ip_dest_ip;
                2: checksum_data = {8'b0, m_ip.ip_protocol, (i_ip_len - 16'd20)}; // tcp length, not IP length
                3: checksum_data = {i_source_port, i_dest_port};
                4: checksum_data = i_seq_number;
                5: checksum_data = i_ack_number;
                6: checksum_data = {4'h5, 4'h0, i_flags, i_window_size};
                7: checksum_data = '0;  // checksum and urgent pointer
            endcase

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
                16: m_ip.ip_payload_axis_tdata = checksum_final[15:8];
                17: m_ip.ip_payload_axis_tdata = checksum_final[7:0];
                18: m_ip.ip_payload_axis_tdata = '0;
                19: begin
                    m_ip.ip_payload_axis_tdata = '0;
                    m_ip.ip_payload_axis_tlast = i_no_data;    // kinda hacky
                end
            endcase

            if (m_ip.ip_payload_axis_tready) begin
                counter_next = counter + 1;

                if (counter == 19) begin
                    state_next = DATA;
                end

                if (m_ip.ip_payload_axis_tlast) begin
                    state_next = IDLE;
                    o_packet_done = '1;
                end
            end
        end

        DATA: begin
            state_next = DATA;
            post_checksum_data.tready = m_ip.ip_payload_axis_tready;
            m_ip.ip_payload_axis_tvalid = post_checksum_data.tvalid;
            m_ip.ip_payload_axis_tdata = post_checksum_data.tdata;
            m_ip.ip_payload_axis_tlast = post_checksum_data.tlast;

            if (post_checksum_data.tlast && post_checksum_data.tvalid && post_checksum_data.tready) begin
                state_next = IDLE;
                o_packet_done = '1;
            end
        end
    endcase

end

endmodule