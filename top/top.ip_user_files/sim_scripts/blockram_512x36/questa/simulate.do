onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib blockram_512x36_opt

do {wave.do}

view wave
view structure
view signals

do {blockram_512x36.udo}

run -all

quit -force
