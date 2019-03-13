onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L blk_mem_gen_v8_3_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.blockram_512x36 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {blockram_512x36.udo}

run -all

quit -force
