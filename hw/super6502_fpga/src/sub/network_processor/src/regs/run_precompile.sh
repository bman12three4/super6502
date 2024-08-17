peakrdl regblock tcp_stream.rdl tcp_top_regs.rdl -o . --cpuif axi4-lite-flat
peakrdl regblock -t tcp_stream_regs tcp_stream.rdl -o . --cpuif passthrough

# sed -i -e 's/struct/struct packed/g' tcp_stream_regs.sv
# sed -i -e 's/struct/struct packed/g' tcp_stream_regs_pkg.sv
# sed -i -e 's/automatic/static/g' tcp_stream_regs.sv

# sed -i -e 's/struct/struct packed/g' tcp_top_regfile.sv
# sed -i -e 's/struct/struct packed/g' tcp_top_regfile_pkg.sv
# sed -i -e 's/automatic/static/g' tcp_top_regfile.sv
