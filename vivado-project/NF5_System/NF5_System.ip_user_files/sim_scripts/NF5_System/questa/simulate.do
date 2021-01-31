onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib NF5_System_opt

do {wave.do}

view wave
view structure
view signals

do {NF5_System.udo}

run -all

quit -force
