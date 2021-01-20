#!/bin/bash

package_name=(Define fpnew_pkg assertions registers defs_div_sqrt_mvp)
path=$1
path2=$1.tmp
path3=$1.tmp2
touch ${path2}
: > ${path2}
touch ${path3}
: > ${path3}

for element in ${package_name[@]}
    do
        linenum=$(cat ${path} | grep -n ${element} | awk -F ":" '{print $1}')
        echo "linenum=$linenum"
        if [ -n "$(echo $linenum | sed -n "/^[0-9]\+$/p")" ];then 
            line=$(sed -n ${linenum}p ${path})
            sed -i '/'${element}'.v/d' ${path}
            sed -i '/'${element}'.sv/d' ${path}
            echo $line >> ${path2}
        else 
            continue 
        fi 
    done
 
cat ${path2} ${path} > ${path3}
rm ${path}
rm ${path2}
mv ${path3} ${path}