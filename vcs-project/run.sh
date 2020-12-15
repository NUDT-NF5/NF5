if [ $VERDI_HOME ];then
    cd vcs-project && vcs -f filelist.v -sverilog +v2k +memcbk -debug_acc+all -debug_region=cell+lib +define+DUMP_FSDB -l compile.log -full64 -assert svaext -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,-no-as-needed -timescale=1ns/1ps && ./simv
else
    cd vcs-project && vcs -f filelist.v -sverilog +v2k +memcbk -debug_acc+all -debug_region=cell+lib +define+DUMP_VCD -l compile.log -full64 -assert svaext -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,-no-as-needed -timescale=1ns/1ps && ./simv
fi
