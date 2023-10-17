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

initial begin
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

    write_reg(0, 8'haa);
    write_reg(1, 8'hbb);

    repeat (5) @(posedge r_clk_cpu);

    assert (u_mapper.mm[0] == 16'hbbaa) else begin
        $error("mm[0] expected 0xbbaa got 0x%x", u_mapper.mm[0]);
        errors += 1;
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
