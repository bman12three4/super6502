module timer
(
    input clk,
    input reset,
    input [7:0] i_data,
    output logic [7:0] o_data,
    input cs,
    input rwb,
    input [1:0] addr,
    output logic irqb
);

//new idea for timer:
//it can either be oneshot or repeating
//it can either cause an interrupt or not.
//if you want it to do both, add another timer.

/*
Addr	Read	        Write
0	    Counter Low	    Latch Low
1	    Counter High	Latch High
2	    Divisor	        Divisor
3	    Status	        Control
*/

logic [15:0] timer_latch, timer_counter;

//control register
// bit 0: Enable interrupts
// bit 1: Enable 1 shot mode

//writing to latch low starts the timer

logic [7:0] divisor, status, control;

logic count_en;

assign status[0] = count_en;

logic [15:0] pulsecount;

//I think this should be negedge so that writes go through
always @(negedge clk) begin
    if (reset) begin
        count_en = '0;
        timer_counter <= '0;
        pulsecount <= '0;
        timer_latch <= '1;
        divisor <= '0;
        control <= '0;
        irqb <= '1;
    end else begin

        if (count_en) begin
            if (pulsecount[15:8] == divisor) begin
                timer_counter <= timer_counter + 16'b1;
                pulsecount <= '0;
            end else begin
                pulsecount <= pulsecount + 16'b1;
            end
        end

        if (timer_counter == timer_latch) begin
            // if interrupts are enabled
            if (control[0]) begin
                irqb <= '0;
            end

            // if oneshot mode is enabled
            if (control[1]) begin
                count_en <= '0;
            end else begin
                timer_counter <= '0;
            end

        end

        if (cs & rwb) begin
            irqb <= '1;
        end

        if (cs & ~rwb) begin
            case (addr)
                2'h0: begin
                    count_en <= '1;
                    timer_latch[7:0] <= i_data;
                end

                2'h1: begin
                    timer_latch[15:8] <= i_data;
                end

                2'h2: begin
                    divisor <= i_data;
                end

                2'h3: begin
                    control <= i_data;
                end
            endcase
        end

    end
end

always_comb begin
    o_data = '0;

    unique case (addr)
        2'h0: begin
            o_data = timer_counter[7:0];
        end

        2'h1: begin
            o_data = timer_counter[15:8];
        end

        2'h2: begin
            o_data = divisor;
        end

        2'h3: begin
            o_data = status;
        end

    endcase
end



endmodule
