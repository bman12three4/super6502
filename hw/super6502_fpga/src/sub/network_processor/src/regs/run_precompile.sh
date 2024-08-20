peakrdl regblock -t tcp_top_regfile tcp_stream_regs.rdl tcp_top_regs.rdl -o . --cpuif passthrough
peakrdl regblock -t tcp_stream_regs tcp_stream_regs.rdl -o . --cpuif passthrough
peakrdl regblock -t mac_regs mac_regs.rdl -o . --cpuif passthrough
peakrdl regblock -t ntw_top_regfile mac_regs.rdl tcp_stream_regs.rdl tcp_top_regs.rdl ntw_top_regs.rdl -o . --cpuif axi4-lite-flat