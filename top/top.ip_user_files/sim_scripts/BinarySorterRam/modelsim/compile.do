vlib work
vlib msim

vlib msim/xil_defaultlib

vmap xil_defaultlib msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../top.srcs/sources_1/ip/BinarySorterRam/sim/BinarySorterRam.v" \


vlog -work xil_defaultlib "glbl.v"

