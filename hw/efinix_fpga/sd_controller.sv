module sd_controller(
    input clk,
    input sd_clk,
    input rst,

    input [2:0] addr,
    input [7:0] data,
    input cs,
    input rw,

    input i_sd_cmd,
    output logic o_sd_cmd,

    input i_sd_data,
    output logic o_sd_data,

    output logic [7:0] data_out
);

logic [31:0] arg;
logic [5:0] cmd;

logic [47:0] rxcmd_buf;
logic [31:0] rx_val;

logic [7:0] rxdata_buf [512];
logic [8:0] data_count;

logic [15:0] data_crc;


assign rx_val = rxcmd_buf[39:8];

always_comb begin
    data_out = 'x;

    if (addr < 4'h4) begin
        data_out = rx_val[8 * addr +: 8];
    end else if (addr == 4'h4) begin
        data_out = {data_flag, read_flag};
    end else if (addr == 4'h5) begin
        data_out = rxdata_buf[data_count];
    end
end

logic read_flag, next_read_flag;
logic data_flag, next_data_flag;

typedef enum bit [2:0] {IDLE, LOAD, CRC, TXCMD, RXCMD, TXDATA, RXDATA, RXDCRC} macro_t;
struct packed {
    macro_t macro;
    logic [8:0] count;
    logic [2:0] d_bit_count;
} state, next_state;

always_ff @(posedge clk) begin
    if (rst) begin
        state.macro <= IDLE;
        state.count <= '0;
        state.d_bit_count <= '1;
        read_flag <= '0;
        data_flag <= '0;
        data_count <= '0;
    end else begin
        if (state.macro == TXCMD || state.macro == CRC) begin
            if (sd_clk) begin
                state <= next_state;
            end
        end else if (state.macro == RXCMD || state.macro == RXDATA || state.macro == RXDCRC) begin
            if (~sd_clk) begin
                state <= next_state;
            end
        end else begin
            state <= next_state;
        end
    end

    if (sd_clk) begin
        read_flag <= next_read_flag;
        data_flag <= next_data_flag;
    end

    if (cs & ~rw) begin
        if (addr < 4'h4) begin
            arg[8 * addr +: 8] <= data;
        end else if (addr == 4'h4) begin
            cmd <= data[6:0];
        end
    end

    if (cs & addr == 4'h5 && sd_clk) begin
        data_count <= data_count + 8'b1;
    end

    if (state.macro == RXCMD) begin
        rxcmd_buf[6'd46-state.count] <= i_sd_cmd;   //we probabily missed bit 47
    end

    if (state.macro == RXDATA && ~sd_clk) begin
        rxdata_buf[state.count][state.d_bit_count] <= i_sd_data;
    end

    if (state.macro == RXDCRC && ~sd_clk) begin
        data_crc[4'd15-state.count] <= i_sd_data;
        data_count <= '0;
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
    next_read_flag = read_flag;
    next_data_flag = data_flag;

    case (state.macro)
        IDLE: begin
            if (~i_sd_cmd) begin        // receive data if sd pulls cmd low
                next_state.macro = RXCMD;
            end

            if (~i_sd_data) begin
                next_state.d_bit_count = '1;
                next_state.macro = RXDATA;
            end

            if (addr == 4'h4 & cs & ~rw) begin     // transmit if cpu writes to cmd
                next_state.macro = LOAD;
            end

            if (addr == 4'h4 & cs & rw) begin
                next_read_flag = '0;
            end

            if (addr == 4'h5 & cs) begin
                next_data_flag = '0;
            end
        end

        LOAD: begin
            next_state.macro = CRC;
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
                next_read_flag = '1;
                next_state.macro = IDLE;
                next_state.count = '0;
            end
        end

        RXDATA: begin
            if (state.count < 511 || (state.count == 511 && state.d_bit_count > 0)) begin
                if (state.d_bit_count == 8'h0) begin
                    next_state.count = state.count + 9'b1;
                end
                next_state.d_bit_count = state.d_bit_count - 3'h1;
            end else begin
                next_data_flag = '1;
                next_state.macro = RXDCRC;
                next_state.count = '0;
            end
        end

        RXDCRC: begin
            if (state.count < 16) begin
                next_state.count = state.count + 9'b1;
            end else begin
                next_state.macro = IDLE;
                next_state.count = '0;
            end
        end

        default: begin
                next_state.macro = IDLE;
                next_state.count = '0;
        end
    endcase
end

always_comb begin
    o_sd_cmd = '1;  //default to 1
    o_sd_data = '1;

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

        default:;
    endcase
end

endmodule
