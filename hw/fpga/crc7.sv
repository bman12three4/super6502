module crc7 #(parameter POLYNOMIAL = 8'h89)
(
    input clk,
    input rst,

    input load,
    input [39:0] data_in,

    output logic [6:0] crc_out,
    output logic valid
);

logic [46:0] data;
logic [46:0] next_data;
logic [46:0] polyshift;

typedef enum bit [1:0] {IDLE, WORKING, VALID} macro_t;
struct packed {
    macro_t macro;
    logic [5:0] count;
} state, next_state;

always_ff @(posedge clk) begin
    if (rst) begin
        polyshift <= {POLYNOMIAL, 39'b0};    //start all the way at the left
        data <= '0;
        state.macro <= IDLE;
        state.count <= '0;
    end else begin
        if (load) begin
            data <= {data_in, 7'b0};
        end else begin
            data <= next_data;
        end
        state <= next_state;

        if (state.macro == WORKING) begin
            polyshift <= polyshift >> 1;
        end

        if (state.macro == VALID) begin
            polyshift <= {POLYNOMIAL, 39'b0};
        end
    end
end

always_comb begin
    next_state = state;

    case (state.macro)
        IDLE: begin
            if (load) begin
                next_state.macro = WORKING;
                next_state.count = '0;
            end
        end

        WORKING: begin
            if (state.count < 39) begin
                next_state.count = state.count + 6'b1;
            end else begin
                next_state.macro = VALID;
                next_state.count = '0;
            end
        end

        VALID: begin            // Same as IDLE, but IDLE is just for reset.
            if (load) begin
                next_state.macro = WORKING;
                next_state.count = '0;
            end
        end

        default:;
    endcase
end

always_comb begin
    valid = 0;
    next_data = '0;
    crc_out = '0;

    case (state.macro)
        IDLE: begin
            valid = 0;
        end

        WORKING: begin
            if (data[6'd46 - state.count]) begin
                next_data = data ^ polyshift;
            end else begin
                next_data = data;
            end
        end

        VALID: begin
            valid =  ~load;
            crc_out = data[6:0];
        end

        default:;
    endcase
end

endmodule
