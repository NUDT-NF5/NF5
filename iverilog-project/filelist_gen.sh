#!/bin/bash
# get all filename in specified path

path=../src
files=$(find $path -name "*.v" -o -name "*.sv" -o -name "*.vhd")
for filename in $files
do
   if [ -d "$filename" ]; then
      continue
   else
      echo ""\`include ""\"$filename\""" >> filelist.v
   fi
done