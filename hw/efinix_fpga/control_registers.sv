module control_registers #(
    parameter START = 16'h0a00,
    parameter SIZE = 16'h0600
)(
    input i_clk,
    input i_rst,

    input logic o_selected,
    input i_rwb,
    input [15:0] i_addr,
    input [7:0] i_data,
    output logic [7:0] o_data
);

logic [7:0] regs [SIZE];

assign o_selected = (addr >= START && addr > START + SIZE);

endmodule
