/*
 * @Author: Sue
 * @Date:   2019-10-28 15:51
 * @Last Modified by: mikey.zhaopeng
 * @Last Modified time: 2019-11-07 14:52:01
 * @Describe: simple TB for all module
 */
`include "../src/common/Define.v"
module	TbAll;
	reg								clk;
	reg								rst_n;

	//global use
	reg 		[10 - 1 :0] 		task_num;
	reg 		[32 - 1 : 0]		clk_count;
	
	// for log file
	integer 							fd;
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
		$readmemh("Instructions.list", data_reg);		
		for (j=0;j<4096;j=j+1)  begin
			i_Core.i_Mem.cache.data [j] [8*0+:8]= data_reg[j*4+0];
			i_Core.i_Mem.cache.data [j] [8*1+:8]= data_reg[j*4+1];
			i_Core.i_Mem.cache.data [j] [8*2+:8]= data_reg[j*4+2];
			i_Core.i_Mem.cache.data [j] [8*3+:8]= data_reg[j*4+3];
			end
end
	initial begin
		fd = $fopen ("mySim.log", "w");
		$fdisplay(fd,"====== NF5 sim start ======");
		#1300;
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
//pass_pc_addr
  parameter pass_pc=32'h000005f0 ;
//fail_pc_addr
  parameter fail_pc=32'h000005dc ;

wire [31:0] ifidpc=i_Core.IFID_NowPC_0;
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
    else if (ifidpc < pass_pc)
      count_pass <= 0;
  end
 always@(posedge clk)
  begin
    if(ifidpc >= fail_pc)
      count_fail <= count_fail+1;
    else if (ifidpc < fail_pc)
      count_fail <= 0;
  end 
  
always@(posedge clk) 
    begin
        if((count_pass == 2)&&(ifidpc == pass_pc+'h8))
        begin
            $fdisplay (fd, "ISA_test Pass when clk=%d, PC=%h ",clk_count,ifidpc);
            #15 $finish;
        end
        else if((count_fail == 2)&&(ifidpc == fail_pc+'h8))
        begin
            $fdisplay (fd, "ISA_test Fail when clk=%d, PC=%h ",clk_count,ifidpc);
            #15 $finish;
        end
    end

initial
        begin            
            $dumpfile("test.vcd");
            $dumpvars(-1,TbAll);
        end


endmodule
