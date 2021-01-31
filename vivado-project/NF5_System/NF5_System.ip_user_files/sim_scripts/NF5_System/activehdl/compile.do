vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/blk_mem_gen_v8_3_6
vlib activehdl/axi_bram_ctrl_v4_0_14
vlib activehdl/generic_baseblocks_v2_1_0
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_register_slice_v2_1_17
vlib activehdl/fifo_generator_v13_2_2
vlib activehdl/axi_data_fifo_v2_1_16
vlib activehdl/axi_crossbar_v2_1_18
vlib activehdl/util_vector_logic_v2_0_1

vmap xil_defaultlib activehdl/xil_defaultlib
vmap blk_mem_gen_v8_3_6 activehdl/blk_mem_gen_v8_3_6
vmap axi_bram_ctrl_v4_0_14 activehdl/axi_bram_ctrl_v4_0_14
vmap generic_baseblocks_v2_1_0 activehdl/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_17 activehdl/axi_register_slice_v2_1_17
vmap fifo_generator_v13_2_2 activehdl/fifo_generator_v13_2_2
vmap axi_data_fifo_v2_1_16 activehdl/axi_data_fifo_v2_1_16
vmap axi_crossbar_v2_1_18 activehdl/axi_crossbar_v2_1_18
vmap util_vector_logic_v2_0_1 activehdl/util_vector_logic_v2_0_1

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

