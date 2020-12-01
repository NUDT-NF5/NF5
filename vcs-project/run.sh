cd vcs-project && vcs -f filelist.v -sverilog +v2k -debug_all -l compile.log -full64 -assert svaext -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,-no-as-needed -timescale=1ns/1ps && ./simv
