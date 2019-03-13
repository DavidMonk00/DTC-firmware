onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib BinarySorterRam_opt

do {wave.do}

view wave
view structure
view signals

do {BinarySorterRam.udo}

run -all

quit -force
