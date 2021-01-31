/*
 * @Author: Sue
 * @Date:   2019-10-28 9:48
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-28 9:48
 * @Describe: general module 
 */
`include "../common/Define.v"
module Mux 
#(
	parameter SEL_WIDTH 	=  2,
	parameter SEL_NUM 		=  4,
	parameter DATA_WIDTH 	= `DATA_WIDTH,
	parameter DATA_WIDTH_LOG2 = `DATA_WIDTH_LOG2
)
(
    input 	[SEL_NUM * DATA_WIDTH - 1 : 0] 			in,
	input 	[SEL_WIDTH - 1 : 0] 					sel,//becaful with width
    output 	 [DATA_WIDTH - 1  : 0] 				out
);
	wire [SEL_WIDTH+DATA_WIDTH_LOG2-1 : 0] RSB;
	assign RSB = sel << DATA_WIDTH_LOG2;
	assign out = in[RSB +: DATA_WIDTH]; //must a latch here for rsb

endmodule