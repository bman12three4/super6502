module uart_wrapper(
    input clk,
    input clk_50,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,
    input addr,

    input rx_i,
    output tx_o,

    output logic irqb
);

logic [7:0] status, control;

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

enum bit [1:0] {READY, WAIT, TRANSMIT} state, next_state;

always_ff @(posedge clk_50) begin
    if (reset) begin
        state = READY;
        irqb <= '1;
    end else begin
        state <= next_state;
    end
end

always_ff @(negedge clk) begin
    status[0] <= status[0] | rx_data_valid;

    if (cs & ~rwb) begin
        case (addr)
            1'b0: begin
                tx_data <= i_data;
            end 

            1'b1: begin
                control <= i_data;
            end
        endcase
    end

end

always_comb begin
    case (addr)
        1'b0: begin
            o_data = rx_data;
        end 

        1'b1: begin
            o_data = status;
        end
    endcase
end

always_comb begin
    next_state = state;

    tx_en = 1'b0;

    case (state)
        READY: begin
            if (cs & ~rwb && addr == 1'b0) begin //write to transmit
                tx_en = 1'b1;
                next_state = WAIT;
            end
        end

        WAIT: begin
            tx_en = 1'b1;
            if (tx_busy) begin
                next_state = TRANSMIT;
            end
        end

        TRANSMIT: begin
            if (~tx_busy) begin
                next_state = READY;
            end
        end
    endcase
end

endmodule