module sd_controller(
    input clk,
    input rst,

    input [2:0] addr,
    input [7:0] data,
    input cs,

    input i_sd_cmd,
    output logic o_sd_cmd,

    input i_sd_data,
    output logic o_sd_dat
);

logic [31:0] arg;
logic [5:0] cmd;

logic [47:0] rxcmd_buf;

typedef enum bit [1:0] {IDLE, CRC, TXCMD, RXCMD} macro_t;
struct packed {
    macro_t macro;
    logic [5:0] count;
} state, next_state;

always_ff @(posedge clk) begin
    if (rst) begin
        state.macro <= IDLE;
        state.count <= '0;
    end else begin
        state <= next_state;
    end

    if (state.macro == IDLE) begin
        if (cs) begin
            if (addr < 4'h4) begin
                arg[8 * addr +: 8] <= data;
            end else if (addr == 4'h4) begin
                cmd <= data;
            end
        end
    end else if (state.macro == RXCMD) begin
        rxcmd_buf[6'd46-state.count] <= i_sd_cmd;   //we probabily missed bit 47
    end
end

logic [6:0] crc;
logic load_crc;
logic crc_valid;
logic [39:0] _packet;
assign _packet = {1'b0, 1'b1, cmd, arg};
logic [47:0] packet_crc;
assign packet_crc = {_packet, crc, 1'b1};

crc7 u_crc7(
    .clk(clk),
    .rst(rst),
    .load(load_crc),
    .data_in(_packet),
    .crc_out(crc),
    .valid(crc_valid)
);

always_comb begin
    next_state = state;

    case (state.macro)
        IDLE: begin
            if (~i_sd_cmd) begin        // receive data if sd pulls cmd low
                next_state.macro = RXCMD;
            end

            if (addr == 4'h4 & cs) begin     // transmit if cpu writes to cmd
                next_state.macro = CRC;
            end
        end

        CRC: begin
            next_state.macro = TXCMD;
        end

        TXCMD: begin
            if (state.count < 47) begin
                next_state.count = state.count + 6'b1;
            end else begin
                next_state.macro = IDLE;
                next_state.count = '0;
            end
        end

        RXCMD: begin
            if (state.count < 47) begin
                next_state.count = state.count + 6'b1;
            end else begin
                next_state.macro = IDLE;
                next_state.count = '0;
            end
        end
    endcase
end

always_comb begin
    o_sd_cmd = '1;  //default to 1
    o_sd_dat = '1;

    load_crc = '0;

    case (state.macro)
        IDLE:;

        CRC: begin
            load_crc = '1;
        end

        TXCMD: begin
            o_sd_cmd = packet_crc[6'd47 - state.count];
        end

        RXCMD:;
    endcase
end

endmodule
