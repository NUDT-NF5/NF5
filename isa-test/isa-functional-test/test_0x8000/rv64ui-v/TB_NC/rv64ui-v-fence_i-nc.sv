//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Thu Apr 30 17:04:16 2020
//Host        : YUANBO-THN114 running 64-bit major release  (build 9200)
//Command     : generate_target system_test_wrapper.bd
//Design      : system_test_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`include "../src/common/Define.v"
module	TbAll;
	reg								clk;
	reg								rst_n;
	//global use
	reg 		[10 - 1 :0] 		task_num;
	reg 		[32 - 1 : 0]		clk_count;
	// for log file
	integer 							fd;
	//simple verification for all module

	//pass
	Core i_Core(
		.clk(clk),
		.rst_n(rst_n)
	);	
	reg         [32 - 1 : 0]		data_reg 	[0 : 4*4096];
	integer j;
	initial begin		
		clk <= 0;
		clk_count <= 0;
		rst_n <= 0;
		#2;
		rst_n <= 1;
		//for data transform	
		$readmemh("Instructions.list", data_reg);
		
		for (j=0;j<4096;j=j+1)  begin
			i_Core.i_Dcache.data [j] [8*0+:8]= data_reg[j*4+0];
			i_Core.i_Dcache.data [j] [8*1+:8]= data_reg[j*4+1];
			i_Core.i_Dcache.data [j] [8*2+:8]= data_reg[j*4+2];
			i_Core.i_Dcache.data [j] [8*3+:8]= data_reg[j*4+3];
			end	
	end

	initial begin
		fd = $fopen ("mySim.log", "w");
		$fdisplay(fd,"====== NF5 sim start ======");
		#3000;
		$fdisplay(fd,"====== NF5 sim finish ======");
		$finish;
		// Close this file handle
		$fclose(fd);
	end

	always	#1 clk = ~clk;	
	always @(posedge clk) 
		begin
			clk_count <= clk_count + 1;
			$fdisplay (fd, "clk = %0d", clk_count);
		end
//Test Program  Chek
sequence IFID_NowPC_value(pass_pc);
    i_Core.IFID_NowPC_0 == pass_pc;
endsequence

property Pass_PC;
  @(posedge clk) IFID_NowPC_value (32'h0000000080002be8) |=>##1 IFID_NowPC_value (32'h0000000080002be8+32'h8);

endproperty

property Fail_PC;
  @(posedge clk) IFID_NowPC_value (32'h0000000080002bd8) |=>##1 IFID_NowPC_value (32'h0000000080002bd8+32'h8);

endproperty

assert property (Pass_PC)	$fdisplay (fd, "ISA_test Pass when clk=%d, PC=%h ",clk_count,i_Core.IFID_NowPC_0); 
assert property (Fail_PC)	$fdisplay (fd, "ISA_test Fail when clk=%d, PC=%h ",clk_count,i_Core.IFID_NowPC_0);
assert property (Pass_PC) #15 $finish;
assert property (Fail_PC) #15 $finish;
/*
initial
        begin            
            $dumpfile("test.vcd");
            $dumpvars(0,TbAll);
        end
*/
endmodule
