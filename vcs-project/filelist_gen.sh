#!/bin/bash
# get all filename in specified path
cd vcs-project
path=../src
true > filelist.v
files=$(find $path -name "*.v" -o -name "*.sv" -o -name "*.vhd" -o -name "*.svh")
for filename in $files
do
   if [ -d "$filename" ]; then
      continue
   else
      echo "$filename" >> filelist.v
   fi
done