vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/blk_mem_gen_v8_3_6
vlib riviera/axi_bram_ctrl_v4_0_14
vlib riviera/generic_baseblocks_v2_1_0
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_register_slice_v2_1_17
vlib riviera/fifo_generator_v13_2_2
vlib riviera/axi_data_fifo_v2_1_16
vlib riviera/axi_crossbar_v2_1_18
vlib riviera/util_vector_logic_v2_0_1

vmap xil_defaultlib riviera/xil_defaultlib
vmap blk_mem_gen_v8_3_6 riviera/blk_mem_gen_v8_3_6
vmap axi_bram_ctrl_v4_0_14 riviera/axi_bram_ctrl_v4_0_14
vmap generic_baseblocks_v2_1_0 riviera/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_17 riviera/axi_register_slice_v2_1_17
vmap fifo_generator_v13_2_2 riviera/fifo_generator_v13_2_2
vmap axi_data_fifo_v2_1_16 riviera/axi_data_fifo_v2_1_16
vmap axi_crossbar_v2_1_18 riviera/axi_crossbar_v2_1_18
vmap util_vector_logic_v2_0_1 riviera/util_vector_logic_v2_0_1

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_SRAM_0_0/sim/NF5_System_SRAM_0_0.v" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_SRAM_1_0/sim/NF5_System_SRAM_1_0.v" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/sim/NF5_System.v" \

vlog -work blk_mem_gen_v8_3_6  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/2751/simulation/blk_mem_gen_v8_3.v" \

vcom -work axi_bram_ctrl_v4_0_14 -93 \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/6db1/hdl/axi_bram_ctrl_v4_0_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_axi_bram_ctrl_0_4/sim/NF5_System_axi_bram_ctrl_0_4.vhd" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_axi_bram_ctrl_0_5/sim/NF5_System_axi_bram_ctrl_0_5.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_Core_0_2/sim/NF5_System_Core_0_2.v" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_17  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/6020/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_2  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/7aff/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_2 -93 \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_2  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_16  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/247d/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_18  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/15a3/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_xbar_0/sim/NF5_System_xbar_0.v" \

vlog -work util_vector_logic_v2_0_1  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/2137/hdl/util_vector_logic_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" "+incdir+../../../../NF5_System.srcs/sources_1/bd/NF5_System/ipshared/ec67/hdl" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_util_vector_logic_0_0/sim/NF5_System_util_vector_logic_0_0.v" \
"../../../../NF5_System.srcs/sources_1/bd/NF5_System/ip/NF5_System_util_vector_logic_0_1/sim/NF5_System_util_vector_logic_0_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

