######################################################################
#
# File name : top_simulate.do
# Created on: Thu May 30 14:36:40 BST 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L xil_defaultlib -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.top

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {top_wave.do}

view wave
view structure
view signals

do {top.udo}

run 100ns
