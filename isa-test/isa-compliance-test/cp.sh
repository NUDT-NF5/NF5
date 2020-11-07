path=./
files=$(find $path -name "rv*")
for filename in $files
do
   if [ -d "$filename" ]; then
      cd "$filename" && cp -r TB_compliance/ TB_iverilog_compliance/
      cd ../..
   else
      continue
   fi
done