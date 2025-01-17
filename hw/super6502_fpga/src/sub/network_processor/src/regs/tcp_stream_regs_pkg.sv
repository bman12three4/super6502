// Generated by PeakRDL-regblock - A free and open-source SystemVerilog generator
//  https://github.com/SystemRDL/PeakRDL-regblock

package tcp_stream_regs_pkg;

    localparam TCP_STREAM_REGS_DATA_WIDTH = 32;
    localparam TCP_STREAM_REGS_MIN_ADDR_WIDTH = 6;

    typedef struct {
        logic hwclr;
    } tcp_stream_regs__control__open__in_t;

    typedef struct {
        logic hwclr;
    } tcp_stream_regs__control__close__in_t;

    typedef struct {
        logic [2:0] next;
    } tcp_stream_regs__control__state__in_t;

    typedef struct {
        tcp_stream_regs__control__open__in_t open;
        tcp_stream_regs__control__close__in_t close;
        tcp_stream_regs__control__state__in_t state;
    } tcp_stream_regs__control__in_t;

    typedef struct {
        logic rd_ack;
        logic [31:0] rd_data;
        logic wr_ack;
    } m2s_dma_regs__external__in_t;

    typedef struct {
        tcp_stream_regs__control__in_t control;
        m2s_dma_regs__external__in_t m2s_dma_regs;
    } tcp_stream_regs__in_t;

    typedef struct {
        logic [31:0] value;
    } tcp_stream_regs__source_port__d__out_t;

    typedef struct {
        tcp_stream_regs__source_port__d__out_t d;
    } tcp_stream_regs__source_port__out_t;

    typedef struct {
        logic [31:0] value;
    } tcp_stream_regs__source_ip__d__out_t;

    typedef struct {
        tcp_stream_regs__source_ip__d__out_t d;
    } tcp_stream_regs__source_ip__out_t;

    typedef struct {
        logic [31:0] value;
    } tcp_stream_regs__dest_port__d__out_t;

    typedef struct {
        tcp_stream_regs__dest_port__d__out_t d;
    } tcp_stream_regs__dest_port__out_t;

    typedef struct {
        logic [31:0] value;
    } tcp_stream_regs__dest_ip__d__out_t;

    typedef struct {
        tcp_stream_regs__dest_ip__d__out_t d;
    } tcp_stream_regs__dest_ip__out_t;

    typedef struct {
        logic value;
    } tcp_stream_regs__control__enable__out_t;

    typedef struct {
        logic value;
    } tcp_stream_regs__control__open__out_t;

    typedef struct {
        logic value;
    } tcp_stream_regs__control__close__out_t;

    typedef struct {
        tcp_stream_regs__control__enable__out_t enable;
        tcp_stream_regs__control__open__out_t open;
        tcp_stream_regs__control__close__out_t close;
    } tcp_stream_regs__control__out_t;

    typedef struct {
        logic req;
        logic [3:0] addr;
        logic req_is_wr;
        logic [31:0] wr_data;
        logic [31:0] wr_biten;
    } m2s_dma_regs__external__out_t;

    typedef struct {
        tcp_stream_regs__source_port__out_t source_port;
        tcp_stream_regs__source_ip__out_t source_ip;
        tcp_stream_regs__dest_port__out_t dest_port;
        tcp_stream_regs__dest_ip__out_t dest_ip;
        tcp_stream_regs__control__out_t control;
        m2s_dma_regs__external__out_t m2s_dma_regs;
    } tcp_stream_regs__out_t;
endpackage
