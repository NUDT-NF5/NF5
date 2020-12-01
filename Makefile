base_dir = $(shell pwd)
test_dir = $(base_dir)/isa-test
nc_dir = $(base_dir)/nc-project
vcs_dir = $(base_dir)/vcs-project
report_dir = $(nc_dir)/report
result_dir = $(nc_dir)/result
src_dir = $(base_dir)/src
output_dir = $(nc_dir)/output
iverilog_dir=$(base_dir)/iverilog-project
soft_scripts=$(base_dir)/soft_proj/soft_scripts

soft_proj=soft_name #indicate software project directory name
temp:
	echo $(base_dir)
	echo $(base_dir)
	echo $(test_dir)
	echo $(report_dir)
	echo $(result_dir)
	echo $(script_dir)
	echo $(src_dir)
	
gen_filelist:
	@echo "=====generate filelist====="
	@find $(src_dir)/* -regex '.*\.v\|.*\.sv' | xargs perl $(nc_dir)/filelist_gen > $(nc_dir)/filelist.v
	@find $(src_dir)/* -regex '.*\.v\|.*\.sv' | xargs perl $(iverilog_dir)/filelist_gen > $(iverilog_dir)/filelist.v
	bash $(vcs_dir)/filelist_gen.sh

compile:
	#todo

reorder_filelist:
	bash $(nc_dir)/reorder.sh $(nc_dir)/filelist.v
	bash $(iverilog_dir)/reorder.sh $(iverilog_dir)/filelist.v
	bash $(vcs_dir)/reorder.sh

sim_default:
	make gen_filelist
	bash $(iverilog_dir)/run_default
	
sim:	
	make gen_filelist	
	make reorder_filelist
	bash isa_run.sh
 	
sim_gui_nc:
	make gen_filelist
	cd $(nc_dir) && bash $(nc_dir)/set_gui && cd -
	cd $(nc_dir) && bash $(nc_dir)/run_nc && cd -

sim_gui_gtk:
	make gen_filelist
	gtkwave $(iverilog_dir)/test.vcd
	
#==================For C project [how to use]======================: 
#1st step   make cproj_gen     soft_proj=helloword (#your C code name)
#2nd step   make cproj_compile soft_proj=helloword (#your C code name)
cproj_gen:
	bash $(soft_scripts)/make_C $(soft_proj)
	#bash $(soft_scripts)/soft_run.sh
cproj_compile:
	bash $(soft_scripts)/compile_C $(soft_proj)
	bash $(soft_scripts)/soft_run.sh

#==================For AS project [how to use]======================: 
#1st step   make asproj_gen     soft_proj=helloword (#your AS code name)
#2nd step   make asproj_compile soft_proj=helloword (#your AS code name)
asproj_gen:
	bash $(soft_scripts)/make_AS $(soft_proj)
	#bash $(soft_scripts)/soft_run.sh
asproj_compile:
	bash $(soft_scripts)/compile_AS $(soft_proj)
	bash $(soft_scripts)/soft_run.sh

hardclean:
	@rm -rf xncsim *.shm *.log *.diag dumpdata.txt *.key .simvision INCA_libs filelist.v cov_work vc_hdrs.h simv.daidir csrc ucli.key

clean: hardclean

all: compile sim

.PHONY:gen_filelist compile sim_gui hardclean clean all
