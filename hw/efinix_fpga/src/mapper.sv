module mapper(
    input clk,
    input rst,

    input [15:0] cpu_addr,
    output logic [24:0] sdram_addr,

    input cs,
    input rwb,

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
    end else begin
        sdram_addr = {map[cpu_addr[15:12]], cpu_addr[11:0]};
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        en <= '0;
        for (bit [13:0] a = 14'b0; a < 14'h10; a++) begin
            map[a] = a;
        end
    end else begin
        if (~rwb & cs) begin
            if (base_addr == 16'h32) begin
                en <= i_data[0];
            end else begin
                if (!base_addr[0]) begin
                    map[base_addr[3:1]] <= {i_data[5:0], map[base_addr[3:1]][7:0]};
                end else begin
                    map[base_addr[3:1]] <= {map[base_addr[3:1]][12:8], i_data};
                end
            end
        end
    end
end

// each each entry is 4k and total address space is 64M,
// so we need 2^14 possible entries

endmodule
