module mapper(
    input i_reset,
    input i_clk,
    input i_clk50,
    input i_clk100,
    input i_cs,
    input i_we,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input [15:0] i_cpu_addr,
    output logic [24:0] o_mapped_addr
);

logic [15:0] mm [16];
logic [15:0] _mm [16];
logic [15:0] mm_next [16];

logic [31:0] we;


// TODO These have basically the same name.
logic [15:0] mm_sel;

logic [15:0] selected_mm;

logic [15:0] _cpu_addr;

always_comb begin
    we = ((i_we & i_cs) << i_cpu_addr[4:0]);

    mm_sel = (1 << i_cpu_addr[4:1]);
    o_data = mm_sel[8*i_cpu_addr[0] +: 8];

    o_mapped_addr = {selected_mm[12:0], i_cpu_addr[11:0]};

    for (int i = 0; i < 16; i++) begin
        mm_next[i] = mm[i];
    end

    for (int i = 0; i < 32; i++) begin
        if (we[i]) begin
            mm_next[i/2][(i%2)*8 +: 8] = i_data;
        end
    end
end

always_ff @(posedge i_clk100) begin
    _cpu_addr <= i_cpu_addr;
    selected_mm <= mm[_cpu_addr[15:12]];
end

always_ff @(negedge i_clk or posedge i_reset) begin
    if (i_reset) begin
        for (int i = 0; i < 16; i++) begin
            mm[i] <= i;
        end
    end else begin
        for (int i = 0; i < 16; i++) begin
            mm[i] <= mm_next[i];
        end
    end


end

endmodule
