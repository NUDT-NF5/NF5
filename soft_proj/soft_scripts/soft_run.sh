iverilog_dir=iverilog-project
nc_dir=nc-project

vivado_dir=vivado-project/NF5_System/NF5_System.sim/sim_1/behav/xsim
vivado_sh_dir=vivado-project
vivado_tb_dir=vivado-project/NF5_System/NF5_System.srcs/sim_1/imports/nf5_source

while :
do
        echo "================选择使用的仿真工具======================="
        echo "    1  Icarus Verilog + Gtkwave       "
        echo "    2  Cadence NC-Verilog             "
	echo "    3  #(Xilinx Vivado)               "
        echo "========================================================"
        echo "    PLease input the [Number] to chose the EDATool :    "
        read number_nc_vivado
        if   [ $number_nc_vivado -eq 1 ]
          then 
 	    EDATool_run_dir=$iverilog_dir/run_iverilog  #$src_dir1
            EDA_env_dir=$iverilog_dir
	    cp $iverilog_dir/TbAll_default.sv src/top/TbAll.sv
            break
        elif [ $number_nc_vivado -eq 2 ]
          then
	    EDATool_run_dir=$nc_dir/run
            EDA_env_dir=$nc_dir
            break
        elif [ $number_nc_vivado -eq 3  ]
          then
            #EDATool_run_dir=$vivado_sh_dir/vivado_nf5.sh
	    #EDA_env_dir=$vivado_dir
 	    echo "Wrong number"
            break
        else
          echo "Wrong number"
          continue
fi
done
bash $EDATool_run_dir
gedit $EDA_env_dir/mySim.log 
