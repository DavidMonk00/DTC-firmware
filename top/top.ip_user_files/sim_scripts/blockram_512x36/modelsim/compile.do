vlib work
vlib msim

vlib msim/xil_defaultlib

vmap xil_defaultlib msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../top.srcs/sources_1/ip/blockram_512x36/sim/blockram_512x36.v" \


vlog -work xil_defaultlib "glbl.v"

