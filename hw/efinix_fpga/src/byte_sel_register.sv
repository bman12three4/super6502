module byte_sel_register
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 32
)(
    input i_clk,
    input i_reset,
    input i_write,
    input [$clog2(ADDR_WIDTH)-1:0] i_byte_sel,
    input [DATA_WIDTH-1:0] i_data,
    output [DATA_WIDTH-1:0] o_data,
    output [DATA_WIDTH*ADDR_WIDTH-1:0] o_full_data
);

logic [DATA_WIDTH*ADDR_WIDTH-1:0] r_data;

assign o_data = r_data[DATA_WIDTH*i_byte_sel +: DATA_WIDTH];
assign o_full_data = r_data;

always_ff @(posedge i_clk) begin
    if (i_reset) begin
        r_data <= '0;
    end else begin
        r_data <= r_data;
        if (i_write) begin
            r_data[DATA_WIDTH*i_byte_sel +: DATA_WIDTH] <= i_data;
        end
    end
end

endmodule