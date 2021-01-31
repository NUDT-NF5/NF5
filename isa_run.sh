#@Author: Y-BoBo
#@Date:   2019-10-28 15:51
#@Last Modified by: Y-BoBo
#@Last Modified time: 2019-11-08 09:33:48
#@Describe: run shell

#!/bin/bash
#-------------环境变量合集------------
isa_test_dir=isa-test
out_dir=output
nc_dir=nc-project
src_dir=src
iverilog_dir=iverilog-project
vivado_dir=vivado-project/NF5_System/NF5_System.sim/sim_1/behav/xsim
vivado_sh_dir=vivado-project
vivado_tb_dir=vivado-project/NF5_System/NF5_System.srcs/sim_1/imports/nf5_source
TB_dir=TB_NC
while :
do
        echo "================选择使用的仿真工具======================="
        echo "    1  Open source tool：Icarus Verilog + Gtkwave       "
        echo "    2  Commercial  tool：Cadence NC-Verilog             "
	echo "    3  Commercial  tool：Xilinx Vivado                  "
        echo "========================================================"
        echo "    PLease input the [Number] to chose the EDATool :    "
        read number_nc_vivado
        if   [ $number_nc_vivado -eq 1 ]
          then 
            EDATool_run_dir=$iverilog_dir/run_iverilog  #$src_dir1
            EDA_env_dir=$iverilog_dir
            TB_dir=TB_iverilog
            break
        elif [ $number_nc_vivado -eq 2 ]
          then
            EDATool_run_dir=$nc_dir/run
            EDA_env_dir=$nc_dir
            TB_dir=TB_NC
            break
        elif [ $number_nc_vivado -eq 3  ]
          then
            EDATool_run_dir=$vivado_sh_dir/vivado_nf5.sh
            EDA_env_dir=$vivado_dir
            TB_dir=TB_vivado
            break
        else
          echo "Wrong number"
          continue
fi
done

cd $nc_dir && ./set_no_gui && cd -
while :
do
        echo  "================选择测试测试集名称和相应的地址======================="
        echo  "   1   Test_name : functional-test    Test_Addr_start : 0x0000    "
        echo  "   2   Test_name : functional-test    Test_Addr_start : 0x8000    "
        echo  "   3   Test_name : compliance-test    Test_Addr_start : 0x0000    "
        echo  "   4   Test_name : compliance-test    Test_Addr_start : 0x8000    "
        echo  "=================================================================="
        echo  "   PLease input the [Number] to chose the Test Name and Address : "
        read number_0x 
        if   [ $number_0x -eq 1 ]
          then
          TVM_test=$isa_test_dir/isa-functional-test
          test_dir=$isa_test_dir/isa-functional-test/test_0x0000
          number_0x_numb=1
          break
        elif [ $number_0x -eq 2 ]
          then
          TVM_test=$isa_test_dir/isa-functional-test
          test_dir=$isa_test_dir/isa-functional-test/test_0x8000
          number_0x_numb=2
          break
        elif [ $number_0x -eq 3 ]
          then
          TVM_test=$isa_test_dir/isa-compliance-test
          test_dir=$isa_test_dir/isa-compliance-test/test_0x0000
          number_0x_numb=3
          # TB_dir=TB_compliance
          break
        elif [ $number_0x -eq 4 ]
          then
          TVM_test=$isa_test_dir/isa-compliance-test
          test_dir=$isa_test_dir/isa-compliance-test/test_0x8000 
          number_0x_numb=4
          # TB_dir=TB_compliance
          break
        else 
          echo "Wrong number"
          continue
fi
done

#--------------产生功能测试集列表---------------------
ls $test_dir/ > $TVM_test/TVM_name.txt  #list testcase name (eg: rv32ui-p)
count_tmp=1
while read name_tmp
do
        ls $test_dir/$name_tmp/verilogtxt/ > $test_dir/$name_tmp/testcase_list.txt  #list testcase name (eg: rv32ui-p-add) 
        let count_tmp++
done < $TVM_test/TVM_name.txt  

#--------------列出基础功能测试集的名称-----------------
echo  "==============================================================================="
cat -n $TVM_test/TVM_name.txt
echo  "==============================================================================="
echo  "Please input the Number of [TVM model and Target Environment Name] to select : "
echo  "==============================================================================="
#-------------选择基础测试 ？中的某一个子集进行遍历测试-----
read number_TVM_model

ISA_TVM_testcase=$(sed -n "$number_TVM_model p" $TVM_test/TVM_name.txt)
echo  "============================"
echo  "     1   Test way :    all                             "
echo  "     2   Test way :    single                      "
echo  "============================"
echo  "     Please select the Way to Test:  "
timer_start=`date "+%Y-%m-%d %H:%M:%S"`

while :
do
read number_single_all
#====================test_all==================
if [ $number_single_all -eq 1 ]
  then
                  #====================functional==================
                  if [ $number_0x_numb -eq 1 ] || [ $number_0x_numb -eq 2 ]
                    then
                            rm -rf $out_dir/Result/Result_funct/*
                            rm -rf $out_dir/Report/Report_funct.txt 
                            mkdir -p $out_dir/Result/Result_funct
                            touch $out_dir/Report/Report_funct.txt
                            #===================循环运行仿真===================
                            count_test=1
                            while read list_testcase
                            do                               
                                    if [ $TB_dir = TB_vivado ]
                                      then
                                        cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$list_testcase-vivado.sv  $vivado_tb_dir/system_test_tb.sv
                                        cp $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase  $EDA_env_dir/Instructions.list
                                    elif [ $TB_dir = TB_iverilog ]
                                      then
                                        cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$list_testcase-iverilog.sv  $src_dir/top/TbAll.sv
                                        cp $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase  $EDA_env_dir/Instructions.list
                                    else
                                        cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$list_testcase.sv  $src_dir/top/TbAll.sv
                                        cp $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase  $EDA_env_dir/Instructions.list
                                    fi          
                                    $EDATool_run_dir
                                    echo  "Test $list_testcase is running  "
                                    cp $EDA_env_dir/mySim.log  $out_dir/Result/Result_funct/$list_testcase.log      #产生的日志文件复制到result文件夹中
                            let count_test++
                            done < $test_dir/$ISA_TVM_testcase/testcase_list.txt
                            #===================处理仿真结果===================
                            mkdir -p $out_dir/Report
                            ls $out_dir/Result/Result_funct > $out_dir/Report/Report_funct_list.txt
                            count_report=1
                            while read line_report    #读取list的每一行
                            do
                                    Report1=$(grep "ISA_test" $out_dir/Result/Result_funct/$line_report)          #将每个测试文件中的ISA_test关键字找出来赋值给变量     
                                    echo  " " >> $out_dir/Report/Report_funct.txt    #将测试文件名称以及关键字段打印到report中
                                    echo "$line_report" >> $out_dir/Report/Report_funct.txt   
                                    echo  " " >> $out_dir/Report/Report_funct.txt  
                                    echo "$Report1" >> $out_dir/Report/Report_funct.txt   
                                    echo  " " >> $out_dir/Report/Report_funct.txt  
                            let count_report++
                            done < $out_dir/Report/Report_funct_list.txt    
                            #============将report的结果重新排列整理为按列对齐============
                            cat $out_dir/Report/Report_funct.txt  | column -t  > $out_dir/Report/Report_funct_New.txt      
                            rm -rf $out_dir/Report/Report_funct.txt
                            mv $out_dir/Report/Report_funct_New.txt  $out_dir/Report/Report_funct.txt
                            gedit $out_dir/Report/Report_funct.txt
                  #===================compliance===================
                  elif [ $number_0x_numb -eq 3 ] || [ $number_0x_numb -eq 4 ]
                    then
                            rm -rf $out_dir/Result/Result_compliance/*
                            rm -rf $out_dir/Report/Report_compliance.txt 
                            mkdir -p $out_dir/Result/Result_compliance
                            mkdir -p $out_dir/Report
                            count_test=1
                            touch $out_dir/Report/Report_compliance.txt
                            #===================循环运行仿真===================
                            while read list_testcase
                            do
                                if [ $TB_dir = TB_vivado ]
                                  then
                                    cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$list_testcase.sv  $vivado_tb_dir/system_test_tb.sv
                                    cp $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase  $EDA_env_dir/Instructions.list
                                elif [ $TB_dir = TB_iverilog ]
                                  then
                                    cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$list_testcase-iverilog.sv  $src_dir/top/TbAll.sv
                                    cp $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase  $EDA_env_dir/Instructions.list
                                else
                                    cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$list_testcase.sv  $src_dir/top/TbAll.sv
                                    cp $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase  $EDA_env_dir/Instructions.list
                                fi                     
                                $EDATool_run_dir
                                cp $EDA_env_dir/mySim.log $out_dir/Result/Result_compliance/$list_testcase.log
                                diff  $test_dir/$ISA_TVM_testcase/signature/"$list_testcase".* $out_dir/Result/Result_compliance/$list_testcase.log
                                if  [ $? -eq 0 ]
                                  then 
                                    echo  "$list_testcase   Pass" >> $out_dir/Report/Report_compliance.txt
                                elif [ $? -eq 1 ] 
                                  then 
                                    echo  "$list_testcase   Fail" >> $out_dir/Report/Report_compliance.txt 
                                else 
                                    echo "Wrong"
                                fi               
                                rm -rf $isa_test_dir/TbAll_tmp.txt
                              let count_test++
                            done < $test_dir/$ISA_TVM_testcase/testcase_list.txt
                            #===================处理仿真结果===================
                            cat $out_dir/Report/Report_compliance.txt  | column -t  > $out_dir/Report/report_compliance_1.txt  
                            rm -rf $out_dir/Report/Report_compliance.txt
                            mv $out_dir/Report/report_compliance_1.txt $out_dir/Report/Report_compliance.txt
                            gedit $out_dir/Report/Report_compliance.txt 
                  else
                    echo "Wrong"
                  fi
                  break
#====================test_single==================
elif [ $number_single_all -eq 2 ]
  then
             #====================functional==================
            if [ $number_0x_numb -eq 1 ] || [ $number_0x_numb -eq 2 ]
            then
                            rm -rf $out_dir/Result/Result_funct_self/*
                            mkdir -p $out_dir/Result/Result_funct_self
                            #===================循环运行仿真===================
                            echo  "==============================================================="
                            cat -n  $test_dir/$ISA_TVM_testcase/testcase_list.txt
                            echo  "==============================================================="
                            echo  "     Please select the single instruction test file to test :  "
                            echo  "==============================================================="    
                            read number_test_once  #输入需要进行单独测试的文件编号
                            single_test_name=$(sed -n "$number_test_once p" $test_dir/$ISA_TVM_testcase/testcase_list.txt)   #根据输入的编号进入list.txt文件查找对应的名称
                            if [ $TB_dir = TB_vivado ]
                              then
                                cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$single_test_name-vivado.sv  $vivado_tb_dir/system_test_tb.sv
                                cp $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name  $EDA_env_dir/Instructions.list
                            elif [ $TB_dir = TB_iverilog ]
                              then
                                cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$single_test_name-iverilog.sv  $src_dir/top/TbAll.sv
                                cp $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name  $EDA_env_dir/Instructions.list
                            else
                                cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$single_test_name.sv  $src_dir/top/TbAll.sv
                                cp $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name  $EDA_env_dir/Instructions.list
                            fi                
                            $EDATool_run_dir
                            echo  "Test $single_test_name is running  "
                            cp $EDA_env_dir/mySim.log $out_dir/Result/Result_funct_self/$single_test_name.txt
                            gedit $out_dir/Result/Result_funct_self/$single_test_name.txt
            #===================compliance===================
            elif [ $number_0x_numb -eq 3 ] || [ $number_0x_numb -eq 4 ]
              then
                            rm -rf $out_dir/Result/Result_compliance_self/*
                            mkdir -p $out_dir/Result/Result_compliance_self
                            #===================循环运行仿真===================
                            echo  "==============================================================="
                            cat -n  $test_dir/$ISA_TVM_testcase/testcase_list.txt
                            echo  "==============================================================="
                            echo  "     Please select the single instruction test file to test :  "
                            echo  "==============================================================="
                            read number_test_once    #输入需要进行单独测试的文件编号         
                            single_test_name=$(sed -n "$number_test_once p" $test_dir/$ISA_TVM_testcase/testcase_list.txt)   #根据输入的编号进入list.txt文件查找对应的名称
                            if [ $TB_dir = TB_vivado ]
                              then
                                cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$single_test_name.sv  $vivado_tb_dir/system_test_tb.sv
                                cp $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name  $EDA_env_dir/Instructions.list
                            elif [ $TB_dir = TB_iverilog ]
                              then
                                cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$single_test_name-iverilog.sv  $src_dir/top/TbAll.sv
                                cp $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name  $EDA_env_dir/Instructions.list
                            else
                                cp  $test_dir/$ISA_TVM_testcase/$TB_dir/$single_test_name.sv  $src_dir/top/TbAll.sv
                                cp $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name  $EDA_env_dir/Instructions.list
                            fi   
                            $EDATool_run_dir
                            diff  $test_dir/$ISA_TVM_testcase/signature/"$single_test_name".* $EDA_env_dir/mySim.log
                            if  [ $? -eq 0 ]
                              then 
                                echo  "$single_test_name   Pass" > $out_dir/Result/Result_compliance_self/$single_test_name.txt
                            elif [ $? -eq 1 ] 
                              then 
                                echo  "$single_test_name   Fail" > $out_dir/Result/Result_compliance_self/$single_test_name.txt 
                            else 
                                echo "Wrong"
                            fi
                            gedit $out_dir/Result/Result_compliance_self/$single_test_name.txt 
                            rm -rf $isa_test_dir/TbAll_tmp.txt
            else
              echo "Wrong number!"
            fi
            break
else
  echo "Wrong number!"
  continue
fi
done
timer_end=`date "+%Y-%m-%d %H:%M:%S"`
echo  "  $timer_start  "
echo  "  $timer_end  "
