
module super6502(
    input                   clk,
    input   logic           rst,
    
    input   logic [15:0]    cpu_addr,
    inout   logic [7:0]     cpu_data,
    
    input   logic           cpu_vpb,
    input   logic           cpu_mlb,
    input   logic           cpu_rwb,
    input   logic           cpu_sync,
    
    output  logic           cpu_led,
    output  logic           cpu_resb,
    output  logic           cpu_rdy,
    output  logic           cpu_sob,
    output  logic           cpu_irqb,
    output  logic           cpu_phi2,
    output  logic           cpu_be,
    output  logic           cpu_nmib
  );
  

logic [7:0] cpu_data_in;
assign cpu_data_in = cpu_data;

logic [7:0] cpu_data_out;
assign cpu_data = cpu_rwb ? cpu_data_out : 'z;




logic [7:0] rom_data_out;
logic [7:0] ram_data_out;

logic ram_cs;
logic rom_cs;


addr_decode decode(
    .addr(cpu_addr),
    .ram_cs(ram_cs),
    .rom_cs(rom_cs)
);

 
logic [2:0] clk_count;
always_ff @(posedge clk) begin
    clk_count <= clk_count + 3'b1;
    if (clk_count == 3'h4) begin
        clk_count <= '0;
        cpu_phi2 <= ~cpu_phi2;
    end
end



always_comb begin
    if (ram_cs)
        cpu_data_out = ram_data_out;
    else if (rom_cs)
        cpu_data_out = rom_data_out;
    else
        cpu_data_out = 'x;
end




ram main_memory(
    .address(cpu_addr[14:0]),
    .clock(clk),
    .data(cpu_data_in),
    .wren(~cpu_rwb & ram_cs),
    .q(ram_data_out)
);


rom boot_rom(
    .address(cpu_addr[14:0]),
    .clock(clk),
    .q(rom_data_out)
);
 
 
endmodule
 