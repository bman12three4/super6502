/*
 *	This is based off of the 74LS610, but is not identical.
	Some of the inputs are flipped so that they are all active high,
	and some outputs are reordered.
	Notably, when MM is low, MA is present on MO0-MO4, not 8 to 11.
 */

module memory_mapper(
	input clk,
	input rst,

	input rw,
	input cs,

	input MM_cs,

	input [3:0] RS,

	input [3:0] MA,

	input logic [11:0] data_in,
	output logic [11:0] data_out,

	output logic [11:0] MO
);

logic [11:0] RAM [16];

logic MM;


always_ff @(posedge clk) begin
    if (rst) begin
        MM <= '0;
    end else begin
        if (MM_cs & ~rw) begin					// can't read MM but do you really need too?
            MM = |data_in;
        end

        if (cs & ~rw) begin					// write to registers
            RAM[RS] <= data_in;
        end else if (cs & rw) begin			// read registers
            data_out <= RAM[RS];
        end
    end
end


always_comb begin
	if (MM) begin						// normal mode
		MO = RAM[MA];
	end else begin						// passthrough mode
		MO = {8'b0, MA};
	end
end

endmodule

