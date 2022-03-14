module uart(
    input clk_50,
    input clk,
    input rst,
    
    input cs,
    input rw,
    input [7:0] data_in,
    input [1:0] addr,
    
    input RXD,
    
    output logic TXD,
    
    output logic [7:0] data_out
);

//Handle reading and writing registers

logic [7:0] _data [3:0];

assign data_out = _data[addr];

always_ff @(posedge clk) begin
    if (rst)
        _data = '{default:'0};
    if (~rw & cs)
        _data[addr] <= data_in;
end

// state controller
typedef enum bit [1:0] {START, DATA, PARITY, STOP} macro_t;
struct packed {
    macro_t macro;
    logic [3:0] count;
} state, next_state;
localparam logic [3:0] maxcount = 4'h7;

logic [7:0] testval, next_testval;


// baud rate: 9600
logic [14:0] clkdiv;

always_ff @(posedge clk_50) begin
    if (rst) begin
        clkdiv <= 0;
        state.macro <= STOP;
        state.count <= 3'b0;
        testval <= '0;
    end else begin
        if (clkdiv == 5207) begin
            clkdiv <= 0;
            state <= next_state;
            testval <= next_testval;
        end else begin
            clkdiv <= clkdiv + 15'b1;
        end
    end
end

always_comb begin
    next_state = state;

    unique case (state.macro)
        START: begin
            next_state.macro = DATA;
            next_state.count = 3'b0;
        end
        DATA: begin
            if (state.count == maxcount) begin
                next_state.macro = STOP;    // or PARITY
                next_state.count = 3'b0;
            end else begin
                next_state.count = state.count + 3'b1;
                next_state.macro = DATA;
            end
        end
        PARITY: begin
        end
        STOP: begin
            next_state.macro = START;
            next_state.count = '0;
        end
    endcase
end

always_comb begin
    TXD = '1;
    next_testval = testval;

    unique case (state.macro)
        START: begin
            TXD = '0;
        end
        DATA: begin
            TXD = testval[state.count];
        end 
        PARITY: begin

        end
        STOP: begin
        next_testval = testval + 8'b1;
            TXD = '1;
        end
    endcase
end

endmodule
