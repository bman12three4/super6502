# Network Processor

The network processor terminates TCP connections.

## Theory of Operation

The idea behind this network processor is that the configuration is stored in
a context buffer rather than being written to device configuration registers.
This like the IP addresses, ports, TCP state, flow control window, congestion
window, sequence numbers, etc. are stored in this context buffer.

The context buffer can be created once by software when the connection is
created, and is then managed by hardware until the connection is closed.

The other interface to the core is through the packet DMA interface. The packets
contain a simple header which contains the instruction for the core, the context
pointer, the protocol, and the length of the data.

## Components

### TCP State Manager

The TCP State manager is responsible for maintaining the TCP State. It facilitates
communication between the RX control and TX control. The most important thing that
the TCP State manager does is request the socket structures from memory, and load
these values into the RX and TX control, and vice-versa.

#### Clock and Reset


| Clock Name | Clock Frequency |
|---------------|---------------|
| System Clock | 100MHz |

| Reset Name | Purpose |
|-----------|------------|
| rst_n   | General Reset |

#### Bus Interfaces

| Bus Name       | Type and Purpose |
| -------------- | ---------------- |
| cfg_apb        | APB Configuration |
| ctx_dma_m_axil | Context DMA Master |

#### Other Signals
| Signal Name | Direction | Description |
| ----------- | --------- | ----------- |
| o_send_syn | O | Tells TX control to send a syn packet. If o_send_ack is also valid, then send a syn_ack packet |
| o_send_ack | O | Tells TX control to send an ack packet |
| o_send_fin | O | Tells TX control to send a fin packet. If o_send_ack is also valid, then send a fin_ack packet |
| o_seq_num | O | Current sequence number |
| i_seq_num | I | Next sequence number |
| i_seq_num_we | I | Write new sequence number |
| o_ack_num | O | Current ack number |
| i_ack_num | I | Next ack number |
| i_ack_num_we | I | Write new ack number |
| i_ctx_addr | I | Context pointer from TX control |
| i_ctx_valid| I | Context pointer is valid |
| o_cam_key | O | Key to write to CAM (port) |
| o_cam_val | O | Value to write to CAM (pointer) |
| i_cam_val | I | Value read from CAM |
| i_cam_hit | I | Value read from CAM is valid |
| o_cam_we | O | Write value to CAM |
| o_cam_re | O | Read value from CAM |
| i_tx_ctx_ptr | I | Context pointer from TX Control |
| i_tx_ctx_ptr_valid | I | Conext pointer is valid |
| i_rx_port | I | RX Port input |
| i_rx_port_valid | I | RX Port Valid |