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
//rst and flush with value
module PipeStage3
#(
	parameter							STAGE_WIDTH=`INSTR_WIDTH
)
(
	input								clk,
	input								rst_n,
	input		[STAGE_WIDTH - 1 : 0]	rst_value,
	input								Stall,
	input								Flush,
	input		[STAGE_WIDTH - 1 : 0]	in,
	output reg	[STAGE_WIDTH - 1 : 0]	out
);

always @(posedge clk)
	if(~rst_n)
		out <= rst_value;
	else if(Stall)
		out <= out;
	else if(Flush)
		out <= rst_value;
	else 
		out <= in;

endmodule
