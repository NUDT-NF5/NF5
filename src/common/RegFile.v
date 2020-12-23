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
	input   [2:0]                       Csr_Mcause,
	input                               Csr_ExcpFlag,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr1,
	output	[`DATA_WIDTH - 1 : 0]		rData1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr2,
	output	[`DATA_WIDTH - 1 : 0]		rData2,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr3,
	output	[`DATA_WIDTH - 1 : 0]		rData3,

	input								wEN1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr1,
	input	[`DATA_WIDTH - 1 : 0]		wData1,

	input								wEN2,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr2,
	input	[`DATA_WIDTH - 1 : 0]		wData2
);
	reg [`DATA_WIDTH - 1 : 0] regFiles [0 : `RF_NUMBER - 1];
	
	assign	rData1 = regFiles[rAddr1];
	assign	rData2 = regFiles[rAddr2];
	assign	rData3 = regFiles[rAddr3];

	assign wEn1 = wEN1 && ~(Csr_Mcause == 'h6 && Csr_ExcpFlag);
	assign wEn2 = wEN2;

	integer i;
	always @(posedge clk)
    	if(~rst_n)
          for(i = 0 ; i < `RF_NUMBER ;i = i + 1)
			regFiles[i] <= 0;
		else if(wEn1 && wEn2 && (wAddr1 != 0) && (wAddr2 != 0)) begin
			regFiles[wAddr2] <= wData2;
			regFiles[wAddr1] <= wData1;
		end
		else if(wEn1 && (wAddr1 != 0))
			regFiles[wAddr1] <= wData1;
		else if(wEn2 && (wAddr2 != 0))
			regFiles[wAddr2] <= wData2;

endmodule