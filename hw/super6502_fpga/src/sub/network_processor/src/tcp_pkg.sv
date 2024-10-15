package tcp_pkg;

    typedef enum logic [2:0] {
        TX_CTRL_NOP,
        TX_CTRL_SEND_SYN,
        TX_CTRL_SEND_ACK,
        TX_CTRL_SEND_SYNACK,
        TX_CTRL_SEND_FIN
    } tx_ctrl_t;

    typedef enum logic [2:0] {
        RX_MSG_NOP,
        RX_MSG_RECV_SYN,
        RX_MSG_RECV_ACK,
        RX_MSG_RECV_FIN,
        RX_MSG_RECV_SYNACK
    } rx_msg_t;
endpackage