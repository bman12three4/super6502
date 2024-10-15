# Network Processor

The network processor terminates TCP connections.

## Theory of Operation

Configuration is loaded statically into one of the available TCP

## Components

### TCP State Manager

The TCP State manager is responsible for maintaining the TCP State. It facilitates
communication between the RX control and TX control. The most important thing that
the TCP State manager does is request the socket structures from memory, and load
these values into the RX and TX control, and vice-versa.

When the TCP State Manager sees i_tx_ctx_ptr_valid, it will read i_tx_ctx_ptr and then
DMA that struct into it's local memory. It will then look up the port in the CAM. If
the port is not present, it will write it. If the CAM is full, then we set a flag in
the context saying that the socket was not opened successfully.

#### Clock and Reset


| Clock Name | Clock Frequency |
|---------------|---------------|
| System Clock | 100MHz |

| Reset Name | Purpose |
|-----------|------------|
| rst_n   | General Reset |

#### Regfile Inputs

All of the registers go through the tcp state manager.


#### Other Signals
| Signal Name | Direction | Description |
| ----------- | --------- | ----------- |
| o_send_type | O | Type of packet to create |
| o_send_valid | O | Send a packet |
| o_seq_num | O | Current sequence number |
| i_seq_num | I | Next sequence number |
| i_seq_num_we | I | Write new sequence number |
| o_ack_num | O | Current ack number |
| i_ack_num | I | Next ack number |
| i_ack_num_we | I | Write new ack number |
| i_recvd_type | I | Received packet type from RX control. Bitmask from packet. |
| i_recvd_valid | I | Recieved type valid |
| o_tx_port | O | TX port output to TX Packet Gen |
| o_tx_ip | O | TX IP Address |
| o_rx_port | O | RX port output to RX Parser |
| o_rx_ip | O | RX IP. Local IP of device |