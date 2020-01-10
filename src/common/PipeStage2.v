/*
 * @Author: Sue
 * @Date:   2019-10-28 9:48
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-28 9:48
 * @Describe: common pipeline module
 * @ModuleParamDescribe: STAGE_WIDTH is stage datawidth
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module PipeStage2
#(
	parameter							STAGE_WIDTH=`INSTR_WIDTH
)
(
	input								clk,
	input								rst_n,
	input								Stall,
	input								Flush,
	input								fence,
	input		[STAGE_WIDTH - 1 : 0]	in,
	output reg	[STAGE_WIDTH - 1 : 0]	out
);

always @(posedge clk)
	if(~rst_n)
		out <= 0;
	else if(Flush)
		out <= 0;
	else if(fence)
		out <= 0;
	else if(Stall)
		out <= out;
	else 
		out <= in;

endmodule
