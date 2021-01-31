onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+NF5_System -L xil_defaultlib -L blk_mem_gen_v8_3_6 -L axi_bram_ctrl_v4_0_14 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_17 -L fifo_generator_v13_2_2 -L axi_data_fifo_v2_1_16 -L axi_crossbar_v2_1_18 -L util_vector_logic_v2_0_1 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.NF5_System xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {NF5_System.udo}

run -all

endsim

quit -force
