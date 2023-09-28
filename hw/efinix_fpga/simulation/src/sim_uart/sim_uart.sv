module sim_uart(
    input clk,
    input clk_50,
    input reset,

    input [7:0] i_data,

    input rx_i,
    output tx_o
);

logic tx_busy, rx_busy;

logic rx_data_valid, rx_error, rx_parity_error;
logic baud_x16_ce;

logic tx_en;

logic [7:0] tx_data, rx_data;

uart u_uart(
    .tx_o ( tx_o ),
    .rx_i ( rx_i ),
    .tx_busy ( tx_busy ),
    .rx_data ( rx_data ),
    .rx_data_valid ( rx_data_valid ),
    .rx_error ( rx_error ),
    .rx_parity_error ( rx_parity_error ),
    .rx_busy ( rx_busy ),
    .baud_x16_ce ( baud_x16_ce ),
    .clk ( clk_50 ),
    .reset ( reset ),
    .tx_data ( tx_data ),
    .baud_rate ( baud_rate ),
    .tx_en ( tx_en )
);

always @(posedge baud_x16_ce) begin
    if (rx_data_valid)
        $display("UART: %c", rx_data);
end

endmodule
