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
	parameter depth = 14'd16383+1;
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
	reg         [32 - 1 : 0]		data_reg 	[0 : 4*depth-1];
	integer j;
	initial begin		
		clk <= 0;
		clk_count <= 0;
		rst_n <= 0;
		#2;
		rst_n <= 1;
		//for data transform		
		$readmemh("Instructions.list", data_reg);
		for (j=0;j<depth;j=j+1)  begin
			i_Core.i_Dcache.data [j] [8*0+:8]= data_reg[j*4+0];
			i_Core.i_Dcache.data [j] [8*1+:8]= data_reg[j*4+1];
			i_Core.i_Dcache.data [j] [8*2+:8]= data_reg[j*4+2];
			i_Core.i_Dcache.data [j] [8*3+:8]= data_reg[j*4+3];
			end	
	end

    wire [13:0] begin_signature;
    reg  [31:0] begin_signature_in;
    wire [13:0] end_signature;
    reg  [31:0] end_signature_in;
    initial begin
	//input compliance data start
 begin_signature_in = 32'h80002140;end_signature_in = 32'h800021e0;
    end
    assign begin_signature = begin_signature_in[15:2];
    assign end_signature   = end_signature_in[15:2];	
	integer dxx;
	initial begin
		fd = $fopen ("mySim.log", "w");
		//$fdisplay(fd,"====== NF5 sim start ======");
		#3500
		for (dxx=begin_signature;dxx<end_signature;dxx=dxx+1)begin
            $fdisplay(fd,"%h",i_Core.i_Dcache.data[dxx]);
            end        
        //$fdisplay(fd,"====== NF5 sim finish ======");
		$finish;
		// Close this file handle
		$fclose(fd);
	end

	always	#1 clk = ~clk;	
	always @(posedge clk) 
		begin
			clk_count <= clk_count + 1;
			//$fdisplay (fd, "clk = %0d", clk_count);
		end

//Test Program  Chek
/*
sequence IFID_NowPC_value(pass_pc);
    i_Core.IFID_NowPC == pass_pc;
endsequence

property Pass_PC;
  @(posedge clk) IFID_NowPC_value (32'h000002f4) |=>##1 IFID_NowPC_value (32'h000002f4+32'h8);

endproperty

property Fail_PC;
  @(posedge clk) IFID_NowPC_value (32'h000002e0) |=>##1 IFID_NowPC_value (32'h000002e0+32'h8);

endproperty

assert property (Pass_PC)	$fdisplay (fd, "ISA_test Pass when clk=%d, PC=%h ",clk_count,i_Core.IFID_NowPC); 
assert property (Fail_PC)	$fdisplay (fd, "ISA_test Fail when clk=%d, PC=%h ",clk_count,i_Core.IFID_NowPC);
assert property (Pass_PC) #15 $finish;
assert property (Fail_PC) #15 $finish;
*/
/*
initial
        begin            
            $dumpfile("test.vcd");
            $dumpvars(0,TbAll);
        end
*/

endmodule
