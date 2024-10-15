module checksum_calc (
    input i_rst,
    input i_clk,

    input i_clear,
    input i_enable,

    input [31:0] i_data,

    output [15:0] o_checksum
);

logic [31:0] sum;
logic [31:0] pre_sum;
logic [31:0] sum_next;
logic [15:0] sum_wrapped;

assign sum_wrapped = sum[15:0] + sum [31:16];
assign o_checksum = ~sum_wrapped;

always @(posedge i_clk) begin
    if (i_rst || i_clear) begin
        sum <= '0;
    end else begin
        if (i_enable) begin
            sum <= sum_next;
        end
    end
end

always_comb begin
    pre_sum = i_data[31:16] + i_data[15:0];
    sum_next = sum + pre_sum;
end

endmodule