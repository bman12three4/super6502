import tcp_pkg::*;

module tcp_rx_ctrl (
    input wire              i_clk,
    input wire              i_rst,

    output tcp_pkg::rx_msg_t    o_rx_msg,
    output logic                o_rx_msg_valid,
    input  logic                i_rx_msg_ack,

    input  wire [31:0]      i_seq_number,
    input  wire [31:0]      i_ack_number,
    input  wire [15:0]      i_source_port,
    input  wire [15:0]      i_dest_port,
    input  wire [7:0]       i_flags,
    input  wire [15:0]      i_window_size,
    input  wire             i_hdr_valid
);

always_ff @(posedge i_clk) begin
    if (i_hdr_valid) begin
        if (i_flags & 8'h12) begin
            o_rx_msg = RX_MSG_RECV_SYNACK;
            o_rx_msg_valid = '1;
        end
    end
end

endmodule