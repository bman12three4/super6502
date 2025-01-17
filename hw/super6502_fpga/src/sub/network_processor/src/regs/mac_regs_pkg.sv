// Generated by PeakRDL-regblock - A free and open-source SystemVerilog generator
//  https://github.com/SystemRDL/PeakRDL-regblock

package mac_regs_pkg;

    localparam MAC_REGS_DATA_WIDTH = 32;
    localparam MAC_REGS_MIN_ADDR_WIDTH = 3;

    typedef struct {
        logic hwset;
    } mac_regs__stats__tx_error_underflow__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__tx_fifo_overflow__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__tx_fifo_bad_frame__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__tx_fifo_good_frame__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__rx_error_bad_frame__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__rx_error_bad_fcs__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__rx_fifo_overflow__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__rx_fifo_bad_frame__in_t;

    typedef struct {
        logic hwset;
    } mac_regs__stats__rx_fifo_good_frame__in_t;

    typedef struct {
        mac_regs__stats__tx_error_underflow__in_t tx_error_underflow;
        mac_regs__stats__tx_fifo_overflow__in_t tx_fifo_overflow;
        mac_regs__stats__tx_fifo_bad_frame__in_t tx_fifo_bad_frame;
        mac_regs__stats__tx_fifo_good_frame__in_t tx_fifo_good_frame;
        mac_regs__stats__rx_error_bad_frame__in_t rx_error_bad_frame;
        mac_regs__stats__rx_error_bad_fcs__in_t rx_error_bad_fcs;
        mac_regs__stats__rx_fifo_overflow__in_t rx_fifo_overflow;
        mac_regs__stats__rx_fifo_bad_frame__in_t rx_fifo_bad_frame;
        mac_regs__stats__rx_fifo_good_frame__in_t rx_fifo_good_frame;
    } mac_regs__stats__in_t;

    typedef struct {
        mac_regs__stats__in_t stats;
    } mac_regs__in_t;

    typedef struct {
        logic value;
    } mac_regs__ctrl__tx_en__out_t;

    typedef struct {
        logic value;
    } mac_regs__ctrl__rx_en__out_t;

    typedef struct {
        logic value;
    } mac_regs__ctrl__phy_rstn__out_t;

    typedef struct {
        logic [7:0] value;
    } mac_regs__ctrl__ifg__out_t;

    typedef struct {
        mac_regs__ctrl__tx_en__out_t tx_en;
        mac_regs__ctrl__rx_en__out_t rx_en;
        mac_regs__ctrl__phy_rstn__out_t phy_rstn;
        mac_regs__ctrl__ifg__out_t ifg;
    } mac_regs__ctrl__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__tx_error_underflow__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__tx_fifo_overflow__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__tx_fifo_bad_frame__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__tx_fifo_good_frame__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__rx_error_bad_frame__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__rx_error_bad_fcs__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__rx_fifo_overflow__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__rx_fifo_bad_frame__out_t;

    typedef struct {
        logic value;
    } mac_regs__stats__rx_fifo_good_frame__out_t;

    typedef struct {
        mac_regs__stats__tx_error_underflow__out_t tx_error_underflow;
        mac_regs__stats__tx_fifo_overflow__out_t tx_fifo_overflow;
        mac_regs__stats__tx_fifo_bad_frame__out_t tx_fifo_bad_frame;
        mac_regs__stats__tx_fifo_good_frame__out_t tx_fifo_good_frame;
        mac_regs__stats__rx_error_bad_frame__out_t rx_error_bad_frame;
        mac_regs__stats__rx_error_bad_fcs__out_t rx_error_bad_fcs;
        mac_regs__stats__rx_fifo_overflow__out_t rx_fifo_overflow;
        mac_regs__stats__rx_fifo_bad_frame__out_t rx_fifo_bad_frame;
        mac_regs__stats__rx_fifo_good_frame__out_t rx_fifo_good_frame;
    } mac_regs__stats__out_t;

    typedef struct {
        mac_regs__ctrl__out_t ctrl;
        mac_regs__stats__out_t stats;
    } mac_regs__out_t;
endpackage
