module sd_controller_wrapper #(
    parameter        NUMIO=4,
    parameter        BASE_ADDRESS=32'h00000000
)(
    input   wire                i_clk,
    input   wire                i_reset,

    input   wire                S_AXIL_AWVALID,
    output  wire                S_AXIL_AWREADY,
    input   wire    [31:0]      S_AXIL_AWADDR,

    input   wire                S_AXIL_WVALID,
    output  wire                S_AXIL_WREADY,
    input   wire    [31:0]      S_AXIL_WDATA,
    input   wire    [3:0]       S_AXIL_WSTRB,

    output  wire                S_AXIL_BVALID,
    input   wire                S_AXIL_BREADY,
    output  wire    [1:0]       S_AXIL_BRESP,

    input   wire                S_AXIL_ARVALID,
    output  wire                S_AXIL_ARREADY,
    input   wire    [31:0]      S_AXIL_ARADDR,

    output  wire                S_AXIL_RVALID,
    input   wire                S_AXIL_RREADY,
    output  wire    [31:0]      S_AXIL_RDATA,
    output  wire    [1:0]       S_AXIL_RRESP,

    output  wire                M_AXI_AWVALID,
    input   wire                M_AXI_AWREADY,
    output  wire    [31:0]      M_AXI_AWADDR,

    output  wire                M_AXI_WVALID,
    input   wire                M_AXI_WREADY,
    output  wire    [31:0]      M_AXI_WDATA,
    output  wire    [3:0]       M_AXI_WSTRB,
    output  wire                M_AXI_WLAST,

    input   wire                M_AXI_BVALID,
    output  wire                M_AXI_BREADY,
    input   wire    [1:0]       M_AXI_BRESP,

    output  wire                M_AXI_ARVALID,
    input   wire                M_AXI_ARREADY,
    output  wire    [31:0]      M_AXI_ARADDR,


    input   wire                M_AXI_RVALID,
    output  wire                M_AXI_RREADY,
    input   wire    [31:0]      M_AXI_RDATA,
    input   wire    [1:0]       M_AXI_RRESP,

    output	wire                o_ck,
    output  wire                io_cmd_tristate,
    output  wire                o_cmd,
    input   wire                i_cmd,

    output  wire    [NUMIO-1:0] io_dat_tristate,
    output  wire    [NUMIO-1:0] o_dat,
    input   wire    [NUMIO-1:0] i_dat,

    input   wire                i_card_detect,
    output  wire                o_hwreset_n,
    output  wire                o_1p8v,
    output  wire                o_int
);

logic                shadow_AXI_AWVALID;
logic                shadow_AXI_AWREADY;
logic    [31:0]      shadow_AXI_AWADDR;
logic                shadow_AXI_WVALID;
logic                shadow_AXI_WREADY;
logic    [31:0]      shadow_AXI_WDATA;
logic    [3:0]       shadow_AXI_WSTRB;
logic                shadow_AXI_BVALID;
logic                shadow_AXI_BREADY;
logic    [1:0]       shadow_AXI_BRESP;
logic                shadow_AXI_ARVALID;
logic                shadow_AXI_ARREADY;
logic    [31:0]      shadow_AXI_ARADDR;
logic                shadow_AXI_RVALID;
logic                shadow_AXI_RREADY;
logic    [31:0]      shadow_AXI_RDATA;
logic    [1:0]       shadow_AXI_RRESP;

shadow_regs #(.N(8)) u_shadow_regs (
    .i_clk              (i_clk),
    .i_reset            (i_reset),

    .S_AXIL_AWVALID     (S_AXIL_AWVALID),
    .S_AXIL_AWREADY     (S_AXIL_AWREADY),
    .S_AXIL_AWADDR      (S_AXIL_AWADDR-BASE_ADDRESS),
    .S_AXIL_WVALID      (S_AXIL_WVALID),
    .S_AXIL_WREADY      (S_AXIL_WREADY),
    .S_AXIL_WDATA       (S_AXIL_WDATA),
    .S_AXIL_WSTRB       (S_AXIL_WSTRB),
    .S_AXIL_BVALID      (S_AXIL_BVALID),
    .S_AXIL_BREADY      (S_AXIL_BREADY),
    .S_AXIL_BRESP       (S_AXIL_BRESP),
    .S_AXIL_ARVALID     (S_AXIL_ARVALID),
    .S_AXIL_ARREADY     (S_AXIL_ARREADY),
    .S_AXIL_ARADDR      (S_AXIL_ARADDR-BASE_ADDRESS),
    .S_AXIL_RVALID      (S_AXIL_RVALID),
    .S_AXIL_RREADY      (S_AXIL_RREADY),
    .S_AXIL_RDATA       (S_AXIL_RDATA),
    .S_AXIL_RRESP       (S_AXIL_RRESP),

    .M_AXI_AWVALID      (shadow_AXI_AWVALID),
    .M_AXI_AWREADY      (shadow_AXI_AWREADY),
    .M_AXI_AWADDR       (shadow_AXI_AWADDR),
    .M_AXI_WVALID       (shadow_AXI_WVALID),
    .M_AXI_WREADY       (shadow_AXI_WREADY),
    .M_AXI_WDATA        (shadow_AXI_WDATA),
    .M_AXI_WSTRB        (shadow_AXI_WSTRB),
    .M_AXI_BVALID       (shadow_AXI_BVALID),
    .M_AXI_BREADY       (shadow_AXI_BREADY),
    .M_AXI_BRESP        (shadow_AXI_BRESP),
    .M_AXI_ARVALID      (shadow_AXI_ARVALID),
    .M_AXI_ARREADY      (shadow_AXI_ARREADY),
    .M_AXI_ARADDR       (shadow_AXI_ARADDR),
    .M_AXI_RVALID       (shadow_AXI_RVALID),
    .M_AXI_RREADY       (shadow_AXI_RREADY),
    .M_AXI_RDATA        (shadow_AXI_RDATA),
    .M_AXI_RRESP        (shadow_AXI_RRESP)
);


sdio_top #(
    .NUMIO              (NUMIO),    // board as it stands is in 1 bit mode
    .ADDRESS_WIDTH      (32),
    .DW                 (32),
    .OPT_DMA            (1),
    .OPT_EMMC           (0),
    .OPT_SERDES         (0),
    .OPT_DDR            (0),
    .OPT_1P8V           (0)     // doesn't really matter but we don't need it
) u_sdio_top (
    .i_clk              (i_clk),
    .i_reset            (i_reset),
    .i_hsclk            ('0),   // Not using serdes

    .S_AXIL_AWVALID     (shadow_AXI_AWVALID),
    .S_AXIL_AWREADY     (shadow_AXI_AWREADY),
    .S_AXIL_AWADDR      (shadow_AXI_AWADDR),
    .S_AXIL_AWPROT      (),
    .S_AXIL_WVALID      (shadow_AXI_WVALID),
    .S_AXIL_WREADY      (shadow_AXI_WREADY),
    .S_AXIL_WDATA       (shadow_AXI_WDATA),
    .S_AXIL_WSTRB       (shadow_AXI_WSTRB),
    .S_AXIL_BVALID      (shadow_AXI_BVALID),
    .S_AXIL_BREADY      (shadow_AXI_BREADY),
    .S_AXIL_BRESP       (shadow_AXI_BRESP),
    .S_AXIL_ARVALID     (shadow_AXI_ARVALID),
    .S_AXIL_ARREADY     (shadow_AXI_ARREADY),
    .S_AXIL_ARADDR      (shadow_AXI_ARADDR),
    .S_AXIL_ARPROT      (),
    .S_AXIL_RVALID      (shadow_AXI_RVALID),
    .S_AXIL_RREADY      (shadow_AXI_RREADY),
    .S_AXIL_RDATA       (shadow_AXI_RDATA),
    .S_AXIL_RRESP       (shadow_AXI_RRESP),

    .M_AXI_AWVALID      (M_AXI_AWVALID),
    .M_AXI_AWREADY      (M_AXI_AWREADY),
    .M_AXI_AWADDR       (M_AXI_AWADDR),
    .M_AXI_AWPROT       (),
    .M_AXI_WVALID       (M_AXI_WVALID),
    .M_AXI_WREADY       (M_AXI_WREADY),
    .M_AXI_WDATA        (M_AXI_WDATA),
    .M_AXI_WSTRB        (M_AXI_WSTRB),
    .M_AXI_BVALID       (M_AXI_BVALID),
    .M_AXI_BREADY       (M_AXI_BREADY),
    .M_AXI_BRESP        (M_AXI_BRESP),
    .M_AXI_ARVALID      (M_AXI_ARVALID),
    .M_AXI_ARREADY      (M_AXI_ARREADY),
    .M_AXI_ARADDR       (M_AXI_ARADDR),
    .M_AXI_ARPROT       (),
    .M_AXI_RVALID       (M_AXI_RVALID),
    .M_AXI_RREADY       (M_AXI_RREADY),
    .M_AXI_RDATA        (M_AXI_RDATA),
    .M_AXI_RRESP        (M_AXI_RRESP),

    .i_dat              (i_dat),
    .o_dat              (o_dat),
    .io_dat_tristate    (io_dat_tristate),
    .i_cmd              (i_cmd),
    .o_cmd              (o_cmd),
    .io_cmd_tristate    (io_cmd_tristate),
    .o_ck               (o_ck),
    .i_ds               ('0),   //emmc, don't care
    .i_card_detect      (i_card_detect),
    .o_int              (o_int)
);

endmodule