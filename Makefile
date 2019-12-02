base_dir = $(shell pwd)
test_dir = $(base_dir)/isa-test
nc_dir = $(base_dir)/nc-project
report_dir = $(nc_dir)/report
result_dir = $(nc_dir)/result
src_dir = $(base_dir)/src
output_dir = $(nc_dir)/output
iverilog_dir=$(base_dir)/iverilog-project
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
compile:
	#todo
sim_default:
	make gen_filelist
	bash $(iverilog_dir)/run_default

	
sim:	
	make gen_filelist	
	./isa_run.sh
 	
sim_gui_nc:
	make gen_filelist
	cd $(nc_dir) && bash $(nc_dir)/set_gui && cd -
	cd $(nc_dir) && bash $(nc_dir)/run_nc && cd -

sim_gui_gtk:
	make gen_filelist
	gtkwave $(iverilog_dir)/test.vcd
	
hardclean:
	@rm -rf xncsim *.shm *.log *.diag dumpdata.txt *.key .simvision INCA_libs filelist.v cov_work

clean: hardclean

all: compile sim

.PHONY:gen_filelist compile sim_gui hardclean clean all
