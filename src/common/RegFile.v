/*
 * @Author: Sue
 * @Date:   2019-10-28 14:49
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-28 14:49
 * @Describe: read rs1 rs2 and write back rd
 * @ModuleParamDescribe: the Describe of module param
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module RegFile
(
	input 								clk,
	input 								rst_n,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr1_0,
	output	[`DATA_WIDTH - 1 : 0]		rData1_0,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr2_0,
	output	[`DATA_WIDTH - 1 : 0]		rData2_0,

	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr1_1,
	output	[`DATA_WIDTH - 1 : 0]		rData1_1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr2_1,
	output	[`DATA_WIDTH - 1 : 0]		rData2_1,
	
	input								wEN_0,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr_0,
	input	[`DATA_WIDTH - 1 : 0]		wData_0,

	input								wEN_1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr_1,
	input	[`DATA_WIDTH - 1 : 0]		wData_1
);
	reg [`DATA_WIDTH - 1 : 0] regFiles [0 : `RF_NUMBER - 1];
	
	assign	rData1_0 = regFiles[rAddr1_0];
	assign	rData2_0 = regFiles[rAddr2_0];

	assign	rData1_1 = regFiles[rAddr1_1];
	assign	rData2_1 = regFiles[rAddr2_1];
	
	integer i;
	always @(posedge clk)
    	if(~rst_n)
          for(i = 0 ; i < `RF_NUMBER ;i = i + 1)
			regFiles[i] <= 0;
		else if(wEN_0 && wEN_1 && (wAddr_0 != 0) && (wAddr_0 != 0)) begin
			regFiles[wAddr_0] <= wData_0;
			regFiles[wAddr_1] <= wData_1;
		end
		else if(wEN_0 && (wAddr_0 != 0))
			regFiles[wAddr_0] <= wData_0;
		else if(wEN_1 && (wAddr_1 != 0))
			regFiles[wAddr_1] <= wData_1;

endmodule