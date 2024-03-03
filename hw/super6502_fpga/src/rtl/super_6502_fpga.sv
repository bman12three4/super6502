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

    input           [7:0]       i_cpu0_data_from_cpu,
    input                       i_cpu0_sync,
    input                       i_cpu0_rwb,
    input   logic   [15:0]      i_cpu0_addr,
    output  logic   [7:0]       o_cpu0_data_from_dut,
    output  logic   [7:0]       o_cpu0_data_oe,
    output  logic               o_cpu0_irqb,
    output  logic               o_cpu0_nmib,
    output  logic               o_cpu0_rdy,
    output  logic               o_cpu0_reset
);


localparam ADDR_WIDTH = 32;
localparam DATA_WIDTH = 32;


assign pll_cpu_reset = '1;
assign o_pll_reset = '1;

assign o_cpu0_nmib = '1;

assign o_clk_phi2 = clk_cpu;

assign o_cpu0_data_oe = {8{i_cpu0_rwb}};


logic master_reset;

assign master_reset = button_reset;

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
    .N_INITIATORS(1),
    .N_TARGETS(2)
) u_crossbar (
    .clk(i_sysclk),
    .rst(~master_reset),

    .ini_araddr     ({cpu0_ARADDR   }),
    .ini_arvalid    ({cpu0_ARVALID  }),
    .ini_arready    ({cpu0_ARREADY  }),
    .ini_rdata      ({cpu0_RDATA    }),
    .ini_rresp      ({cpu0_RRESP    }),
    .ini_rvalid     ({cpu0_RVALID   }),
    .ini_rready     ({cpu0_RREADY   }),
    .ini_awaddr     ({cpu0_AWADDR   }),
    .ini_awready    ({cpu0_AWREADY  }),
    .ini_awvalid    ({cpu0_AWVALID  }),
    .ini_wvalid     ({cpu0_WVALID   }),
    .ini_wready     ({cpu0_WREADY   }),
    .ini_wdata      ({cpu0_WDATA    }),
    .ini_wstrb      ({cpu0_WSTRB    }),
    .ini_bresp      ({cpu0_BRESP    }),
    .ini_bvalid     ({cpu0_BVALID   }),
    .ini_bready     ({cpu0_BREADY   }),

    .tgt_araddr     ({ram_araddr,   rom_araddr      }),
    .tgt_arvalid    ({ram_arvalid,  rom_arvalid     }),
    .tgt_arready    ({ram_arready,  rom_arready     }),
    .tgt_rdata      ({ram_rdata,    rom_rdata       }),
    .tgt_rresp      ({ram_rresp,    rom_rresp       }),
    .tgt_rvalid     ({ram_rvalid,   rom_rvalid      }),
    .tgt_rready     ({ram_rready,   rom_rready      }),
    .tgt_awaddr     ({ram_awaddr,   rom_awaddr      }),
    .tgt_awvalid    ({ram_awvalid,  rom_awvalid     }),
    .tgt_awready    ({ram_awready,  rom_awready     }),
    .tgt_wdata      ({ram_wdata,    rom_wdata       }),
    .tgt_wvalid     ({ram_wvalid,   rom_wvalid      }),
    .tgt_wready     ({ram_wready,   rom_wready      }),
    .tgt_wstrb      ({ram_wstrb,    rom_wstrb       }),
    .tgt_bresp      ({ram_bresp,    rom_bresp       }),
    .tgt_bvalid     ({ram_bvalid,   rom_bvalid      }),
    .tgt_bready     ({ram_bready,   rom_bready      })
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



endmodule