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

enum logic [2:0] {IDLE, SEND_SYN} state, state_next;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        state <= IDLE;
    end else begin
        state <= state_next;
    end
end

always_comb begin
    case (state)
        IDLE: begin
            if (i_tx_ctrl) begin
                o_tx_ctrl_ack = '1;
            end
        end
    endcase
end

endmodule