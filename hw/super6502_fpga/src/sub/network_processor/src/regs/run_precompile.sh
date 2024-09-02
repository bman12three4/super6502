peakrdl regblock -t tcp_top_regfile ../../../stream_dmas/src/regs/m2s_dma_regs.rdl tcp_stream_regs.rdl tcp_top_regs.rdl -o . --cpuif passthrough
peakrdl regblock -t tcp_stream_regs ../../../stream_dmas/src/regs/m2s_dma_regs.rdl tcp_stream_regs.rdl -o . --cpuif passthrough
peakrdl regblock -t mac_regs mac_regs.rdl -o . --cpuif passthrough
peakrdl regblock -t ntw_top_regfile mac_regs.rdl ../../../stream_dmas/src/regs/m2s_dma_regs.rdl tcp_stream_regs.rdl tcp_top_regs.rdl ntw_top_regs.rdl -o . --cpuif axi4-lite-flat
peakrdl html -t ntw_top_regfile mac_regs.rdl ../../../stream_dmas/src/regs/m2s_dma_regs.rdl tcp_stream_regs.rdl tcp_top_regs.rdl ntw_top_regs.rdl -o html
