module interrupt_controller
(
    input clk,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,

    output logic irqb_master,

    input irqb0, irqb1, irqb2, irqb3,
    input irqb4, irqb5, irqb6, irqb7
);


//All of the inputs are low level triggered.
logic [7:0] irqbv;
assign irqbv = {irqb0, irqb1, irqb2, irqb3, irqb4, irqb5, irqb6, irqb7};

always @(posedge clk) begin
    o_data <= irqbv;
    irqb_master = &irqbv;

    if (cs & ~rwb) begin
        o_data <= o_data | i_data;
    end
end

endmodule