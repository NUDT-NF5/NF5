vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/blk_mem_gen_v8_3_6
vlib modelsim_lib/msim/axi_bram_ctrl_v4_0_14
vlib modelsim_lib/msim/generic_baseblocks_v2_1_0
vlib modelsim_lib/msim/axi_infrastructure_v1_1_0
vlib modelsim_lib/msim/axi_register_slice_v2_1_17
vlib modelsim_lib/msim/fifo_generator_v13_2_2
vlib modelsim_lib/msim/axi_data_fifo_v2_1_16
vlib modelsim_lib/msim/axi_crossbar_v2_1_18
vlib modelsim_lib/msim/util_vector_logic_v2_0_1

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap blk_mem_gen_v8_3_6 modelsim_lib/msim/blk_mem_gen_v8_3_6
vmap axi_bram_ctrl_v4_0_14 modelsim_lib/msim/axi_bram_ctrl_v4_0_14
vmap generic_baseblocks_v2_1_0 modelsim_lib/msim/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 modelsim_lib/msim/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_17 modelsim_lib/msim/axi_register_slice_v2_1_17
vmap fifo_generator_v13_2_2 modelsim_lib/msim/fifo_generator_v13_2_2
vmap axi_data_fifo_v2_1_16 modelsim_lib/msim/axi_data_fifo_v2_1_16
vmap axi_crossbar_v2_1_18 modelsim_lib/msim/axi_crossbar_v2_1_18
vmap util_vector_logic_v2_0_1 modelsim_lib/msim/util_vector_logic_v2_0_1

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_SRAM_0_0/sim/NF5_System_SRAM_0_0.v" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_SRAM_1_0/sim/NF5_System_SRAM_1_0.v" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/sim/NF5_System.v" \

vlog -work blk_mem_gen_v8_3_6 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/2751/simulation/blk_mem_gen_v8_3.v" \

vcom -work axi_bram_ctrl_v4_0_14 -64 -93 \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/6db1/hdl/axi_bram_ctrl_v4_0_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_axi_bram_ctrl_0_4/sim/NF5_System_axi_bram_ctrl_0_4.vhd" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_axi_bram_ctrl_0_5/sim/NF5_System_axi_bram_ctrl_0_5.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_Core_0_2/sim/NF5_System_Core_0_2.v" \

vlog -work generic_baseblocks_v2_1_0 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_17 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/6020/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_2 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/7aff/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_2 -64 -93 \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_2 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_16 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/247d/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_18 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/15a3/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_xbar_0/sim/NF5_System_xbar_0.v" \

vlog -work util_vector_logic_v2_0_1 -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/2137/hdl/util_vector_logic_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_util_vector_logic_0_0/sim/NF5_System_util_vector_logic_0_0.v" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_util_vector_logic_0_1/sim/NF5_System_util_vector_logic_0_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

