module multiplier(
    input clk,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,
    input [2:0] addr
);

logic [15:0] a, b;
logic [31:0] out;

always_ff @(negedge clk) begin
    if (reset) begin
        a <= '0;
        b <= '0;
    end


    if (cs & ~rwb) begin
        case (addr)
            3'h0: begin
                a[7:0] <= i_data;
            end

            3'h1: begin
                a[15:8] <= i_data;
            end

            3'h2: begin
                b[7:0] <= i_data;
            end

            3'h3: begin
                b[15:8] <= i_data;
            end
        endcase
    end
end

assign out = a * b;
assign o_data = out[((addr-4)*8)+:8];


endmodule