#@Author: Y-BoBo
#@Date:   2019-10-28 15:51
#@Last Modified by: Y-BoBo
#@Last Modified time: 2019-11-08 09:33:48
#@Describe: run shell


# cd NF5_System
# vivado -mode tcl -source vivado_nf5.tcl


NF5_proj=/home/ubuntu/Music/NF5_Cache_jzk_ex
vivado_proj=vivado-project
isa_test_proj=isa-test

#!/bin/bash
rm -rf 
while read test_name
do
	cp $NF5_proj/$isa_test_proj/isa-functional-test/test_0x8000/rv32ui-p/verilogtxt/$test_name $NF5_proj/$vivado_proj/NF5_System/NF5_System.sim/sim_1/behav/xsim/Instructions.list
	cp $NF5_proj/$isa_test_proj/isa-functional-test/test_0x8000/rv32ui-p/TB_vivado/$test_name-vivado.sv $NF5_proj/$vivado_proj/NF5_System/NF5_System.srcs/sim_1/imports/nf5_source/system_test_tb.sv
	# bash /home/ubuntu/Music/vivado_nf5.sh
	# source $NF5_proj/$vivado_proj/NF5_System/NF5_System.sim/sim_1/behav/xsim/system_test_tb.tcl
	# exec tclsh $NF5_proj/$vivado_proj/NF5_System/NF5_System.sim/sim_1/behav/xsim/system_test_tb.tcl
	# run 1ns
	cp $NF5_proj/$vivado_proj/NF5_System/NF5_System.sim/sim_1/behav/xsim/mySim.log $NF5_proj/$vivado_proj/tmp/$test_name.txt
	Report1=$(grep "ISA_test" $NF5_proj/$vivado_proj/tmp/$test_name.txt)             
	echo  " " >> $NF5_proj/$vivado_proj/tmp/Report_funct.txt 
	echo "$test_name" >> $NF5_proj/$vivado_proj/tmp/Report_funct.txt   
	echo  " " >> $NF5_proj/$vivado_proj/tmp/Report_funct.txt  
	echo "$Report1" >> $NF5_proj/$vivado_proj/tmp/Report_funct.txt   
	echo  " " >> $NF5_proj/$vivado_proj/tmp/Report_funct.txt  
let test_name++
done < $NF5_proj/$isa_test_proj/isa-functional-test/test_0x8000/rv32ui-p/testcase_list.txt

# set a [open myfile]
# set lines [split [read $a] "\n"]
# close $a;                          # Saves a few bytes :-)
# foreach line $lines {
#     # do something with each line...
# }

# while {[gets $qaz line] >= 0} {
# puts $line
#  }

# NF5_proj=/home/ubuntu/Music/NF5_Cache_jzk_ex
# vivado_proj=vivado-project
# isa_test_proj=isa-test
# test_name=rv32ui-p-add
# rv32ui-p-add
# rv32ui-p-bgeu

# cp /home/ubuntu/Music/NF5_Cache_jzk_ex/isa-test/isa-functional-test/test_0x8000/rv32ui-p/verilogtxt/rv32ui-p-bgeu /home/ubuntu/Music/NF5_Cache_jzk_ex/vivado-project/NF5_System/NF5_System.sim/sim_1/behav/xsim/Instructions.list
# cp /home/ubuntu/Music/NF5_Cache_jzk_ex/isa-test/isa-functional-test/test_0x8000/rv32ui-p/TB_vivado/rv32ui-p-bgeu-vivado.sv /home/ubuntu/Music/NF5_Cache_jzk_ex/vivado-project/NF5_System/NF5_System.srcs/sim_1/imports/nf5_source/system_test_tb.sv