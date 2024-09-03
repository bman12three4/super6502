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
    SYN_SENT,
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
        if (i_enable) begin
            tcp_state <= IDLE;
        end else begin
            tcp_state <= tcp_state_next;
        end
    end
end

always_comb begin
    tcp_state_next = tcp_state;

    o_tx_ctrl = TX_CTRL_NOP;
    o_tx_ctrl_valid = '0;

    o_rx_msg_ack = '0;

    case (tcp_state)
        IDLE: begin
            if (i_open) begin
                o_tx_ctrl = TX_CTRL_SEND_SYN;
                o_tx_ctrl_valid = '1;

                if (i_tx_ctrl_ack) begin
                    tcp_state_next = SYN_SENT;
                end
            end
        end

        SYN_SENT: begin
            $display("SYN_SENT not implemented");
        end
    endcase
end

endmodule