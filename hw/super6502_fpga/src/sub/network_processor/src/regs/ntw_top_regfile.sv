// Generated by PeakRDL-regblock - A free and open-source SystemVerilog generator
//  https://github.com/SystemRDL/PeakRDL-regblock

module ntw_top_regfile (
        input wire clk,
        input wire rst,

        output logic s_axil_awready,
        input wire s_axil_awvalid,
        input wire [9:0] s_axil_awaddr,
        input wire [2:0] s_axil_awprot,
        output logic s_axil_wready,
        input wire s_axil_wvalid,
        input wire [31:0] s_axil_wdata,
        input wire [3:0]s_axil_wstrb,
        input wire s_axil_bready,
        output logic s_axil_bvalid,
        output logic [1:0] s_axil_bresp,
        output logic s_axil_arready,
        input wire s_axil_arvalid,
        input wire [9:0] s_axil_araddr,
        input wire [2:0] s_axil_arprot,
        input wire s_axil_rready,
        output logic s_axil_rvalid,
        output logic [31:0] s_axil_rdata,
        output logic [1:0] s_axil_rresp,

        input ntw_top_regfile_pkg::ntw_top_regfile__in_t hwif_in,
        output ntw_top_regfile_pkg::ntw_top_regfile__out_t hwif_out
    );

    //--------------------------------------------------------------------------
    // CPU Bus interface logic
    //--------------------------------------------------------------------------
    logic cpuif_req;
    logic cpuif_req_is_wr;
    logic [9:0] cpuif_addr;
    logic [31:0] cpuif_wr_data;
    logic [31:0] cpuif_wr_biten;
    logic cpuif_req_stall_wr;
    logic cpuif_req_stall_rd;

    logic cpuif_rd_ack;
    logic cpuif_rd_err;
    logic [31:0] cpuif_rd_data;

    logic cpuif_wr_ack;
    logic cpuif_wr_err;

    // Max Outstanding Transactions: 2
    logic [1:0] axil_n_in_flight;
    logic axil_prev_was_rd;
    logic axil_arvalid;
    logic [9:0] axil_araddr;
    logic axil_ar_accept;
    logic axil_awvalid;
    logic [9:0] axil_awaddr;
    logic axil_wvalid;
    logic [31:0] axil_wdata;
    logic [3:0] axil_wstrb;
    logic axil_aw_accept;
    logic axil_resp_acked;

    // Transaction request acceptance
    always_ff @(posedge clk) begin
        if(rst) begin
            axil_prev_was_rd <= '0;
            axil_arvalid <= '0;
            axil_araddr <= '0;
            axil_awvalid <= '0;
            axil_awaddr <= '0;
            axil_wvalid <= '0;
            axil_wdata <= '0;
            axil_wstrb <= '0;
            axil_n_in_flight <= '0;
        end else begin
            // AR* acceptance register
            if(axil_ar_accept) begin
                axil_prev_was_rd <= '1;
                axil_arvalid <= '0;
            end
            if(s_axil_arvalid && s_axil_arready) begin
                axil_arvalid <= '1;
                axil_araddr <= s_axil_araddr;
            end

            // AW* & W* acceptance registers
            if(axil_aw_accept) begin
                axil_prev_was_rd <= '0;
                axil_awvalid <= '0;
                axil_wvalid <= '0;
            end
            if(s_axil_awvalid && s_axil_awready) begin
                axil_awvalid <= '1;
                axil_awaddr <= s_axil_awaddr;
            end
            if(s_axil_wvalid && s_axil_wready) begin
                axil_wvalid <= '1;
                axil_wdata <= s_axil_wdata;
                axil_wstrb <= s_axil_wstrb;
            end

            // Keep track of in-flight transactions
            if((axil_ar_accept || axil_aw_accept) && !axil_resp_acked) begin
                axil_n_in_flight <= axil_n_in_flight + 1'b1;
            end else if(!(axil_ar_accept || axil_aw_accept) && axil_resp_acked) begin
                axil_n_in_flight <= axil_n_in_flight - 1'b1;
            end
        end
    end

    always_comb begin
        s_axil_arready = (!axil_arvalid || axil_ar_accept);
        s_axil_awready = (!axil_awvalid || axil_aw_accept);
        s_axil_wready = (!axil_wvalid || axil_aw_accept);
    end

    // Request dispatch
    always_comb begin
        cpuif_wr_data = axil_wdata;
        for(int i=0; i<4; i++) begin
            cpuif_wr_biten[i*8 +: 8] = {8{axil_wstrb[i]}};
        end
        cpuif_req = '0;
        cpuif_req_is_wr = '0;
        cpuif_addr = '0;
        axil_ar_accept = '0;
        axil_aw_accept = '0;

        if(axil_n_in_flight < 2'd2) begin
            // Can safely issue more transactions without overwhelming response buffer
            if(axil_arvalid && !axil_prev_was_rd) begin
                cpuif_req = '1;
                cpuif_req_is_wr = '0;
                cpuif_addr = {axil_araddr[9:2], 2'b0};
                if(!cpuif_req_stall_rd) axil_ar_accept = '1;
            end else if(axil_awvalid && axil_wvalid) begin
                cpuif_req = '1;
                cpuif_req_is_wr = '1;
                cpuif_addr = {axil_awaddr[9:2], 2'b0};
                if(!cpuif_req_stall_wr) axil_aw_accept = '1;
            end else if(axil_arvalid) begin
                cpuif_req = '1;
                cpuif_req_is_wr = '0;
                cpuif_addr = {axil_araddr[9:2], 2'b0};
                if(!cpuif_req_stall_rd) axil_ar_accept = '1;
            end
        end
    end


    // AXI4-Lite Response Logic
    struct {
        logic is_wr;
        logic err;
        logic [31:0] rdata;
    } axil_resp_buffer[2];

    logic [1:0] axil_resp_wptr;
    logic [1:0] axil_resp_rptr;

    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i=0; i<2; i++) begin
                axil_resp_buffer[i].is_wr <= '0;
                axil_resp_buffer[i].err <= '0;
                axil_resp_buffer[i].rdata <= '0;
            end
            axil_resp_wptr <= '0;
            axil_resp_rptr <= '0;
        end else begin
            // Store responses in buffer until AXI response channel accepts them
            if(cpuif_rd_ack || cpuif_wr_ack) begin
                if(cpuif_rd_ack) begin
                    axil_resp_buffer[axil_resp_wptr[0:0]].is_wr <= '0;
                    axil_resp_buffer[axil_resp_wptr[0:0]].err <= cpuif_rd_err;
                    axil_resp_buffer[axil_resp_wptr[0:0]].rdata <= cpuif_rd_data;

                end else if(cpuif_wr_ack) begin
                    axil_resp_buffer[axil_resp_wptr[0:0]].is_wr <= '1;
                    axil_resp_buffer[axil_resp_wptr[0:0]].err <= cpuif_wr_err;
                end
                axil_resp_wptr <= axil_resp_wptr + 1'b1;
            end

            // Advance read pointer when acknowledged
            if(axil_resp_acked) begin
                axil_resp_rptr <= axil_resp_rptr + 1'b1;
            end
        end
    end

    always_comb begin
        axil_resp_acked = '0;
        s_axil_bvalid = '0;
        s_axil_rvalid = '0;
        if(axil_resp_rptr != axil_resp_wptr) begin
            if(axil_resp_buffer[axil_resp_rptr[0:0]].is_wr) begin
                s_axil_bvalid = '1;
                if(s_axil_bready) axil_resp_acked = '1;
            end else begin
                s_axil_rvalid = '1;
                if(s_axil_rready) axil_resp_acked = '1;
            end
        end

        s_axil_rdata = axil_resp_buffer[axil_resp_rptr[0:0]].rdata;
        if(axil_resp_buffer[axil_resp_rptr[0:0]].err) begin
            s_axil_bresp = 2'b10;
            s_axil_rresp = 2'b10;
        end else begin
            s_axil_bresp = 2'b00;
            s_axil_rresp = 2'b00;
        end
    end

    logic cpuif_req_masked;
    logic external_req;
    logic external_pending;
    logic external_wr_ack;
    logic external_rd_ack;
    always_ff @(posedge clk) begin
        if(rst) begin
            external_pending <= '0;
        end else begin
            if(external_req & ~external_wr_ack & ~external_rd_ack) external_pending <= '1;
            else if(external_wr_ack | external_rd_ack) external_pending <= '0;
            assert(!external_wr_ack || (external_pending | external_req))
                else $error("An external wr_ack strobe was asserted when no external request was active");
            assert(!external_rd_ack || (external_pending | external_req))
                else $error("An external rd_ack strobe was asserted when no external request was active");
        end
    end

    // Read & write latencies are balanced. Stalls not required
    // except if external
    assign cpuif_req_stall_rd = external_pending;
    assign cpuif_req_stall_wr = external_pending;
    assign cpuif_req_masked = cpuif_req
                            & !(!cpuif_req_is_wr & cpuif_req_stall_rd)
                            & !(cpuif_req_is_wr & cpuif_req_stall_wr);

    //--------------------------------------------------------------------------
    // Address Decode
    //--------------------------------------------------------------------------
    typedef struct {
        logic mac;
        logic tcp_top;
    } decoded_reg_strb_t;
    decoded_reg_strb_t decoded_reg_strb;
    logic decoded_strb_is_external;

    logic [9:0] decoded_addr;

    logic decoded_req;
    logic decoded_req_is_wr;
    logic [31:0] decoded_wr_data;
    logic [31:0] decoded_wr_biten;

    always_comb begin
        automatic logic is_external;
        is_external = '0;
        decoded_reg_strb.mac = cpuif_req_masked & (cpuif_addr >= 10'h0) & (cpuif_addr <= 10'h0 + 10'h7);
        is_external |= cpuif_req_masked & (cpuif_addr >= 10'h0) & (cpuif_addr <= 10'h0 + 10'h7);
        decoded_reg_strb.tcp_top = cpuif_req_masked & (cpuif_addr >= 10'h200) & (cpuif_addr <= 10'h200 + 10'hff);
        is_external |= cpuif_req_masked & (cpuif_addr >= 10'h200) & (cpuif_addr <= 10'h200 + 10'hff);
        decoded_strb_is_external = is_external;
        external_req = is_external;
    end

    // Pass down signals to next stage
    assign decoded_addr = cpuif_addr;

    assign decoded_req = cpuif_req_masked;
    assign decoded_req_is_wr = cpuif_req_is_wr;
    assign decoded_wr_data = cpuif_wr_data;
    assign decoded_wr_biten = cpuif_wr_biten;

    //--------------------------------------------------------------------------
    // Field logic
    //--------------------------------------------------------------------------
    

    

    assign hwif_out.mac.req = decoded_reg_strb.mac;
    assign hwif_out.mac.addr = decoded_addr[3:0];
    assign hwif_out.mac.req_is_wr = decoded_req_is_wr;
    assign hwif_out.mac.wr_data = decoded_wr_data;
    assign hwif_out.mac.wr_biten = decoded_wr_biten;
    assign hwif_out.tcp_top.req = decoded_reg_strb.tcp_top;
    assign hwif_out.tcp_top.addr = decoded_addr[8:0];
    assign hwif_out.tcp_top.req_is_wr = decoded_req_is_wr;
    assign hwif_out.tcp_top.wr_data = decoded_wr_data;
    assign hwif_out.tcp_top.wr_biten = decoded_wr_biten;

    //--------------------------------------------------------------------------
    // Write response
    //--------------------------------------------------------------------------
    always_comb begin
        automatic logic wr_ack;
        wr_ack = '0;
        wr_ack |= hwif_in.mac.wr_ack;
        wr_ack |= hwif_in.tcp_top.wr_ack;
        external_wr_ack = wr_ack;
    end
    assign cpuif_wr_ack = external_wr_ack | (decoded_req & decoded_req_is_wr & ~decoded_strb_is_external);
    // Writes are always granted with no error response
    assign cpuif_wr_err = '0;

    //--------------------------------------------------------------------------
    // Readback
    //--------------------------------------------------------------------------
    logic readback_external_rd_ack_c;
    always_comb begin
        automatic logic rd_ack;
        rd_ack = '0;
        rd_ack |= hwif_in.mac.rd_ack;
        rd_ack |= hwif_in.tcp_top.rd_ack;
        readback_external_rd_ack_c = rd_ack;
    end

    logic readback_external_rd_ack;

    assign readback_external_rd_ack = readback_external_rd_ack_c;

    logic readback_err;
    logic readback_done;
    logic [31:0] readback_data;

    // Assign readback values to a flattened array
    logic [31:0] readback_array[2];
    assign readback_array[0] = hwif_in.mac.rd_ack ? hwif_in.mac.rd_data : '0;
    assign readback_array[1] = hwif_in.tcp_top.rd_ack ? hwif_in.tcp_top.rd_data : '0;

    // Reduce the array
    always_comb begin
        automatic logic [31:0] readback_data_var;
        readback_done = decoded_req & ~decoded_req_is_wr & ~decoded_strb_is_external;
        readback_err = '0;
        readback_data_var = '0;
        for(int i=0; i<2; i++) readback_data_var |= readback_array[i];
        readback_data = readback_data_var;
    end

    assign external_rd_ack = readback_external_rd_ack;
    assign cpuif_rd_ack = readback_done | readback_external_rd_ack;
    assign cpuif_rd_data = readback_data;
    assign cpuif_rd_err = readback_err;
endmodule
