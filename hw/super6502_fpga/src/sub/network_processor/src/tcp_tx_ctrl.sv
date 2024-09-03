import tcp_pkg::*;

module tcp_tx_ctrl(
    input i_clk,
    input i_rst,

    input  tcp_pkg::tx_ctrl_t   i_tx_ctrl,
    input  logic                i_tx_ctrl_valid,
    output logic                o_tx_ctrl_ack,

    output logic [31:0]         o_seq_number,
    output logic [31:0]         o_ack_number,
    output logic [7:0]          o_flags,
    output logic [15:0]         o_window_size,
    output logic                o_hdr_valid
);

localparam FLAG_FIN = (1 << 0);
localparam FLAG_SYN = (1 << 1);
localparam FLAG_RST = (1 << 2);
localparam FLAG_PSH = (1 << 3);
localparam FLAG_ACK = (1 << 4);
localparam FLAG_URG = (1 << 5);
localparam FLAG_ECE = (1 << 6);
localparam FLAG_CWR = (1 << 7);

enum logic [2:0] {IDLE, SEND_SYN} state, state_next;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        state <= IDLE;
    end else begin
        state <= state_next;
    end
end

always_comb begin
    o_seq_number    = '0;
    o_ack_number    = '0;
    o_flags         = '0;
    o_window_size   = '0;
    o_hdr_valid     = '0;

    case (state)
        IDLE: begin
            if (i_tx_ctrl_valid) begin
                o_tx_ctrl_ack = '1;

                case (i_tx_ctrl)
                    TX_CTRL_SEND_SYN: state_next = SEND_SYN;
                endcase
            end
        end

        SEND_SYN: begin
            o_flags = FLAG_SYN;
            o_hdr_valid = '1;
        end
    endcase
end

endmodule