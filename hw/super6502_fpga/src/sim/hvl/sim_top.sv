`timescale 1ns/1ps

module sim_top();

localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 32;

logic clk_100, clk_200, clk_50, clk_cpu;

// clk_100
initial begin
    clk_100 <= '1;
    forever begin
        #5 clk_100 <= ~clk_100;
    end
end

// clk_200
initial begin
    clk_200 <= '1;
    forever begin
        #2.5 clk_200 <= ~clk_200;
    end
end

// clk_50
initial begin
    clk_50 <= '1;
    forever begin
        #10 clk_50 <= ~clk_50;
    end
end

// clk_cpu
// 2MHz
initial begin
    clk_cpu <= '1;
    forever begin
        // #62.5 clk_cpu <= ~clk_cpu;
        #250 clk_cpu <= ~clk_cpu;
    end
end


initial begin
    $dumpfile("sim_top.vcd");
    $dumpvars(0,sim_top);
end

logic button_reset;

logic           w_cpu0_reset;
logic [15:0]    w_cpu0_addr;
logic [7:0]     w_cpu0_data_from_cpu;
logic [7:0]     w_cpu0_data_from_dut;
logic           w_cpu0_rdy;
logic           w_cpu0_irqb;
logic           w_cpu0_we;
logic           w_cpu0_sync;

cpu_65c02 u_cpu0 (
    .phi2   (clk_cpu),
    .reset  (~w_cpu0_reset),
    .AB     (w_cpu0_addr),
    .RDY    (w_cpu0_rdy),
    .IRQ    (~w_cpu0_irqb),
    .NMI    ('0),
    .DI_s1  (w_cpu0_data_from_dut),
    .DO     (w_cpu0_data_from_cpu),
    .WE     (w_cpu0_we),
    .SYNC   (w_cpu0_sync)
);


super6502_fpga u_dut (
    .i_sysclk               (clk_100),
    .i_sdrclk               (clk_200),
    .i_tACclk               (clk_200),
    .clk_cpu                (clk_cpu),

    .button_reset           (button_reset),

    .o_cpu0_reset           (w_cpu0_reset),
    .i_cpu0_addr            (w_cpu0_addr),
    .i_cpu0_data_from_cpu   (w_cpu0_data_from_cpu),
    .o_cpu0_data_from_dut   (w_cpu0_data_from_dut),
    .o_cpu0_rdy             (w_cpu0_rdy),
    .o_cpu0_irqb            (w_cpu0_irqb),
    .i_cpu0_rwb             (~w_cpu0_we),
    .i_cpu0_sync            (w_cpu0_sync)
);

initial begin
    button_reset <= '1;
    repeat(10) @(clk_cpu);
    button_reset <= '0;
    repeat(10) @(clk_cpu);
    button_reset <= '1;
    repeat(4000) @(posedge clk_cpu);
    $finish();
end

endmodule