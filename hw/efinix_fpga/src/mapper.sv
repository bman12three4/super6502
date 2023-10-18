module mapper(
    input i_reset,
    input i_clk,
    input i_cs,
    input i_we,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input [15:0] i_cpu_addr,
    output logic [24:0] o_mapped_addr
);

logic [15:0] mm [16];

logic [31:0] we;

logic [15:0] mm_sel;

always_comb begin
    we = (i_we << i_cpu_addr[4:0]);

    o_data = mm_sel[8*i_cpu_addr[0] +: 8];
end

always_ff @(negedge i_clk or posedge i_reset) begin
    if (i_reset) begin
        for (int i = 0; i < 16; i++) begin
            mm[i] <= i;
        end
    end

    for (int i = 0; i < 32; i++) begin
        if (we[i]) begin
            mm[i/2][(i%2)*8 +: 8] <= i_data;
        end
    end


end

endmodule
