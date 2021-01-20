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
module PipeStageMem
#(
	parameter							STAGE_WIDTH=`INSTR_WIDTH
)
(
	input								clk,
	input								rst_n,
	input								Stall,
	input								Flush,
    input       [`ST_TYPE_WIDTH - 1:0]  IDEX_StType,
    input       [`LD_TYPE_WIDTH - 1:0]  IDEX_LdType,
	input		[STAGE_WIDTH - 1 : 0]	in,
	output reg	[STAGE_WIDTH - 1 : 0]	out
);

always @(posedge clk)
	if(~rst_n)
		out <= 0;
	else if(Stall)
		out <= out;
	else if(Flush)
		out <= 0;
	else if(| {IDEX_StType, IDEX_LdType})
		out <= in;
    else
        out <= 0;

endmodule