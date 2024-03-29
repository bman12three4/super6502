module interrupt_controller 
#(
    parameter N_INTERRUPTS = 128
)(
    input clk,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input addr,
    input cs,
    input rwb,

    input [N_INTERRUPTS-1:0] int_in,
    output logic int_out
);

logic w_enable_write;
logic [7:0] w_enable_data;
logic [N_INTERRUPTS-1:0] w_enable_full_data;

logic [N_INTERRUPTS-1:0] int_in_d1;

logic [4:0] w_byte_sel;

logic [7:0] irq_val;

byte_sel_register #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(N_INTERRUPTS/8)
) reg_enable (
    .i_clk(~clk),
    .i_reset(reset),
    .i_write(w_enable_write),
    .i_byte_sel(w_byte_sel),
    .i_data(i_data),
    .o_data(w_enable_data),
    .o_full_data(w_enable_full_data)
);

logic we, re;

assign we = cs & ~rwb;
assign re = cs & rwb;

logic [N_INTERRUPTS-1:0] int_masked;
assign int_masked = int_in & w_enable_full_data;


logic w_type_write;
logic [7:0] w_type_data;
logic [N_INTERRUPTS-1:0] w_type_full_data;

byte_sel_register #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(N_INTERRUPTS/8)
) reg_type (
    .i_clk(~clk),
    .i_reset(reset),
    .i_write(w_type_write),
    .i_byte_sel(w_byte_sel),
    .i_data(i_data),
    .o_data(w_type_data),
    .o_full_data(w_type_full_data)
);

logic [7:0] cmd, cmd_next;

logic w_eoi;

logic [N_INTERRUPTS-1:0] r_int, r_int_next;

always_comb begin
    w_eoi = 0;

    if (addr == '0 && we) begin
        cmd_next = i_data;
    end else begin
        cmd_next = cmd;
    end


    w_type_write = '0;
    w_enable_write = '0;

    if (addr == '1) begin
        unique casez (cmd)
            8'b000?????: begin
                o_data = irq_val;
            end

            8'b001?????: begin
                w_enable_write = we;
                w_byte_sel = cmd[4:0];
                o_data = w_enable_data;
            end

            8'b010?????: begin
                w_type_write = we;
                w_byte_sel = cmd[4:0];
                o_data = w_type_data;
            end

            8'hff: begin
                // Kind of dumb, still requires a data write
                w_eoi = i_data[0] & we;
            end
        endcase
    end

    int_out = |r_int;

    irq_val = 8'hff;
    for (int i = N_INTERRUPTS-1; i >= 0; i--) begin
        if (r_int[i] == 1) begin
            irq_val = i;
        end
    end

    for (int i = 0; i < N_INTERRUPTS; i++) begin
        case (w_type_full_data[i])
            0: begin    // Edge triggered
                if (w_eoi && i == irq_val) begin
                    r_int_next[i] = 0;
                end else begin
                    r_int_next[i] = (~int_in_d1[i] & int_masked[i]) | r_int[i];
                end
            end

            1: begin    // Level Triggered
                // If we are trying to clear this interrupt but it is still active,
                // then we don't actually want to clear it.
                if (w_eoi && i == irq_val) begin
                    r_int_next[i] = int_masked[i];
                end else begin
                    r_int_next[i] = r_int[i] | int_masked[i];
                end
            end
        endcase
    end
end

always_ff @(negedge clk) begin
    if (reset) begin
        r_int <= '0;
        cmd <= '0;
        int_in_d1 <= '0;
    end else begin
        r_int <= r_int_next;
        cmd <= cmd_next;
        int_in_d1 <= int_in;
    end
end

endmodule