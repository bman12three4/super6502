import tcp_pkg::*;

module tcp_rx_ctrl (
    input  logic              i_clk,
    input  logic              i_rst,

    output tcp_pkg::rx_msg_t  o_rx_msg,
    output logic              o_rx_msg_valid,
    input  logic              i_rx_msg_ack,

    input  logic [31:0]       i_seq_number,
    input  logic [31:0]       i_ack_number,
    input  logic [15:0]       i_source_port,
    input  logic [15:0]       i_dest_port,
    input  logic [7:0]        i_flags,
    input  logic [15:0]       i_window_size,
    input  logic              i_hdr_valid,

    output logic [31:0]       o_ack_number
);

tcp_pkg::rx_msg_t rx_msg_next;
logic rx_msg_valid_next;

logic [31:0] ack_num, ack_num_next;
assign o_ack_number = ack_num;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        ack_num <= '0;
        o_rx_msg <= RX_MSG_NOP;
        o_rx_msg_valid <= '0;
    end else begin
        ack_num <= ack_num_next;
        o_rx_msg <= rx_msg_next;
        o_rx_msg_valid <= rx_msg_valid_next;
    end
end

always_comb begin
    rx_msg_next = RX_MSG_NOP;
    rx_msg_valid_next = '0;

    ack_num_next = ack_num;

    if (i_hdr_valid) begin
        if (i_flags == 8'h12) begin
            rx_msg_next = RX_MSG_RECV_SYNACK;
            rx_msg_valid_next = '1;

            ack_num_next = i_seq_number + 1;
        end

        if (i_flags == 8'h11) begin
            rx_msg_next = RX_MSG_RECV_FIN;
            rx_msg_valid_next = '1;
            ack_num_next = i_seq_number + 1;
        end

        if (i_flags == 8'h10) begin
            rx_msg_next = RX_MSG_RECV_ACK;
            rx_msg_valid_next = '1;
        end

    end
end

endmodule
