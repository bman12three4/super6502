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
    
    output logic irq,
    output logic [7:0] data_out
);

//Temporary!
assign irq = ~RXD;

//Handle reading and writing registers

logic [7:0] tx_buf;
logic [7:0] rx_buf;
logic [7:0] status;

logic tx_flag;

logic tx_flag_set;
logic tx_flag_clear;

assign status[0] = tx_flag | tx_flag_clear;

always_ff @(posedge clk) begin
    if (rst) begin
        tx_flag_set <= '0;
        tx_buf <= '0;
        rx_buf <= '0;
        status[7:1] <= '0;
    end

    if (cs) begin
        if (~rw) begin
            if (addr == 0)
                tx_buf <= data_in;
        end else begin
            if (addr == 0)
                data_out <= rx_buf;
            if (addr == 1)
                data_out <= status;
        end
    end

    if (~rw & cs && addr == 0)
        tx_flag_set <= '1;
    else
        tx_flag_set <= '0;
end

// tx state controller
typedef enum bit [2:0] {START, DATA, PARITY, STOP, IDLE} macro_t;
struct packed {
    macro_t macro;
    logic [3:0] count;
} tx_state, tx_next_state, rx_state, rx_next_state;
localparam logic [3:0] maxcount = 4'h7;

// baud rate: 9600
localparam baud = 9600;
localparam count = (50000000/baud)-1;
logic [14:0] clkdiv;

always_ff @(posedge clk_50) begin
    if (rst) begin
        clkdiv <= 0;
        tx_state.macro <= IDLE;
        tx_state.count <= 3'b0;
        tx_flag <= '0;
    end else begin
        if (tx_flag_set)
            tx_flag <= '1;
        else if (tx_flag_clear)
            tx_flag <= '0;

        if (clkdiv == count) begin
            clkdiv <= 0;
            tx_state <= tx_next_state;
        end else begin
            clkdiv <= clkdiv + 15'b1;
        end
    end
end

always_comb begin
    tx_next_state = tx_state;

    unique case (tx_state.macro)
        START: begin
            tx_next_state.macro = DATA;
            tx_next_state.count = 3'b0;
        end
        DATA: begin
            if (tx_state.count == maxcount) begin
                tx_next_state.macro = STOP;    // or PARITY
                tx_next_state.count = 3'b0;
            end else begin
                tx_next_state.count = tx_state.count + 3'b1;
                tx_next_state.macro = DATA;
            end
        end
        PARITY: begin
        end
        STOP: begin
            tx_next_state.macro = IDLE;
            tx_next_state.count = '0;
        end
        IDLE: begin
            if (tx_flag)
                tx_next_state.macro = START;
            else
                tx_next_state.macro = IDLE;
        end
    
        default:;
    endcase
end

always_comb begin
    TXD = '1;
    tx_flag_clear = '0;

    unique case (tx_state.macro)
        START: begin
            TXD = '0;
        end
        DATA: begin
            TXD = tx_buf[tx_state.count];
        end 
        PARITY: begin

        end
        STOP: begin
            tx_flag_clear = '1;
            TXD = '1;
        end
        IDLE: begin
            TXD = '1;
        end

        default:;
    endcase
end

endmodule
