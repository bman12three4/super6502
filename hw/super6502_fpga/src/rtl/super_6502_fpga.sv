module super6502_fpga(
    input   logic               i_sysclk,       // Controller Clock (100MHz)
    input   logic               i_sdrclk,       // t_su and t_wd clock (200MHz)
    input   logic               i_tACclk,       // t_ac clock (200MHz)
    input                       clk_cpu,

    input                       button_reset,

    input                       pll_cpu_locked,
    output  logic               pll_cpu_reset,

    input                       i_pll_locked,
    output  logic               o_pll_reset,

    output  logic               o_sdr_CKE,
    output  logic               o_sdr_n_CS,
    output  logic               o_sdr_n_WE,
    output  logic               o_sdr_n_RAS,
    output  logic               o_sdr_n_CAS,
    output  logic   [1:0]       o_sdr_BA,
    output  logic   [12:0]      o_sdr_ADDR,
    input   logic   [15:0]      i_sdr_DATA,
    output  logic   [15:0]      o_sdr_DATA,
    output  logic   [15:0]      o_sdr_DATA_oe,
    output  logic   [1:0]       o_sdr_DQM,


    input           [7:0]       i_cpu0_data_from_cpu,
    input                       i_cpu0_sync,
    input                       i_cpu0_rwb,
    input   logic   [15:0]      i_cpu0_addr,
    output  logic   [7:0]       o_cpu0_data_from_dut,
    output  logic   [7:0]       o_cpu0_data_oe,
    output  logic               o_cpu0_irqb,
    output  logic               o_cpu0_nmib,
    output  logic               o_cpu0_rdy,
    output  logic               o_cpu0_reset,
    output  logic               o_clk_phi2,

    input                       i_sd_cmd,
    output                      o_sd_cmd,
    output                      o_sd_cmd_oe,
    input                       i_sd_dat,
    output                      o_sd_dat,
    output                      o_sd_dat_oe,
    output                      o_sd_clk,
    output                      o_sd_cs
);


localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 32;

assign pll_cpu_reset = '1;
assign o_pll_reset = '1;

assign o_cpu0_nmib = '1;

assign o_clk_phi2 = clk_cpu;

assign o_cpu0_data_oe = {8{i_cpu0_rwb}};

logic vio0_reset;
assign vio0_reset = '1;

logic master_reset;
logic sdram_ready;
logic [3:0] w_sdr_state;

logic pre_reset;

assign pre_reset = button_reset & vio0_reset;

assign sdram_ready = |w_sdr_state;

assign master_reset = pre_reset & sdram_ready;

assign o_sd_cs = '1;


logic                       cpu0_AWVALID;
logic                       cpu0_AWREADY;
logic [ADDR_WIDTH-1:0]      cpu0_AWADDR;
logic                       cpu0_WVALID;
logic                       cpu0_WREADY;
logic [DATA_WIDTH-1:0]      cpu0_WDATA;
logic [DATA_WIDTH/8-1:0]    cpu0_WSTRB;
logic                       cpu0_BVALID;
logic                       cpu0_BREADY;
logic [1:0]                 cpu0_BRESP;
logic                       cpu0_ARVALID;
logic                       cpu0_ARREADY;
logic [ADDR_WIDTH-1:0]      cpu0_ARADDR;
logic                       cpu0_RVALID;
logic                       cpu0_RREADY;
logic [DATA_WIDTH-1:0]      cpu0_RDATA;
logic [1:0]                 cpu0_RRESP;


logic                       ram_awvalid;
logic                       ram_awready;
logic [ADDR_WIDTH-1:0]      ram_awaddr;
logic                       ram_wvalid;
logic                       ram_wready;
logic [DATA_WIDTH-1:0]      ram_wdata;
logic [DATA_WIDTH/8-1:0]    ram_wstrb;
logic                       ram_bvalid;
logic                       ram_bready;
logic [1:0]                 ram_bresp;
logic                       ram_arvalid;
logic                       ram_arready;
logic [ADDR_WIDTH-1:0]      ram_araddr;
logic                       ram_rvalid;
logic                       ram_rready;
logic [DATA_WIDTH-1:0]      ram_rdata;
logic [1:0]                 ram_rresp;

logic                       rom_awvalid;
logic                       rom_awready;
logic [ADDR_WIDTH-1:0]      rom_awaddr;
logic                       rom_wvalid;
logic                       rom_wready;
logic [DATA_WIDTH-1:0]      rom_wdata;
logic [DATA_WIDTH/8-1:0]    rom_wstrb;
logic                       rom_bvalid;
logic                       rom_bready;
logic [1:0]                 rom_bresp;
logic                       rom_arvalid;
logic                       rom_arready;
logic [ADDR_WIDTH-1:0]      rom_araddr;
logic                       rom_rvalid;
logic                       rom_rready;
logic [DATA_WIDTH-1:0]      rom_rdata;
logic [1:0]                 rom_rresp;

logic                       sdram_AWVALID;
logic                       sdram_AWREADY;
logic  [ADDR_WIDTH-1:0]     sdram_AWADDR;
logic                       sdram_WVALID;
logic                       sdram_WREADY;
logic  [DATA_WIDTH-1:0]     sdram_WDATA;
logic  [DATA_WIDTH/8-1:0]   sdram_WSTRB;
logic                       sdram_BVALID;
logic                       sdram_BREADY;
logic  [1:0]                sdram_BRESP;
logic                       sdram_ARVALID;
logic                       sdram_ARREADY;
logic  [ADDR_WIDTH-1:0]     sdram_ARADDR;
logic                       sdram_RVALID;
logic                       sdram_RREADY;
logic  [DATA_WIDTH-1:0]     sdram_RDATA;
logic  [1:0]                sdram_RRESP;


// These are for the control/status registers
logic                       sd_controller_csr_AWVALID;
logic                       sd_controller_csr_AWREADY;
logic  [ADDR_WIDTH-1:0]     sd_controller_csr_AWADDR;
logic                       sd_controller_csr_WVALID;
logic                       sd_controller_csr_WREADY;
logic  [DATA_WIDTH-1:0]     sd_controller_csr_WDATA;
logic  [DATA_WIDTH/8-1:0]   sd_controller_csr_WSTRB;
logic                       sd_controller_csr_BVALID;
logic                       sd_controller_csr_BREADY;
logic  [1:0]                sd_controller_csr_BRESP;
logic                       sd_controller_csr_ARVALID;
logic                       sd_controller_csr_ARREADY;
logic  [ADDR_WIDTH-1:0]     sd_controller_csr_ARADDR;
logic                       sd_controller_csr_RVALID;
logic                       sd_controller_csr_RREADY;
logic  [DATA_WIDTH-1:0]     sd_controller_csr_RDATA;
logic  [1:0]                sd_controller_csr_RRESP;

// these are for the dma master.
logic                       sd_controller_dma_AWVALID;
logic                       sd_controller_dma_AWREADY;
logic  [ADDR_WIDTH-1:0]     sd_controller_dma_AWADDR;
logic                       sd_controller_dma_WVALID;
logic                       sd_controller_dma_WREADY;
logic  [DATA_WIDTH-1:0]     sd_controller_dma_WDATA;
logic  [DATA_WIDTH/8-1:0]   sd_controller_dma_WSTRB;
logic                       sd_controller_dma_BVALID;
logic                       sd_controller_dma_BREADY;
logic  [1:0]                sd_controller_dma_BRESP;
logic                       sd_controller_dma_ARVALID;
logic                       sd_controller_dma_ARREADY;
logic  [ADDR_WIDTH-1:0]     sd_controller_dma_ARADDR;
logic                       sd_controller_dma_RVALID;
logic                       sd_controller_dma_RREADY;
logic  [DATA_WIDTH-1:0]     sd_controller_dma_RDATA;
logic  [1:0]                sd_controller_dma_RRESP;


cpu_wrapper u_cpu_wrapper_0(
    .i_clk_cpu  (clk_cpu),
    .i_clk_100  (i_sysclk),
    .i_rst      (~master_reset),

    .o_cpu_rst  (o_cpu0_reset),
    .o_cpu_rdy  (o_cpu0_rdy),
    .o_cpu_be   (),
    .o_cpu_irqb (o_cpu0_irqb),
    .o_cpu_nmib (),
    .o_cpu_sob  (),

    .i_cpu_rwb  (i_cpu0_rwb),
    .i_cpu_sync (i_cpu0_sync),
    .i_cpu_vpb  ('0),
    .i_cpu_mlb  ('0),

    .i_cpu_addr (i_cpu0_addr),
    .i_cpu_data (i_cpu0_data_from_cpu),
    .o_cpu_data (o_cpu0_data_from_dut),

    .o_AWVALID  (cpu0_AWVALID),
    .i_AWREADY  (cpu0_AWREADY),
    .o_AWADDR   (cpu0_AWADDR),
    .o_WVALID   (cpu0_WVALID),
    .i_WREADY   (cpu0_WREADY),
    .o_WDATA    (cpu0_WDATA),
    .o_WSTRB    (cpu0_WSTRB),
    .i_BVALID   (cpu0_BVALID),
    .o_BREADY   (cpu0_BREADY),
    .i_BRESP    (cpu0_BRESP),
    .o_ARVALID  (cpu0_ARVALID),
    .i_ARREADY  (cpu0_ARREADY),
    .o_ARADDR   (cpu0_ARADDR),
    .i_RVALID   (cpu0_RVALID),
    .o_RREADY   (cpu0_RREADY),
    .i_RDATA    (cpu0_RDATA),
    .i_RRESP    (cpu0_RRESP),

    .i_irq('0),
    .i_nmi('0)
);


axi_crossbar #(
    .N_INITIATORS(2),
    .N_TARGETS(4)
) u_crossbar (
    .clk(i_sysclk),
    .rst(~master_reset),

    .ini_araddr     ({cpu0_ARADDR,  sd_controller_dma_ARADDR        }),
    .ini_arvalid    ({cpu0_ARVALID, sd_controller_dma_ARVALID       }),
    .ini_arready    ({cpu0_ARREADY, sd_controller_dma_ARREADY       }),
    .ini_rdata      ({cpu0_RDATA,   sd_controller_dma_RDATA         }),
    .ini_rresp      ({cpu0_RRESP,   sd_controller_dma_RRESP         }),
    .ini_rvalid     ({cpu0_RVALID,  sd_controller_dma_RVALID        }),
    .ini_rready     ({cpu0_RREADY,  sd_controller_dma_RREADY        }),
    .ini_awaddr     ({cpu0_AWADDR,  sd_controller_dma_AWADDR        }),
    .ini_awready    ({cpu0_AWREADY, sd_controller_dma_AWREADY       }),
    .ini_awvalid    ({cpu0_AWVALID, sd_controller_dma_AWVALID       }),
    .ini_wvalid     ({cpu0_WVALID,  sd_controller_dma_WVALID        }),
    .ini_wready     ({cpu0_WREADY,  sd_controller_dma_WREADY        }),
    .ini_wdata      ({cpu0_WDATA,   sd_controller_dma_WDATA         }),
    .ini_wstrb      ({cpu0_WSTRB,   sd_controller_dma_WSTRB         }),
    .ini_bresp      ({cpu0_BRESP,   sd_controller_dma_BRESP         }),
    .ini_bvalid     ({cpu0_BVALID,  sd_controller_dma_BVALID        }),
    .ini_bready     ({cpu0_BREADY,  sd_controller_dma_BREADY        }),
    .tgt_araddr     ({ram_araddr,   rom_araddr,     sdram_ARADDR,   sd_controller_csr_ARADDR    }),
    .tgt_arvalid    ({ram_arvalid,  rom_arvalid,    sdram_ARVALID,  sd_controller_csr_ARVALID   }),
    .tgt_arready    ({ram_arready,  rom_arready,    sdram_ARREADY,  sd_controller_csr_ARREADY   }),
    .tgt_rdata      ({ram_rdata,    rom_rdata,      sdram_RDATA,    sd_controller_csr_RDATA     }),
    .tgt_rresp      ({ram_rresp,    rom_rresp,      sdram_RRESP,    sd_controller_csr_RRESP     }),
    .tgt_rvalid     ({ram_rvalid,   rom_rvalid,     sdram_RVALID,   sd_controller_csr_RVALID    }),
    .tgt_rready     ({ram_rready,   rom_rready,     sdram_RREADY,   sd_controller_csr_RREADY    }),
    .tgt_awaddr     ({ram_awaddr,   rom_awaddr,     sdram_AWADDR,   sd_controller_csr_AWADDR    }),
    .tgt_awvalid    ({ram_awvalid,  rom_awvalid,    sdram_AWVALID,  sd_controller_csr_AWVALID   }),
    .tgt_awready    ({ram_awready,  rom_awready,    sdram_AWREADY,  sd_controller_csr_AWREADY   }),
    .tgt_wdata      ({ram_wdata,    rom_wdata,      sdram_WDATA,    sd_controller_csr_WDATA     }),
    .tgt_wvalid     ({ram_wvalid,   rom_wvalid,     sdram_WVALID,   sd_controller_csr_WVALID    }),
    .tgt_wready     ({ram_wready,   rom_wready,     sdram_WREADY,   sd_controller_csr_WREADY    }),
    .tgt_wstrb      ({ram_wstrb,    rom_wstrb,      sdram_WSTRB,    sd_controller_csr_WSTRB     }),
    .tgt_bresp      ({ram_bresp,    rom_bresp,      sdram_BRESP,    sd_controller_csr_BRESP     }),
    .tgt_bvalid     ({ram_bvalid,   rom_bvalid,     sdram_BVALID,   sd_controller_csr_BVALID    }),
    .tgt_bready     ({ram_bready,   rom_bready,     sdram_BREADY,   sd_controller_csr_BREADY    })

);

axi4_lite_rom #(
    .ROM_SIZE(8),
    .ROM_INIT_FILE("init_hex.mem")
) u_rom (
    .i_clk(i_sysclk),
    .i_rst(~master_reset),

    .o_AWREADY(rom_awready),
    .o_WREADY(rom_wready),

    .o_BVALID(rom_bvalid),
    .i_BREADY(rom_bready),
    .o_BRESP(rom_bresp),

    .i_ARVALID(rom_arvalid),
    .o_ARREADY(rom_arready),
    .i_ARADDR(rom_araddr),
    .i_ARPROT('0),

    .o_RVALID(rom_rvalid),
    .i_RREADY(rom_rready),
    .o_RDATA(rom_rdata),
    .o_RRESP(rom_rresp),

    .i_AWVALID(rom_awvalid),
    .i_AWADDR(rom_awaddr),
    .i_AWPROT('0),

    .i_WVALID(rom_wvalid),
    .i_WDATA(rom_wdata),
    .i_WSTRB(rom_wstrb)
);

axi4_lite_ram #(
    .RAM_SIZE(9)
) u_ram(
    .i_clk(i_sysclk),
    .i_rst(~master_reset),

    .o_AWREADY(ram_awready),
    .o_WREADY(ram_wready),

    .o_BVALID(ram_bvalid),
    .i_BREADY(ram_bready),
    .o_BRESP(ram_bresp),

    .i_ARVALID(ram_arvalid),
    .o_ARREADY(ram_arready),
    .i_ARADDR(ram_araddr),
    .i_ARPROT('0),

    .o_RVALID(ram_rvalid),
    .i_RREADY(ram_rready),
    .o_RDATA(ram_rdata),
    .o_RRESP(ram_rresp),

    .i_AWVALID(ram_awvalid),
    .i_AWADDR(ram_awaddr),
    .i_AWPROT('0),

    .i_WVALID(ram_wvalid),
    .i_WDATA(ram_wdata),
    .i_WSTRB(ram_wstrb)
);

logic [1:0] w_sdr_CKE;
logic [1:0] w_sdr_n_CS;
logic [1:0] w_sdr_n_RAS;
logic [1:0] w_sdr_n_CAS;
logic [1:0] w_sdr_n_WE;
logic [3:0] w_sdr_BA;
logic [25:0] w_sdr_ADDR;
logic [31:0] w_sdr_DATA;
logic [31:0] w_sdr_DATA_oe;
logic [3:0] w_sdr_DQM;

assign o_sdr_CKE = w_sdr_CKE[0];    //Using SOFT ddio, ignore second cycle
assign o_sdr_n_CS = w_sdr_n_CS[0];
assign o_sdr_n_RAS = w_sdr_n_RAS[0];
assign o_sdr_n_CAS = w_sdr_n_CAS[0];
assign o_sdr_n_WE = w_sdr_n_WE[0];
assign o_sdr_BA = w_sdr_BA[0+:2];
assign o_sdr_ADDR = w_sdr_ADDR[0+:13];
assign o_sdr_DATA = w_sdr_DATA[0+:16];
assign o_sdr_DATA_oe = w_sdr_DATA_oe[0+:16];
assign o_sdr_DQM = w_sdr_DQM[0+:2];

sdram_controller u_sdram_controller(
    .i_aresetn          (pre_reset),
    .i_sysclk           (i_sysclk),
    .i_sdrclk           (i_sdrclk),
    .i_tACclk           (i_tACclk),
    .o_pll_reset        (),
    .i_pll_locked       ('1),

    .o_sdr_state        (w_sdr_state),

    .i_AXI4_AWVALID     (sdram_AWVALID),
    .o_AXI4_AWREADY     (sdram_AWREADY),
    .i_AXI4_AWADDR      (sdram_AWADDR[23:0]),
    .i_AXI4_WVALID      (sdram_WVALID),
    .o_AXI4_WREADY      (sdram_WREADY),
    .i_AXI4_WDATA       (sdram_WDATA),
    .i_AXI4_WSTRB       (sdram_WSTRB),
    .o_AXI4_BVALID      (sdram_BVALID),
    .i_AXI4_BREADY      (sdram_BREADY),
    .i_AXI4_ARVALID     (sdram_ARVALID),
    .o_AXI4_ARREADY     (sdram_ARREADY),
    .i_AXI4_ARADDR      (sdram_ARADDR[23:0]),
    .o_AXI4_RVALID      (sdram_RVALID),
    .i_AXI4_RREADY      (sdram_RREADY),
    .o_AXI4_RDATA       (sdram_RDATA),

    .i_AXI4_WLAST       (sdram_WVALID),
    .o_AXI4_RLAST       (),
    .i_AXI4_AWID        ('0),
    .i_AXI4_AWSIZE      ('0),
    .i_AXI4_ARID        ('0),
    .i_AXI4_ARLEN       ('0),
    .i_AXI4_ARSIZE      ('0),
    .i_AXI4_ARBURST     ('0),
    .i_AXI4_AWLEN       ('0),
    .o_AXI4_RID         (),
    .o_AXI4_BID         (),

    .o_sdr_CKE          (w_sdr_CKE),
    .o_sdr_n_CS         (w_sdr_n_CS),
    .o_sdr_n_RAS        (w_sdr_n_RAS),
    .o_sdr_n_CAS        (w_sdr_n_CAS),
    .o_sdr_n_WE         (w_sdr_n_WE),
    .o_sdr_BA           (w_sdr_BA),
    .o_sdr_ADDR         (w_sdr_ADDR),
    .o_sdr_DATA         (w_sdr_DATA),
    .o_sdr_DATA_oe      (w_sdr_DATA_oe),
    .i_sdr_DATA         ({{16'b0}, {i_sdr_DATA}}),
    .o_sdr_DQM          (w_sdr_DQM)
);

logic                       sd_controller_apb_psel;
logic                       sd_controller_apb_penable;
logic                       sd_controller_apb_pwrite;
logic [2:0]                 sd_controller_apb_pprot;
logic [ADDR_WIDTH-1:0]      sd_controller_apb_paddr;
logic [DATA_WIDTH-1:0]      sd_controller_apb_pwdata;
logic [DATA_WIDTH/8-1:0]    sd_controller_apb_pstrb;
logic                       sd_controller_apb_pready;
logic  [DATA_WIDTH-1:0]       sd_controller_apb_prdata;
logic                       sd_controller_apb_pslverr;


axi4_lite_to_apb4 u_sd_axi_apb_converter (
    .i_clk(i_sysclk),
    .i_rst(~master_reset),

    .i_AWVALID(sd_controller_csr_AWVALID),
    .o_AWREADY(sd_controller_csr_AWREADY),
    .i_AWADDR(sd_controller_csr_AWADDR),
    .i_WVALID(sd_controller_csr_AWVALID),
    .o_WREADY(sd_controller_csr_WREADY),
    .i_WDATA(sd_controller_csr_WDATA),
    .i_WSTRB(sd_controller_csr_WSTRB),
    .o_BVALID(sd_controller_csr_BVALID),
    .i_BREADY(sd_controller_csr_BREADY),
    .o_BRESP(sd_controller_csr_BRESP),
    .i_ARVALID(sd_controller_csr_ARVALID),
    .o_ARREADY(sd_controller_csr_ARREADY),
    .i_ARADDR(sd_controller_csr_ARADDR),
    .i_ARPROT('0),
    .o_RVALID(sd_controller_csr_RVALID),
    .i_RREADY(sd_controller_csr_RREADY),
    .o_RDATA(sd_controller_csr_RDATA),
    .o_RRESP(sd_controller_csr_RRESP),

    .m_apb_psel(sd_controller_apb_psel),
    .m_apb_penable(sd_controller_apb_penable),
    .m_apb_pwrite(sd_controller_apb_pwrite),
    .m_apb_pprot(sd_controller_apb_pprot),
    .m_apb_paddr(sd_controller_apb_paddr),
    .m_apb_pwdata(sd_controller_apb_pwdata),
    .m_apb_pstrb(sd_controller_apb_pstrb),
    .m_apb_pready(sd_controller_apb_pready),
    .m_apb_prdata(sd_controller_apb_prdata),
    .m_apb_pslverr(sd_controller_apb_pslverr)
);

sd_controller_top u_sd_controller (
    .clk(i_sysclk),
    .rst(~master_reset),

    .s_apb_psel(sd_controller_apb_psel),
    .s_apb_penable(sd_controller_apb_penable),
    .s_apb_pwrite(sd_controller_apb_pwrite),
    .s_apb_pprot(sd_controller_apb_pprot),
    .s_apb_paddr(sd_controller_apb_paddr[5:0]),
    .s_apb_pwdata(sd_controller_apb_pwdata),
    .s_apb_pstrb(sd_controller_apb_pstrb),
    .s_apb_pready(sd_controller_apb_pready),
    .s_apb_prdata(sd_controller_apb_prdata),
    .s_apb_pslverr(sd_controller_apb_pslverr),

    .o_AWVALID  (sd_controller_dma_AWVALID),
    .i_AWREADY  (sd_controller_dma_AWREADY),
    .o_AWADDR   (sd_controller_dma_AWADDR),
    .o_WVALID   (sd_controller_dma_WVALID),
    .i_WREADY   (sd_controller_dma_WREADY),
    .o_WDATA    (sd_controller_dma_WDATA),
    .o_WSTRB    (sd_controller_dma_WSTRB),
    .i_BVALID   (sd_controller_dma_BVALID),
    .o_BREADY   (sd_controller_dma_BREADY),
    .i_BRESP    (sd_controller_dma_BRESP),
    .o_ARVALID  (sd_controller_dma_ARVALID),
    .i_ARREADY  (sd_controller_dma_ARREADY),
    .o_ARADDR   (sd_controller_dma_ARADDR),
    .i_RVALID   (sd_controller_dma_RVALID),
    .o_RREADY   (sd_controller_dma_RREADY),
    .i_RDATA    (sd_controller_dma_RDATA),
    .i_RRESP    (sd_controller_dma_RRESP),

    

    .i_sd_cmd(i_sd_cmd),
    .o_sd_cmd(o_sd_cmd),
    .o_sd_cmd_oe(o_sd_cmd_oe),
    .o_sd_clk(o_sd_clk),

    .i_sd_dat(i_sd_dat),
    .o_sd_dat(o_sd_dat),
    .o_sd_dat_oe(o_sd_dat_oe)
);

endmodule