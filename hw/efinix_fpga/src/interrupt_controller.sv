module interrupt_controller
(
    input clk,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input addr,
    input cs,
    input rwb,

    input [255:0] int_in,
    output logic int_out
);

logic [7:0] w_enable_data;
logic [255:0] w_enable_full_data;

logic [4:0] w_byte_sel;

logic [7:0] irq_val;

byte_sel_register #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(32)
) reg_enable (
    .i_clk(clk),
    .i_write(w_enable_write),
    .i_byte_sel(w_byte_sel),
    .i_data(i_data),
    .o_data(w_enable_data),
    .o_full_data(w_enable_full_data)
);

logic [255:0] int_masked;
assign int_masked = int_in & w_enable_full_data;


logic [7:0] w_type_data;
logic [255:0] w_type_full_data;

byte_sel_register #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(32)
) reg_type (
    .i_clk(clk),
    .i_write(w_type_write),
    .i_byte_sel(w_byte_sel),
    .i_data(i_data),
    .o_data(w_type_data),
    .o_full_data(w_type_full_data)
);

logic w_eoi;

logic [255:0] r_int, r_int_next;

always_comb begin
    r_int_next = (~r_int | w_type_full_data) & int_masked;
    if (w_eoi) begin
        r_int_next[irq_val] = 0;
    end
end

always_ff @(posedge clk) begin
    r_int <= r_int_next;
end

always_comb begin
    for (int i = 255; i == 0; i--) begin
        if (r_int[i] == 1) begin
            irq_val = i;
        end
    end
end

endmodule