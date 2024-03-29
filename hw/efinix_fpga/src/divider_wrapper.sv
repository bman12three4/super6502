module divider_wrapper(
    input clk,
    input divclk,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,
    input [2:0] addr
);

logic [15:0] numer, denom;
logic [15:0] quotient, remain;

logic [15:0] r_quotient, r_remain;

logic clken, rfd;

assign clken = '1;


divider u_divider(
.numer ( numer ),
.denom ( denom ),
.clken ( clken ),
.clk ( divclk ),
.reset ( reset ),
.quotient ( quotient ),
.remain ( remain ),
.rfd ( rfd )
);


always_ff @(negedge clk) begin
    if (reset) begin
        numer <= '0;
        denom <= '0;
    end


    if (cs & ~rwb) begin
        case (addr)
            3'h0: begin
                numer[7:0] <= i_data;
            end

            3'h1: begin
                numer[15:8] <= i_data;
            end

            3'h2: begin
                denom[7:0] <= i_data;
            end

            3'h3: begin
                denom[15:8] <= i_data;
            end
        endcase
    end
end

always_ff @(posedge divclk) begin
    if (rfd) begin
        r_quotient <= quotient;
        r_remain <= remain;
    end
end

always_comb begin

    case (addr)
        3'h4: begin
            o_data = r_quotient[7:0];
        end

        3'h5: begin
            o_data = r_quotient[15:8];
        end

        3'h6: begin
            o_data = r_remain[7:0];
        end

        3'h7: begin
            o_data = r_remain[15:8];
        end

    endcase

end

endmodule