#!/bin/bash
cd vcs-project

# package_name=(fpnew_pkg assertions registers defs_div_sqrt_mvp)
# 
# for element in ${package_name[@]}
#     do
#         linenum=$(cat filelist.v | grep -n ${element} | awk -F ":" '{print $1}')
#         # echo "$linenum"
#         line=$(sed -n ${linenum}p filelist.v)
#         # echo "$line"
#         sed -i '/'${element}'.sv/d' filelist.v
#         sed -i '1i\'$line'' filelist.v
#     done
