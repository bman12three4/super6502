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

//new idea for timer:
//it can either be oneshot or repeating
//it can either cause an interrupt or not.
//if you want it to do both, add another timer.

logic [15:0] timer_latch, timer_counter;

//control register
// bit 0: Enable interrupts
// bit 1: Enable 1 shot mode

//by default it just starts counting up

logic [7:0] divisor, status, control;


logic [15:0] pulsecount;

//I think this should be negedge so that writes go through
always @(negedge clk) begin
    if (reset) begin
        timer_counter <= '0;
        pulsecount <= '0;
        timer_latch <= '0;
        divisor <= '0;
        status <= '0;
        control <= '0;
        irq <= '1;
    end else begin

        if (pulsecount[15:8] == divisor) begin
            timer_counter <= timer_counter + 16'b1;
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
            o_data = timer_counter[7:0];
        end

        3'h1: begin
            o_data = timer_counter[15:8];
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
