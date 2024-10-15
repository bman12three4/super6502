// Generated by PeakRDL-regblock - A free and open-source SystemVerilog generator
//  https://github.com/SystemRDL/PeakRDL-regblock

package ntw_top_regfile_pkg;

    localparam NTW_TOP_REGFILE_DATA_WIDTH = 32;
    localparam NTW_TOP_REGFILE_MIN_ADDR_WIDTH = 10;

    typedef struct {
        logic rd_ack;
        logic [31:0] rd_data;
        logic wr_ack;
    } mac_regs__external__in_t;

    typedef struct {
        logic rd_ack;
        logic [31:0] rd_data;
        logic wr_ack;
    } tcp_top_regfile__external__in_t;

    typedef struct {
        mac_regs__external__in_t mac;
        tcp_top_regfile__external__in_t tcp_top;
    } ntw_top_regfile__in_t;

    typedef struct {
        logic req;
        logic [2:0] addr;
        logic req_is_wr;
        logic [31:0] wr_data;
        logic [31:0] wr_biten;
    } mac_regs__external__out_t;

    typedef struct {
        logic req;
        logic [7:0] addr;
        logic req_is_wr;
        logic [31:0] wr_data;
        logic [31:0] wr_biten;
    } tcp_top_regfile__external__out_t;

    typedef struct {
        mac_regs__external__out_t mac;
        tcp_top_regfile__external__out_t tcp_top;
    } ntw_top_regfile__out_t;
endpackage