module rtc(
    input clk,
    input reset,
    input rwb,
    input cs,
    input addr,
    input [7:0] i_data,
    output logic [7:0] o_data,
    output logic irq  
);

localparam REG_SIZ = 32;

logic [REG_SIZ-1:0] r_counter, r_counter_next;
logic [REG_SIZ-1:0] r_irq_counter, r_irq_counter_next;

// Because we need to increment this, it can't be
// a byte sel register. Thats fine because we don't need
// to be able to write from the cpu anyway.
logic [REG_SIZ-1:0] r_output, r_output_next;

logic [1:0] w_byte_sel;

logic w_increment_write;
logic [7:0] w_increment_data;
logic [REG_SIZ-1:0] w_increment_full_data;

byte_sel_register #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(REG_SIZ/8)
) u_increment_reg (
    .i_clk(~clk),
    .i_reset(reset),
    .i_write(w_increment_write),
    .i_byte_sel(w_byte_sel),
    .i_data(i_data),
    .o_data(w_increment_data),
    .o_full_data(w_increment_full_data)
);

logic w_threshold_write;
logic [7:0] w_threshold_data;
logic [REG_SIZ-1:0] w_threshold_full_data;

byte_sel_register #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(REG_SIZ/8)
) u_threshold_reg (
    .i_clk(~clk),
    .i_reset(reset),
    .i_write(w_threshold_write),
    .i_byte_sel(w_byte_sel),
    .i_data(i_data),
    .o_data(w_threshold_data),
    .o_full_data(w_threshold_full_data)
);

logic w_irq_threshold_write;
logic [7:0] w_irq_threshold_data;
logic [REG_SIZ-1:0] w_irq_threshold_full_data;

byte_sel_register #(
    .DATA_WIDTH(8),
    .ADDR_WIDTH(REG_SIZ/8)
) u_irq_threshold_reg (
    .i_clk(~clk),
    .i_reset(reset),
    .i_write(w_irq_threshold_write),
    .i_byte_sel(w_byte_sel),
    .i_data(i_data),
    .o_data(w_irq_threshold_data),
    .o_full_data(w_irq_threshold_full_data)
);

logic we, re;

assign we = cs & ~rwb;
assign re = cs & rwb;


logic [7:0] cmd, cmd_next;

logic [7:0] ctrl, ctrl_next;

always_comb begin
    if (addr == '0 && we) begin
        cmd_next = i_data;
    end else begin
        cmd_next = cmd;
    end

    w_increment_write = 0;
    w_threshold_write = 0;
    w_irq_threshold_write = 0;
    w_byte_sel = cmd[3:0];

    ctrl_next = ctrl;

    if (addr == '1) begin
        unique casez (cmd)
            8'h0?: begin
                w_threshold_write = we;
                o_data = w_threshold_data;
            end

            8'h1?: begin
                w_increment_write = we;
                o_data = w_increment_data;
            end

            8'h2?: begin
                w_irq_threshold_write = we;
                o_data = w_irq_threshold_data;
            end

            8'h3?: begin
                if (we) begin
                    ctrl_next = i_data;
                end
                o_data = r_output[8*w_byte_sel +: 8];
            end
        endcase
    end
end

always_comb begin
    r_counter_next = r_counter + w_increment_full_data;


    r_irq_counter_next = r_irq_counter;
    r_output_next = r_output;

    if (r_counter == w_threshold_full_data) begin
        r_counter_next = '0;
        r_irq_counter_next = r_irq_counter + 1;
        r_output_next = r_output + 1;
    end

    irq = 0;
    if (r_irq_counter == w_irq_threshold_full_data) begin
        irq = ctrl[1];
        r_irq_counter_next = '0;
    end

    if (ctrl[0] == '0) begin
        r_irq_counter_next = 0;
        r_counter_next = '0;
        r_output_next = '0;
    end
end

// Does it matter if we do negedge clock or just invert the input to the module?
always_ff @(negedge clk) begin
    if (reset) begin
        r_counter <= '0;
        r_irq_counter <= '0;
        r_output <= '0;
        cmd <= '0;
        ctrl <= '0;
    end else begin
        ctrl <= ctrl_next;
        cmd <= cmd_next;
        r_counter <= r_counter_next;
        r_irq_counter <= r_irq_counter_next;
        r_output <= r_output_next;
    end
end


endmodule