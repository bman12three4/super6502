import tcp_pkg::*;

module tcp_state_manager(
    input  wire                 i_clk,
    input  wire                 i_rst,

    input  wire                 i_enable,

    input  wire                 i_open,
    output logic                o_open_clr,
    input  wire                 i_close,
    output logic                o_close_clr,

    output tcp_pkg::tx_ctrl_t   o_tx_ctrl,
    output logic                o_tx_ctrl_valid,
    input  logic                i_tx_ctrl_ack,

    input tcp_pkg::rx_msg_t     i_rx_msg,
    input  wire                 i_rx_msg_valid,
    output logic                o_rx_msg_ack
);

enum logic [3:0] {
    IDLE,
    SYN_RCVD,       // In this design, this state should not be reached!
    SYN_SENT_1,
    SYN_SENT_2,
    ESTABLISHED,
    WAIT_CLOSE,
    LAST_ACK,
    TIME_WAIT,
    FIN_WAIT_1,
    FIN_WAIT_2
} tcp_state, tcp_state_next;


always_ff @(posedge i_clk) begin
    if (i_rst) begin
        tcp_state <= IDLE;
    end else begin
        if (~i_enable) begin
            tcp_state <= IDLE;
        end else begin
            tcp_state <= tcp_state_next;
        end
    end
end

always_comb begin
    tcp_state_next = tcp_state;

    o_tx_ctrl_valid = '0;
    o_open_clr = '0;

    o_tx_ctrl = TX_CTRL_NOP;
    o_tx_ctrl_valid = '0;

    o_rx_msg_ack = '0;

    case (tcp_state)
        IDLE: begin
            if (i_open) begin
                o_tx_ctrl = TX_CTRL_SEND_SYN;
                o_tx_ctrl_valid = '1;

                if (i_tx_ctrl_ack) begin
                    tcp_state_next = SYN_SENT_1;
                end
            end
        end

        SYN_SENT_1: begin
            if (i_rx_msg_valid && i_rx_msg== RX_MSG_RECV_SYNACK) begin
                tcp_state_next = SYN_SENT_2;
            end
        end

        SYN_SENT_2: begin
            o_tx_ctrl = TX_CTRL_SEND_ACK;
            o_tx_ctrl_valid = '1;

            if (i_tx_ctrl_ack) begin
                tcp_state_next = ESTABLISHED;
                o_open_clr = '1;
            end
        end

        ESTABLISHED: begin
            if (i_rx_msg_valid && i_rx_msg == RX_MSG_RECV_FIN) begin
                o_tx_ctrl = TX_CTRL_SEND_FIN;
                o_tx_ctrl_valid = '1;
                tcp_state_next = LAST_ACK;
            end

            if (i_close) begin
                o_tx_ctrl = TX_CTRL_SEND_FIN;
                o_tx_ctrl_valid = '1;
                tcp_state_next = FIN_WAIT_1;
            end
        end

        FIN_WAIT_1: begin
            if (i_rx_msg_valid) begin
                if (i_rx_msg == RX_MSG_RECV_ACK) begin
                    tcp_state_next = FIN_WAIT_2;
                end else if (i_rx_msg == RX_MSG_RECV_FIN) begin
                    tcp_state_next = TIME_WAIT;
                    o_tx_ctrl_valid = '1;
                    o_tx_ctrl = TX_CTRL_SEND_ACK;
                end
            end
        end

        FIN_WAIT_2: begin
            if (i_rx_msg == RX_MSG_RECV_FIN) begin
                tcp_state_next = TIME_WAIT;
                o_tx_ctrl = TX_CTRL_SEND_ACK;
                o_tx_ctrl_valid = '1;
            end
        end

        TIME_WAIT: begin
            tcp_state_next = IDLE;
        end

        LAST_ACK: begin
            if (i_rx_msg_valid && i_rx_msg == RX_MSG_RECV_ACK) begin
                tcp_state_next = IDLE;
            end
        end
    endcase
end

endmodule
