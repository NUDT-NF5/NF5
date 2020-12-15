if [ $VERDI_HOME ];then
    cd vcs-project && verdi +v2k -sverilog -f filelist.v -ssf test.fsdb
else
    cd vcs-project && gtkwave test.vcd
fi