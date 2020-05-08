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
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr1,
	output	[`DATA_WIDTH - 1 : 0]		rData1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr2,
	output	[`DATA_WIDTH - 1 : 0]		rData2,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr3,
	output	[`DATA_WIDTH - 1 : 0]		rData3,

	input								wEN,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr,
	input	[`DATA_WIDTH - 1 : 0]		wData
);
	reg [`DATA_WIDTH - 1 : 0] regFiles [0 : `RF_NUMBER - 1];
	
	assign	rData1 = regFiles[rAddr1];
	assign	rData2 = regFiles[rAddr2];
	assign	rData3 = regFiles[rAddr3];

	integer i;
	always @(posedge clk)
    	if(~rst_n)
          for(i = 0 ; i < `RF_NUMBER ;i = i + 1)
			regFiles[i] <= 0;
		else if(wEN && (wAddr != 0))
			regFiles[wAddr] <= wData;

endmodule