
# NC-Sim Command File
# TOOL:	ncsim	09.20-s022
#
#
# You can restore this configuration with:
#
#      ncverilog -f run_nc.f +tcl+/home/vlsi/Desktop/NF5/SystemNCexampleProject/ecall.tcl
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level never
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 1
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
alias . run
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves TbAll.i_Core.i_Csr.csr_mtvec_wen TbAll.i_Core.i_Csr.csr_mtvec_q TbAll.i_Core.i_Csr.csr_mtvec_d TbAll.i_Core.i_Csr.csr_op1 TbAll.i_Core.i_Csr.csr_op2 TbAll.i_Core.i_Csr.rst_n TbAll.i_Core.i_Csr.clk TbAll.i_Core.i_Csr.IDEX_NowPC {TbAll.i_Core.i_RegFile.regFiles[5]} TbAll.i_Core.i_Csr.csr_satp_q TbAll.i_Core.i_Csr.csr_satp_d TbAll.i_Core.i_Csr.csr_satp_wen TbAll.i_Core.i_Csr.csr_mepc_d TbAll.i_Core.i_Csr.csr_mepc_nxt TbAll.i_Core.i_Csr.csr_mepc_q TbAll.i_Core.i_Csr.csr_mepc_wen TbAll.i_Core.i_Csr.Decode_Flush TbAll.i_Core.i_Csr.EX_BranchFlag TbAll.i_Core.i_Csr.Csr_Evec TbAll.i_Core.i_Ctrl.Flush TbAll.i_Core.i_Fetch.Fetch_NextPC TbAll.i_Core.i_Csr.IFID_NowPC TbAll.i_ImmGenMux.io_inst TbAll.i_ImmGenMux.io_out TbAll.i_Core.i_EX.EX_BranchPC TbAll.i_Core.i_Decode.IFID_Instr TbAll.i_Core.i_Dcache.data
probe -create -database waves TbAll.i_Core.i_EX.Wb_DataWrt TbAll.i_Core.i_EX.comparator_s2 TbAll.i_Core.i_EX.comparator_s1 TbAll.i_Core.i_EX.comparator_result TbAll.i_Core.i_EX.ucomparator_result TbAll.i_Core.i_EX.EX_AluData
probe -create -database waves TbAll.i_Core.i_EX.forward_rs1 TbAll.i_Core.i_EX.forward_rs2

simvision -input /home/vlsi/Desktop/NF5/SystemNCexampleProject/ecall.tcl.svcf
