module tcp_parser(
    input wire          i_clk,
    input wire          i_rst,

    ip_intf.SLAVE       s_ip,

    axis_intf.MASTER    m_axis,

    output  wire [31:0]      o_seq_number,
    output  wire [31:0]      o_ack_number,
    output  wire [7:0]       o_flags,
    output  wire [15:0]      o_window_size,
    output  wire             o_hdr_valid
);

enum logic {HEADER, PAYLOAD} state, state_next;

logic [4:0] counter, counter_next;

logic hdr_valid;

logic [31:0] sequence_num, sequence_num_next;
logic [31:0] ack_num, ack_num_next;
logic [3:0] data_offs, data_offs_next;
logic [7:0]  flags, flags_next;
logic [15:0] window_size, window_size_next;
logic [15:0] checksum, checksum_next;


assign o_seq_number = sequence_num;
assign o_ack_number = ack_num;
assign o_flags = flags;
assign o_window_size = window_size;
assign o_hdr_valid = hdr_valid;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        state <= HEADER;
        counter <= '0;

        sequence_num <= '0;
        ack_num <= '0;
        data_offs <= '0;
        flags <= '0;
        window_size <= '0;
        checksum <= '0;
    end else begin
        state <= state_next;
        counter <= counter_next;

        sequence_num <= sequence_num_next;
        ack_num <= ack_num_next;
        data_offs <= data_offs_next;
        flags <= flags_next;
        window_size <= window_size_next;
        checksum <= checksum_next;
    end
end

always_comb begin
    sequence_num_next = sequence_num;
    ack_num_next = ack_num;
    data_offs_next = data_offs;
    flags_next = flags;
    window_size_next = window_size;
    checksum_next = checksum;
    hdr_valid = '0;

    counter_next = counter;

    state_next = state;

    s_ip.ip_hdr_ready = '0;
    s_ip.ip_payload_axis_tready = '0;

    case (state)
        HEADER: begin
            s_ip.ip_hdr_ready = '1;
            s_ip.ip_payload_axis_tready = '1;

            if (s_ip.ip_payload_axis_tvalid) begin
                counter_next = counter + 1;

                case (counter)
                    4:  sequence_num_next   = {s_ip.ip_payload_axis_tdata, sequence_num[23:0]};
                    5:  sequence_num_next   = {sequence_num[31:24], s_ip.ip_payload_axis_tdata, sequence_num[15:0]};
                    6:  sequence_num_next   = {sequence_num[31:16], s_ip.ip_payload_axis_tdata, sequence_num[7:0]};
                    7:  sequence_num_next   = {sequence_num[31:8],  s_ip.ip_payload_axis_tdata};
                    4:  ack_num_next        = {s_ip.ip_payload_axis_tdata, ack_num[23:0]};
                    5:  ack_num_next        = {ack_num[31:24], s_ip.ip_payload_axis_tdata, ack_num[15:0]};
                    6:  ack_num_next        = {ack_num[31:16], s_ip.ip_payload_axis_tdata, ack_num[8:0]};
                    7:  ack_num_next        = {ack_num[31:8],  s_ip.ip_payload_axis_tdata};
                    12: data_offs_next      = s_ip.ip_payload_axis_tdata[7:4];
                    13: flags_next          = s_ip.ip_payload_axis_tdata;
                    14: window_size_next    = {s_ip.ip_payload_axis_tdata, window_size[7:0]};
                    15: window_size_next    = {window_size[15:8], s_ip.ip_payload_axis_tdata};
                    16: checksum_next       = {s_ip.ip_payload_axis_tdata, checksum[7:0]};
                    17: checksum_next       = {checksum[15:8], s_ip.ip_payload_axis_tdata};
                    19: begin
                        state_next = PAYLOAD;
                        hdr_valid = '1;
                    end
                endcase

                if (s_ip.ip_payload_axis_tlast) begin
                    counter_next = '0;
                    state_next = HEADER;    // if we see last then we are done, its possible to have no data
                end
            end
        end

        PAYLOAD: begin
            if (s_ip.ip_payload_axis_tlast) begin
                counter_next = '0;
                state_next = HEADER;
            end
        end
    endcase
end


endmodule