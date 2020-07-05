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
module PipeStage
#(
	parameter							STAGE_WIDTH=`INSTR_WIDTH,
	parameter                           ISSUE1_START=`INSTR_WIDTH
)
(
	input								clk,
	input								rst_n,
	input								Stall,
	input								Flush,
	input 								issue_select,
	input		[STAGE_WIDTH - 1 : 0]	in,
	output reg	[STAGE_WIDTH - 1 : 0]	out
);

always @(posedge clk)
	if(~rst_n)
		out <= 0;
	else if(Stall)
		out <= out;
	else if(Flush && issue_select)
		out[STAGE_WIDTH - 1:ISSUE1_START] <= 0;
	else if(Flush)
		out <= 0;
	else 
		out <= in;

endmodule
