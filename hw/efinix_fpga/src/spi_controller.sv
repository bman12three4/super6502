module spi_controller(
    input i_clk,
    input i_rst,

    input i_cs,
    input i_rwb,
    input [1:0] i_addr,
    input [7:0] i_data,
    output logic [7:0] o_data,

    output o_spi_cs,
    output o_spi_clk,
    output o_spi_mosi,
    input i_spi_miso
);


// We need a speed register
// an input data register
// and an output data register
// and then a control register for cs

logic [7:0] r_baud_rate;
logic [7:0] r_input_data;
logic [7:0] r_output_data;
logic [7:0] r_control;

logic [8:0] r_clock_counter;

logic active;
logic [2:0] count;
logic spi_clk;

logic r_spi_mosi;

assign o_spi_cs = ~r_control[0];
assign o_spi_clk = spi_clk;
assign o_spi_mosi = r_spi_mosi;

always @(negedge i_clk) begin
    if (i_rst) begin
        r_baud_rate <= 8'h1;
        r_input_data <= '0;
        r_output_data <= '0;
        r_control <= '0;
        r_clock_counter <= '0;
        count <= '0;
        spi_clk <= '0;
        active <= '0;
    end else begin
        if (~i_rwb & i_cs) begin
            unique case (i_addr)
                0: r_baud_rate <= i_data;
                1:;
                2: begin 
                    r_output_data <= i_data;
                    active <= '1;
                end
                3: r_control <= i_data;
            endcase
        end

        if (active) begin
            r_spi_mosi <= r_output_data[7];
            r_clock_counter <= r_clock_counter + 9'b1;
            if (r_clock_counter >= r_baud_rate) begin
                r_clock_counter <= '0;
                spi_clk <= ~spi_clk;
                // rising edge
                if (spi_clk == '0) begin
                    r_output_data <= r_output_data << 1;
                    count <= count + 1;
                end
                // falling edge
                if (spi_clk == '1) begin
                    r_input_data <= {r_input_data[6:0], i_spi_miso};
                    if (count == '0) begin
                        active <= '0;
                    end
                end
            end

        end
    end
end

always_comb begin
    unique case (i_addr)
        0: o_data = r_baud_rate;
        1: o_data = r_input_data;
        2:;
        3: o_data = {active, r_control[6:0]};
        default: o_data = 'x;
    endcase
end


endmodule