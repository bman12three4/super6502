import tcp_pkg::*;

module tcp_tx_ctrl(
    input i_clk,
    input i_rst,

    input  tcp_pkg::tx_ctrl_t   i_tx_ctrl,
    input  logic                i_tx_ctrl_valid,
    output logic                o_tx_ctrl_ack,

    output logic [15:0]         o_ip_len,
    output logic [31:0]         o_seq_number,
    output logic [31:0]         o_ack_number,
    output logic [7:0]          o_flags,
    output logic [15:0]         o_window_size,
    output logic                o_hdr_valid,

    input  wire                 i_packet_done
);

localparam FLAG_FIN = (1 << 0);
localparam FLAG_SYN = (1 << 1);
localparam FLAG_RST = (1 << 2);
localparam FLAG_PSH = (1 << 3);
localparam FLAG_ACK = (1 << 4);
localparam FLAG_URG = (1 << 5);
localparam FLAG_ECE = (1 << 6);
localparam FLAG_CWR = (1 << 7);

logic [31:0] seq_num, seq_num_next;
assign o_seq_number = seq_num;

enum logic [2:0] {IDLE, SEND_SYN, SEND_ACK} state, state_next;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        state <= IDLE;
        seq_num <= '0;
    end else begin
        state <= state_next;
        seq_num <= seq_num_next;
    end
end

always_comb begin
    o_ack_number    = '0;
    o_flags         = '0;
    o_window_size   = 16'b1;
    o_hdr_valid     = '0;

    seq_num_next = seq_num;

    o_ip_len        = 16'd40;   // default length of IP packet

    case (state)
        IDLE: begin
            if (i_tx_ctrl_valid) begin
                o_tx_ctrl_ack = '1;

                case (i_tx_ctrl)
                    TX_CTRL_SEND_SYN: state_next = SEND_SYN;
                    TX_CTRL_SEND_ACK: state_next = SEND_ACK;
                endcase
            end
        end

        SEND_SYN: begin
            o_flags = FLAG_SYN;
            o_hdr_valid = '1;

            if (i_packet_done) begin
                state_next = IDLE;
                seq_num_next = seq_num + 1;
            end
        end

        SEND_ACK: begin
            o_flags = FLAG_ACK;
            o_hdr_valid = '1;

            if (i_packet_done) begin
                state_next = IDLE;
                seq_num_next = seq_num + 1;
            end
        end
    endcase
end

endmodule