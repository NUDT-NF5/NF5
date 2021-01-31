//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Thu Apr 30 17:04:16 2020
//Host        : YUANBO-THN114 running 64-bit major release  (build 9200)
//Command     : generate_target system_test_wrapper.bd
//Design      : system_test_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
module	system_test_tb();
  reg clk;
  reg rst_n;

   NF5_System NF5_System_i
       (.clk_0(clk),
        .rst_n_0(rst_n));
	parameter depth = 'hFFFF+1;

	//global use
	reg 		[10 - 1 :0] 		task_num;
	reg 		[32 - 1 : 0]		clk_count;
	// for log file
	integer 							fd;

	//simple verification for all module
	
	//pass	
	reg         [8 - 1 : 0]		data_reg 	[0 : 4*depth-1];
	integer j;
	initial begin
		
		clk <= 0;
		clk_count <= 0;
		rst_n <= 1;
		#1
        	rst_n <= 0;
		#2;
		rst_n <= 1;
		//for data transform
		$readmemh("Instructions.list", data_reg);	   
	   	for (j=0;j<depth;j=j+1)  begin
			//system_test_i.SRAM_0.inst.memory [j] [7:0]  =data_reg[j*4+0];
			NF5_System_i.SRAM_0.inst.memory [j] [8*0+:8]= data_reg[j*4+0];
			NF5_System_i.SRAM_0.inst.memory [j] [8*1+:8]= data_reg[j*4+1];
			NF5_System_i.SRAM_0.inst.memory [j] [8*2+:8]= data_reg[j*4+2];
			NF5_System_i.SRAM_0.inst.memory [j] [8*3+:8]= data_reg[j*4+3];
		end	

	end

    wire [13:0] begin_signature;
    reg  [31:0] begin_signature_in;
    wire [13:0] end_signature;
    reg  [31:0] end_signature_in;
    initial begin
	//input compliance data start
 begin_signature_in = 32'h80002000;end_signature_in = 32'h80002060;
    end
    assign begin_signature = begin_signature_in[15:2];
    assign end_signature   = end_signature_in[15:2];	
	integer dxx;
	initial begin
		fd = $fopen ("mySim.log", "w");
		//$fdisplay(fd,"====== NF5 sim start ======");
		#9300
		for (dxx=begin_signature;dxx<end_signature;dxx=dxx+1)begin
		    $fdisplay(fd,"%h",NF5_System_i.SRAM_0.inst.memory[dxx]);
		    end        
        //$fdisplay(fd,"====== NF5 sim finish ======");
        $fclose(fd);
		$finish;
		// Close this file handle
		
	end

	always	#1 clk = ~clk;	
	always @(posedge clk) 
		begin
			clk_count <= clk_count + 1;
			//$fdisplay (fd, "clk = %0d", clk_count);
		end


endmodule
