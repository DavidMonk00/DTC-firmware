######################################################################
#
# File name : tb_simulate.do
# Created on: Fri Mar 09 11:37:27 GMT 2018
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L blk_mem_gen_v8_3_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.tb xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_wave.do}

view wave
view structure
view signals

do {/DataStore/trunk/cactusupgrades/projects/tracktrigger/dtc/TestBench.udo}

run 1000ns
