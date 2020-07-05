#!/bin/bash
#@Author: Y-BoBo
#@Date:   2019-10-28 15:51
#@Last Modified by: Y-BoBo
#@Last Modified time: 2019-11-08 09:33:48
#@Describe: run shell

#-------------环境变量合集------------
isa_test_dir=isa-test
out_dir=output
nc_dir=nc-project
src_dir=src
iverilog_dir=iverilog-project

#-----------选择使用的仿真工具---------
echo -e "\n   1  Open source tool：Icarus Verilog + Gtkwave \n"
echo -e "\n   2  Commercial  tool：Cadence NC-Verilog  \n"
echo -e "\n   PLease input the [Number] to chose the EDATool : \n"

read number
if   [ $number -eq 1 ]
  then 
    EDATool_run_dir=./$iverilog_dir/run_iverilog  $src_dir1
    EDA_env_dir=$iverilog_dir
    EDA_env_dir_number=1
elif [ $number -eq 2 ]
  then
    EDATool_run_dir=./$nc_dir/run
    EDA_env_dir=$nc_dir
    EDA_env_dir_number=2
else
  echo "Wrong number"
fi
cd $nc_dir && ./set_no_gui && cd -
echo -e "\n   1   Test_name : functional-test \t Test_Addr_start : 0x0000 \n"
echo -e "\n   2   Test_name : functional-test \t Test_Addr_start : 0x8000 \n"
echo -e "\n   3   Test_name : compliance-test \t Test_Addr_start : 0x0000 \n"
echo -e "\n   4   Test_name : compliance-test \t Test_Addr_start : 0x8000 \n"
#-----------选择测试测试集名称和相应的地址---------
echo -e "\n   PLease input the [Number] to chose the Test Name and Address : \n"

read number 
if   [ $number -eq 1 ]
  then
  TVM_test=$isa_test_dir/isa-functional-test
  test_dir=$isa_test_dir/isa-functional-test/test_0x0000
elif [ $number -eq 2 ]
  then
  TVM_test=$isa_test_dir/isa-functional-test
  test_dir=$isa_test_dir/isa-functional-test/test_0x8000
elif [ $number -eq 3 ]
  then
  TVM_test=$isa_test_dir/isa-compliance-test
  test_dir=$isa_test_dir/isa-compliance-test/test_0x0000
elif [ $number -eq 4 ]
  then
  TVM_test=$isa_test_dir/isa-compliance-test
  test_dir=$isa_test_dir/isa-compliance-test/test_0x8000  
else 
  echo "Wrong number"
fi
#--------------产生功能测试集列表---------------------
ls $test_dir/ > $TVM_test/TVM_name.txt  #list testcase name (eg: rv32ui-p)
count_tmp=1
while read name_tmp
do
    ls $test_dir/$name_tmp/verilogtxt/ > $test_dir/$name_tmp/testcase_list.txt  #list testcase name (eg: rv32ui-p-add) 
    let count_tmp++
done < $TVM_test/TVM_name.txt  
#--------------列出基础功能测试集的名称-----------------
cat -n $TVM_test/TVM_name.txt
echo -e "\n   Please input the Number of [TVM model and Target Environment Name] to select : \n"
#-------------选择基础测试 ？中的某一个子集进行遍历测试-----
read number_TVM_model
ISA_TVM_testcase=$(sed -n "$number_TVM_model p" $TVM_test/TVM_name.txt)
echo -e "\n \t 1   Test way : \t all \n"
echo -e "\n \t 2   Test way : \t single  \n"
echo -e "\n Please select the Way to Test: \n"
timer_start=`date "+%Y-%m-%d %H:%M:%S"`
read number_all
if [ $number_all -eq 1 ]
  then
  if [ $number -eq 1 ] || [ $number -eq 2 ]
    then
            rm -rf $out_dir/Result/Result_funct/*
            rm -rf $out_dir/Report/Report_funct.txt 
            mkdir -p $out_dir/Result/Result_funct
            touch $out_dir/Report/Report_funct.txt
            count_test=1
            while read list_testcase
            do
                #-------------------pass-------------------------
                    #-------------将dump测试反汇编文件中的pass字段提取出来，将对应的地址写进pass文件中
                    grep "<pass>:" $test_dir/$ISA_TVM_testcase/dump/"$list_testcase".* | gawk '{print $1}' > $test_dir/$ISA_TVM_testcase/passpc_$list_testcase.txt 
                    #-------------将pass文件内的数据赋值给变量pass，以供后续使用   
                    pass=$(cat $test_dir/$ISA_TVM_testcase/passpc_$list_testcase.txt) 
                #--------------------fail------------------------
                    #-------------将dump测试反汇编文件中的fail字段提取出来，将对应的地址写进fail文件中
                    grep "<fail>:" $test_dir/$ISA_TVM_testcase/dump/"$list_testcase".* | gawk '{print $1}' > $test_dir/$ISA_TVM_testcase/failpc_$list_testcase.txt 
                    #-------------将fail文件内的数据赋值给变量fail，以供后续使用     
                    fail=$(cat $test_dir/$ISA_TVM_testcase/failpc_$list_testcase.txt)   
                #----------使用不同的TbAll样例，针对不同的仿真工具进行替换文本    
                if [ $EDA_env_dir_number -eq 2 ]
                    then                                    
                    #-------------将pass变量中的pc值赋给断言中的对应地址
                    sed -ne 'p;/Pass_PC;/n' $isa_test_dir/TbAll_standard_assert.txt > $isa_test_dir/TbAll_tmp.txt
                    sed "/property Pass_PC;/a\  @(posedge clk) IFID_NowPC_value (32'h$pass) |=>##1 IFID_NowPC_value (32'h$pass+32'h8);" $isa_test_dir/TbAll_tmp.txt > $isa_test_dir/TbAll_tmp_pass.txt                   
                    #-------------将fail变量中的pc值赋给断言中的对应地址  
                    sed -ne 'p;/Fail_PC;/n' $isa_test_dir/TbAll_tmp_pass.txt > $isa_test_dir/TbAll_tmp2.txt
                    sed "/property Fail_PC;/a\  @(posedge clk) IFID_NowPC_value (32'h$fail) |=>##1 IFID_NowPC_value (32'h$fail+32'h8);"  $isa_test_dir/TbAll_tmp2.txt >  $src_dir/top/TbAll.sv    
                    sed "s/6F F0 9F FF/6F 00 C0 09/" $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase > $EDA_env_dir/Instructions.list    
                elif [ $EDA_env_dir_number -eq 1 ]
                    then
                    sed -ne 'p;/pass_pc_addr/n' $isa_test_dir/TbAll_iverilog_funct.txt > $isa_test_dir/TbAll_tmp.txt
                    sed "/pass_pc_addr/a\  parameter pass_pc=32'h$pass ;" $isa_test_dir/TbAll_tmp.txt > $isa_test_dir/TbAll_tmp_pass.txt
                    sed -ne 'p;/fail_pc_addr/n' $isa_test_dir/TbAll_tmp_pass.txt > $isa_test_dir/TbAll_tmp2.txt
                    sed "/fail_pc_addr/a\  parameter fail_pc=32'h$fail ;" $isa_test_dir/TbAll_tmp2.txt > $src_dir/top/TbAll.sv
                    cat $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase > $EDA_env_dir/Instructions.list
                fi
                $EDATool_run_dir
                echo -e "Test $list_testcase is running \n"
                #------------将产生的日志文件复制到result文件夹中
                cp $EDA_env_dir/mySim.log  $out_dir/Result/Result_funct/$list_testcase.log
                rm -rf $test_dir/$ISA_TVM_testcase/passpc_$list_testcase.txt 
                rm -rf $test_dir/$ISA_TVM_testcase/failpc_$list_testcase.txt 
                rm -rf $isa_test_dir/TbAll_tmp.txt
                rm -rf $isa_test_dir/TbAll_tmp_pass.txt 
                rm -rf $isa_test_dir/TbAll_tmp2.txt
                let count_test++
            done < $test_dir/$ISA_TVM_testcase/testcase_list.txt
            mkdir -p $out_dir/Report
            ls $out_dir/Result/Result_funct > $out_dir/Report/Report_funct_list.txt
            count_report=1
            while read line_report                           #读取list的每一行
            do
                #-------------将每个测试文件中的ISA_test关键字找出来赋值给变量
                Report1=$(grep "ISA_test" $out_dir/Result/Result_funct/$line_report)              
                #-------------将测试文件名称以及关键字段打印到report中
                echo -e "\n" >> $out_dir/Report/Report_funct.txt
                echo "$line_report" >> $out_dir/Report/Report_funct.txt   
                echo -e "\n" >> $out_dir/Report/Report_funct.txt  
                echo "$Report1" >> $out_dir/Report/Report_funct.txt   
                echo -e "\n" >> $out_dir/Report/Report_funct.txt  
                let count_report++
            done < $out_dir/Report/Report_funct_list.txt    #读取list的每一行
            #------------将report的结果重新排列整理为按列对齐
            cat $out_dir/Report/Report_funct.txt  | column -t  > $out_dir/Report/Report_funct_New.txt      
            rm -rf $out_dir/Report/Report_funct.txt
            mv $out_dir/Report/Report_funct_New.txt  $out_dir/Report/Report_funct.txt
            gedit $out_dir/Report/Report_funct.txt
  elif [ $number -eq 3 ] || [ $number -eq 4 ]
    then
            rm -rf $out_dir/Result/Result_compliance/*
            rm -rf $out_dir/Report/Report_compliance.txt 
            mkdir -p $out_dir/Result/Result_compliance
            mkdir -p $out_dir/Report
            count_test=1
            touch $out_dir/Report/Report_compliance.txt
            while read list_testcase
            do                
                begin_sign=$(grep "<begin_signature>:" $test_dir/$ISA_TVM_testcase/dump/"$list_testcase".* | gawk '{print $1}')
                end_sign=$(grep "<end_signature>:" $test_dir/$ISA_TVM_testcase/dump/"$list_testcase".* | gawk '{print $1}')
                sed -ne 'p;/\/\/input compliance data start/n' $isa_test_dir/TbAll_self_assert_compliance.txt > $isa_test_dir/TbAll_tmp.txt
                sed "/\/\/input compliance data start/a\ begin_signature_in = 32'h$begin_sign;end_signature_in = 32'h$end_sign;" $isa_test_dir/TbAll_tmp.txt > $src_dir/top/TbAll.sv
                cat $test_dir/$ISA_TVM_testcase/verilogtxt/$list_testcase > $EDA_env_dir/Instructions.list 
                $EDATool_run_dir
                cp $EDA_env_dir/mySim.log $out_dir/Result/Result_compliance/$list_testcase.log
                diff  $test_dir/$ISA_TVM_testcase/signature/"$list_testcase".* $out_dir/Result/Result_compliance/$list_testcase.log
                if  [ $? -eq 0 ]
                  then 
                    echo -e "$list_testcase \tPass" >> $out_dir/Report/Report_compliance.txt
                elif [ $? -eq 1 ] 
                  then 
                    echo -e "$list_testcase \tFail" >> $out_dir/Report/Report_compliance.txt 
                else 
                    echo "Wrong"
                fi               
                rm -rf $isa_test_dir/TbAll_tmp.txt
               let count_test++
            done < $test_dir/$ISA_TVM_testcase/testcase_list.txt
            cat $out_dir/Report/Report_compliance.txt  | column -t  > $out_dir/Report/report_compliance_1.txt  
            rm -rf $out_dir/Report/Report_compliance.txt
            mv $out_dir/Report/report_compliance_1.txt $out_dir/Report/Report_compliance.txt
            gedit $out_dir/Report/Report_compliance.txt 
  else
    echo "Wrong"
  fi
elif [ $number_all -eq 2 ]
  then
    if [ $number -eq 1 ] || [ $number -eq 2 ]
    then
            rm -rf $out_dir/Result/Result_funct_self/*
            mkdir -p $out_dir/Result/Result_funct_self
            cat -n  $test_dir/$ISA_TVM_testcase/testcase_list.txt
            echo -e "\n \t Please select the single instruction test file to test : \n"
            #------------输入需要进行单独测试的文件编号-----------
            read number_test_once
            #------------根据输入的编号进入list.txt文件查找对应的名称----------------
            single_test_name=$(sed -n "$number_test_once p" $test_dir/$ISA_TVM_testcase/testcase_list.txt)
        #-------------------pass-------------------------
            #------------将dump测试反汇编文件中的pass字段提取出来，将对应的地址写进pass文件中
            grep "<pass>:" $test_dir/$ISA_TVM_testcase/dump/"$single_test_name".* | gawk '{print $1}' > $test_dir/$ISA_TVM_testcase/passpc_$single_test_name.txt 
            #------------将pass文件内的数据赋值给变量pass，以供后续使用   
            pass=$(cat $test_dir/$ISA_TVM_testcase/passpc_$single_test_name.txt )
        #--------------------fail------------------------
            #------------将dump测试反汇编文件中的fail字段提取出来，将对应的地址写进fail文件中
            grep "<fail>:" $test_dir/$ISA_TVM_testcase/dump/"$single_test_name".* | gawk '{print $1}' > $test_dir/$ISA_TVM_testcase/failpc_$single_test_name.txt 
            #------------将fail文件内的数据赋值给变量fail，以供后续使用            
            fail=$(cat $test_dir/$ISA_TVM_testcase/failpc_$single_test_name.txt)             
            if [ $EDA_env_dir_number -eq 2 ] 
                then
                    #------------将pass变量中的pc值赋给断言中的对应地址
                    sed -ne 'p;/Pass_PC;/n' $isa_test_dir/TbAll_self_assert.txt > $isa_test_dir/TbAll_tmp.txt
                    sed "/property Pass_PC;/a\  @(posedge clk) IFID_NowPC_value (32'h$pass) |=>##1 IFID_NowPC_value (32'h$pass+32'h8);" $isa_test_dir/TbAll_tmp.txt > $isa_test_dir/TbAll_tmp_pass.txt                       
                    #------------将fail变量中的pc值赋给断言中的对应地址
                    sed -ne 'p;/Fail_PC;/n' $isa_test_dir/TbAll_tmp_pass.txt > $isa_test_dir/TbAll_tmp2.txt
                    sed "/property Fail_PC;/a\  @(posedge clk) IFID_NowPC_value (32'h$fail) |=>##1 IFID_NowPC_value (32'h$fail+32'h8);"  $isa_test_dir/TbAll_tmp2.txt >  $src_dir/top/TbAll.sv    
                    sed "s/6F F0 9F FF/6F 00 C0 09/" $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name > $EDA_env_dir/Instructions.list
            elif [ $EDA_env_dir_number -eq 1 ]
                then
                    sed -ne 'p;/pass_pc_addr/n' $isa_test_dir/TbAll_iverilog_funct.txt > $isa_test_dir/TbAll_tmp.txt
                    sed "/pass_pc_addr/a\  parameter pass_pc=32'h$pass ;" $isa_test_dir/TbAll_tmp.txt > $isa_test_dir/TbAll_tmp_pass.txt
                    sed -ne 'p;/fail_pc_addr/n' $isa_test_dir/TbAll_tmp_pass.txt > $isa_test_dir/TbAll_tmp2.txt
                    sed "/fail_pc_addr/a\  parameter fail_pc=32'h$fail ;" $isa_test_dir/TbAll_tmp2.txt >  $src_dir/top/TbAll.sv
                    cat $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name > $EDA_env_dir/Instructions.list
            fi            
            $EDATool_run_dir
            rm -rf $test_dir/$ISA_TVM_testcase/passpc_$list_testcase.txt 
            rm -rf $test_dir/$ISA_TVM_testcase/failpc_$list_testcase.txt 
            rm -rf $isa_test_dir/TbAll_tmp.txt
            rm -rf $isa_test_dir/TbAll_tmp_pass.txt 
            rm -rf $isa_test_dir/TbAll_tmp2.txt
            echo -e "Test $single_test_name is running \n"
            cp $EDA_env_dir/mySim.log $out_dir/Result/Result_funct_self/$single_test_name.txt
            gedit $out_dir/Result/Result_funct_self/$single_test_name.txt
    elif [ $number -eq 3 ] || [ $number -eq 4 ]
      then
            rm -rf $out_dir/Result/Result_compliance_self/*
            mkdir -p $out_dir/Result/Result_compliance_self
            cat -n  $test_dir/$ISA_TVM_testcase/testcase_list.txt
            echo -e "\n \t Please select the single instruction test file to test : \n"
            #-----------输入需要进行单独测试的文件编号-----------
            read number_test_once
            #------------根据输入的编号进入list.txt文件查找对应的名称----------------
            single_test_name=$(sed -n "$number_test_once p" $test_dir/$ISA_TVM_testcase/testcase_list.txt)
            begin_sign=$(grep "<begin_signature>:" $test_dir/$ISA_TVM_testcase/dump/"$single_test_name".* | gawk '{print $1}')
            end_sign=$(grep "<end_signature>:" $test_dir/$ISA_TVM_testcase/dump/"$single_test_name".* | gawk '{print $1}')
            sed -ne 'p;/\/\/input compliance data start/n' $isa_test_dir/TbAll_self_assert_compliance.txt > $isa_test_dir/TbAll_tmp.txt
            sed "/\/\/input compliance data start/a\ begin_signature_in = 32'h$begin_sign;end_signature_in = 32'h$end_sign;" $isa_test_dir/TbAll_tmp.txt > $src_dir/top/TbAll.sv
            cat $test_dir/$ISA_TVM_testcase/verilogtxt/$single_test_name > $EDA_env_dir/Instructions.list 
            $EDATool_run_dir
            diff  $test_dir/$ISA_TVM_testcase/signature/"$single_test_name".* $EDA_env_dir/mySim.log
            if  [ $? -eq 0 ]
              then 
                echo -e "$single_test_name \tPass" > $out_dir/Result/Result_compliance_self/$single_test_name.txt
            elif [ $? -eq 1 ] 
              then 
                echo -e "$single_test_name \tFail" > $out_dir/Result/Result_compliance_self/$single_test_name.txt 
            else 
                echo "Wrong"
            fi
            gedit $out_dir/Result/Result_compliance_self/$single_test_name.txt 
            rm -rf $isa_test_dir/TbAll_tmp.txt
    else
      echo "Wrong"
    fi
else
  echo "Wrong number!"
fi
timer_end=`date "+%Y-%m-%d %H:%M:%S"`
echo -e "\n $timer_start \n"
echo -e "\n $timer_end \n"