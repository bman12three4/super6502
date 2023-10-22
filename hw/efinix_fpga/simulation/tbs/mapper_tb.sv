`timescale 1ns/1ps

module mapper_tb();

logic r_clk_cpu;

// clk_cpu
initial begin
    r_clk_cpu <= '1;
    forever begin
        #125 r_clk_cpu <= ~r_clk_cpu;
    end
end

logic reset;
logic [15:0] addr;
logic [24:0] map_addr;
logic [7:0] i_data;
logic [7:0] o_data;
logic cs;
logic rwb;

mapper u_mapper(
    .i_reset(reset),
    .i_clk(r_clk_cpu),
    .i_cs(cs),
    .i_we(~rwb),
    .i_data(i_data),
    .o_data(o_data),
    .i_cpu_addr(addr),
    .o_mapped_addr(map_addr)
);


/* These could be made better probably */
task write_reg(input logic [4:0] _addr, input logic [7:0] _data);
    @(negedge r_clk_cpu);
    cs <= '1;
    addr <= _addr;
    rwb <= '0;
    i_data <= '1;
    @(posedge r_clk_cpu);
    i_data <= _data;
    @(negedge r_clk_cpu);
    cs <= '0;
    rwb <= '1;
endtask

task read_reg(input logic [2:0] _addr, output logic [7:0] _data);
    @(negedge r_clk_cpu);
    cs <= '1;
    addr <= _addr;
    rwb <= '1;
    i_data <= '1;
    @(posedge r_clk_cpu);
    _data <= o_data;
    @(negedge r_clk_cpu);
    cs <= '0;
    rwb <= '1;
endtask

int errors;

int rnd_values [16];

int rnd_addr;

initial begin
    for (int i = 0; i < 16; i++) begin
        rnd_values[i] = $urandom();
    end


    errors = 0;
    repeat (5) @(posedge r_clk_cpu);
    reset = 1;
    cs = 0;
    rwb = 1;
    addr = '0;
    i_data = '0;
    repeat (5) @(posedge r_clk_cpu);
    reset = 0;
    repeat (5) @(posedge r_clk_cpu);


    for (int i = 0; i < 16; i++) begin
        write_reg(2*i,     rnd_values[i][7:0]);
        write_reg(2*i + 1, rnd_values[i][15:8]);
    end

    repeat (5) @(posedge r_clk_cpu);

    for (int i = 0; i < 16; i++) begin
        assert (u_mapper.mm[i] == rnd_values[i][15:0]) else begin
            $error("mm[%d] expected 0x%x got 0x%x", i, rnd_values[i][15:0], u_mapper.mm[i]);
            errors += 1;
        end
    end

    for (int i = 0; i < 16; i++) begin
        rnd_addr = $urandom();
        addr = i << 12 | rnd_addr[11:0];
        #1 // Neccesary for this assertion to work
        assert (map_addr == {rnd_values[i][12:0], rnd_addr[11:0]}) else begin
            $error("Expected %x got %x", {rnd_values[i][12:0], rnd_addr[11:0]}, map_addr);
        end

        @(posedge r_clk_cpu);
    end

    if (errors != 0) begin
        $finish_and_return(-1);
    end else begin
        $finish();
    end
end

initial
begin
    $dumpfile("mapper_tb.vcd");
    $dumpvars(0,mapper_tb);
    for (int i = 0; i < 16; i++) $dumpvars(0, u_mapper.mm[i]);
end

endmodule
