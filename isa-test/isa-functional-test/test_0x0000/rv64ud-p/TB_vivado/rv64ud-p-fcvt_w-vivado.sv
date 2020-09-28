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

module system_test_tb();
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

	initial begin
		fd = $fopen ("mySim.log", "w");
		$fdisplay(fd,"====== NF5 sim start ======");
		#9300;
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
/*
sequence IFID_NowPC_value(pass_pc);
    NF5_System_i.Core_0.inst.IFID_NowPC == pass_pc;
endsequence


property Pass_PC;
  @(posedge clk) IFID_NowPC_value (32'h800005f0) |=>##1 IFID_NowPC_value (32'h800005f0+32'h8);

endproperty

property Fail_PC;
  @(posedge clk) IFID_NowPC_value (32'h800005dc) |=>##1 IFID_NowPC_value (32'h800005dc+32'h8);

endproperty

assert property (Pass_PC)	$fdisplay (fd, "ISA_test Pass when clk=%d, PC=%h ",clk_count, NF5_System_i.Core_0.inst.IFID_NowPC); 
assert property (Fail_PC)	$fdisplay (fd, "ISA_test Fail when clk=%d, PC=%h ",clk_count, NF5_System_i.Core_0.inst.IFID_NowPC);
assert property (Pass_PC) #15 $finish;
assert property (Fail_PC) #15 $finish;*/

//Test Program  Chek
//pass_pc_addr
  parameter pass_pc=32'h0000000000000968 ;
//fail_pc_addr
  parameter fail_pc=32'h0000000000000954 ;

wire [31:0] ifidpc=NF5_System_i.Core_0.inst.IFID_NowPC;
reg  [31:0] count_pass;
reg  [31:0] count_fail;
initial
    begin
        count_pass =0;
    end
always@(posedge clk)
  begin
    if(ifidpc >= pass_pc)
      count_pass <= count_pass+1;
  end
 always@(posedge clk)
  begin
    if(ifidpc >= fail_pc)
      count_fail <= count_fail+1;
  end 
  
always@(posedge clk) 
    begin
        if((count_pass == 2)&&(ifidpc == pass_pc+'h8))
        begin
            $fdisplay (fd, "ISA_test Pass when clk=%d, PC=%h ",clk_count,ifidpc);
            $finish;
        end
        else if((count_fail == 2)&&(ifidpc == fail_pc+'h8))
        begin
            $fdisplay (fd, "ISA_test Fail when clk=%d, PC=%h ",clk_count,ifidpc);
            #15 $finish;
        end
    end

/*initial
        begin            
            $dumpfile("test.vcd");
            $dumpvars(0,system_test_tb);
        end*/

endmodule

