module mapper(
    input clk,
    input rst,

    input [15:0] cpu_addr,
    output logic [24:0] sdram_addr,

    input cs,
    input rw,

    input [7:0] i_data,
    output logic [7:0] o_data
);

logic [12:0] map [16];

logic [15:0] base_addr;

assign base_addr = cpu_addr - 16'hefb7;

logic en;

always_comb begin
    if (!en) begin
        sdram_addr = {9'b0, cpu_addr};
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        en <= '0;
    end
end

// each each entry is 4k and total address space is 64M,
// so we need 2^14 possible entries

endmodule
