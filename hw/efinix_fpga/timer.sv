module timer
(
    input clk,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,
    input [2:0] addr,
    output logic irq
);

logic [16:0] tick_counter_reg, irq_counter_reg;
logic [7:0] divisor, status, control;

//  --------------------------------
//  |   0   |  Tick Counter Low    |
//  --------------------------------
//  |   1   |  Tick Counter High   |
//  --------------------------------
//  |   2   |   IRQ Counter Low    |
//  --------------------------------
//  |   3   |   IRQ Counter High   |
//  --------------------------------
//  |   4   |       Reserved       |
//  --------------------------------
//  |   5   |       Divisor        |
//  --------------------------------
//  |   6   |       Status         |
//  --------------------------------
//  |   7   |       Control        |
//  --------------------------------


//   Tick counter register
// The tick counter register is read only. It starts at 0 upon
// reset and increments continuously according to the divsor.

//   IRQ Counter Register
// The IRQ counter register is writable, which is how you set the desired
// time to count down. Writing to the high register does nothing, while
// writing to the low register will begin the countdown. Based on the control
// register, the register will reset itself when it reaches 0 and triggers an
// interrupt. See the control register for more details.

//   Divisor
// The divisor register controls how fast the timer counts up. The divisor is
// bit shifted left by 8 (multiplied by 256), and that is the number of pulses
// it takes to increment the counters.

//   Status
// 6:0 Reserved
// 7: Interrupt.   Set if an interrupt has occured. Write to clear.

//   Control
// 0: Oneshot.     Set if you only want the timer to run once.
// 7:1 Reserved     


// What features do we want for the timer?
// 1. Tracking elapsed time
// 2. Trigger interrupts (repeated or elapsed)

// General Idea
// Takes in the input clock and can set a divisor
// of a power of 2. Every time that many clock pulses
// occur, it will increment the counter. The counter
// can then be read at any point.
// The interrupts will have a difference counter which
// counts down. When the counter reaches 0, it will trigger
// an interrupt and optionally reset the counter to start
// again.

logic [15:0] pulsecount;

logic [15:0] tickcount;

//I think this should be negedge so that writes go through
always @(negedge clk) begin
    if (reset) begin
        tickcount <= '0;
        pulsecount <= '0;
        tick_counter_reg <= '0;
        irq_counter_reg <= '0;
        divisor <= '0;
        status <= '0;
        control <= '0;
    end else begin

        if (pulsecount[15:8] == divisor) begin
            tickcount <= tickcount + 16'b1;
            pulsecount <= '0;
        end else begin
            pulsecount <= pulsecount + 16'b1;
        end

        if (cs & ~rwb) begin
            case (addr)
                3'h5: begin
                    divisor <= i_data;
                end 
            endcase
        end

    end
end

always_comb begin
    o_data = '0;

    unique case (addr)
        3'h0: begin
            o_data = tickcount[7:0];
        end

        3'h1: begin
            o_data = tickcount[15:8];
        end

        3'h2: begin

        end

        3'h3: begin

        end

        3'h4: begin

        end

        3'h5: begin

        end

        3'h6: begin

        end

        3'h7: begin

        end

    endcase
end



endmodule
