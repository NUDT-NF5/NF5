filelist.v

//Turn on Read, Write and / or Connectivity Access
+access+rw

//Suppresses timing checks and path delays in specify blocks.
//ignore sdf annotations
+nospecify

//Bring up the Graphical User Interface
//gui
+run
+sv
+assert

//invoke 64bit verion
//+nc64bit

//+nosdfwarn
+ncnowarn+CUNGL1
+ncnowarn+NONPRT


+nccoverage+all
+tcl+test.tcl

//updata coverage info
+nccovoverwrite

//+nctop+example_tester
+nccovdut+TbAll

+nccovtest+xor_salsa8

//optional test name used to combined coverage
//use the option of test.tcl file
+nccovfile+test.tcl
