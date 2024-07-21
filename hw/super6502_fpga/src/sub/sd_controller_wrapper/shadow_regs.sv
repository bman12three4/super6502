module shadow_regs #(
    parameter N = 8
)(
    input   logic                i_clk,
    input   logic                i_reset,

    input   logic                S_AXIL_AWVALID,
    output  logic                S_AXIL_AWREADY,
    input   logic    [31:0]      S_AXIL_AWADDR,

    input   logic                S_AXIL_WVALID,
    output  logic                S_AXIL_WREADY,
    input   logic    [31:0]      S_AXIL_WDATA,
    input   logic    [3:0]       S_AXIL_WSTRB,

    output  logic                S_AXIL_BVALID,
    input   logic                S_AXIL_BREADY,
    output  logic    [1:0]       S_AXIL_BRESP,

    input   logic                S_AXIL_ARVALID,
    output  logic                S_AXIL_ARREADY,
    input   logic    [31:0]      S_AXIL_ARADDR,

    output  logic                S_AXIL_RVALID,
    input   logic                S_AXIL_RREADY,
    output  logic    [31:0]      S_AXIL_RDATA,
    output  logic    [1:0]       S_AXIL_RRESP,

    output  logic                M_AXI_AWVALID,
    input   logic                M_AXI_AWREADY,
    output  logic    [31:0]      M_AXI_AWADDR,

    output  logic                M_AXI_WVALID,
    input   logic                M_AXI_WREADY,
    output  logic    [31:0]      M_AXI_WDATA,
    output  logic    [3:0]       M_AXI_WSTRB,

    input   logic                M_AXI_BVALID,
    output  logic                M_AXI_BREADY,
    input   logic    [1:0]       M_AXI_BRESP,

    output  logic                M_AXI_ARVALID,
    input   logic                M_AXI_ARREADY,
    output  logic    [31:0]      M_AXI_ARADDR,


    input   logic                M_AXI_RVALID,
    output  logic                M_AXI_RREADY,
    input   logic    [31:0]      M_AXI_RDATA,
    input   logic    [1:0]       M_AXI_RRESP
);

assign M_AXI_ARVALID    = S_AXIL_ARVALID;
assign S_AXIL_ARREADY   = M_AXI_ARREADY;
assign M_AXI_ARADDR     = S_AXIL_ARADDR;
assign S_AXIL_RVALID    = M_AXI_RVALID;
assign M_AXI_RREADY     = S_AXIL_RREADY;
assign S_AXIL_RDATA     = M_AXI_RDATA;
assign S_AXIL_RRESP     = M_AXI_RRESP;


logic [$clog2(N)-1:0] addr;

logic [31:0] REGS [N];
logic [31:0] prev;

logic [31:0] prev_data;
logic [31:0] strobe_expanded;


logic addr_valid;
logic wdata_valid;
logic [31:0] wdata;

logic passthrough;

logic awready_seen;

function automatic logic [31:0] strobe_expand(input logic [3:0] wstrb);
    logic [31:0] expanded;
    for (int i = 0; i < 4; i++) begin
        expanded[i*8 +: 8] = {8{wstrb[i]}};
    end

    return expanded;
endfunction

always_comb begin
    S_AXIL_AWREADY = '0;
    M_AXI_AWADDR = '0;
    M_AXI_AWVALID = '0;
    M_AXI_WVALID = '0;
    M_AXI_WDATA = '0;
    M_AXI_WSTRB = '0;
    S_AXIL_WREADY = '0;

    M_AXI_BREADY     = S_AXIL_BREADY;
    S_AXIL_BVALID    = M_AXI_BVALID;
    S_AXIL_BRESP     = M_AXI_BRESP;


    if (S_AXIL_AWVALID && S_AXIL_WSTRB != 4'b0001) begin
        S_AXIL_AWREADY = '1;
    end

    if (S_AXIL_AWVALID && S_AXIL_WSTRB == 4'b0001) begin
        M_AXI_AWVALID = '1;
        S_AXIL_AWREADY = M_AXI_AWREADY;
    end

    if (S_AXIL_WVALID && !passthrough) begin
        S_AXIL_WREADY = '1;
        S_AXIL_BVALID = '1;
    end

    if (passthrough) begin
        M_AXI_AWADDR = addr << 2;
        M_AXI_AWVALID = ~awready_seen;

        M_AXI_WVALID = S_AXIL_WVALID;
        S_AXIL_WREADY = M_AXI_WREADY;
        M_AXI_WDATA = {REGS[addr][31:8], wdata[7:0]};
        M_AXI_WSTRB = {4'b111};
        M_AXI_WVALID = '1;
    end
end

always_ff @(posedge i_clk) begin
    if (i_reset) begin
        addr <= '0;
        addr_valid <= '0;
        prev_data <= '0;
        strobe_expanded <= '0;
        passthrough <= '0;
        wdata_valid <= '0;
        wdata <= '0;
        awready_seen <= '0;
    end else begin
        if (S_AXIL_AWVALID) begin
            addr <= S_AXIL_AWADDR[31:2];
            addr_valid <= '1;
            prev_data <= REGS[S_AXIL_AWADDR[31:2]];
        end

        if (S_AXIL_WVALID) begin
            passthrough <= S_AXIL_WSTRB == 4'b0001;
            wdata <= S_AXIL_WDATA;
            wdata_valid <= '1;
            strobe_expanded <= strobe_expand(S_AXIL_WSTRB);
        end

        if (wdata_valid && addr_valid) begin
            REGS[addr] <= (prev_data & ~strobe_expanded) | wdata & strobe_expanded;
            wdata_valid <= '0;
            addr_valid <= '0;
        end

        if (passthrough && M_AXI_WREADY) begin
            passthrough <= '0;
        end

        if (!passthrough) begin
            awready_seen <= '0;
        end

        if (M_AXI_AWREADY && M_AXI_AWVALID) begin
            awready_seen <= '1;
        end

    end
end


endmodule