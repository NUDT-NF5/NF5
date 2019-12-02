/*
 * @Author: Sue
 * @Date:   2019-10-28 8:29
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-28 8:29
 * @Describe: fetch instruction from Icache and send it to IFID module
 * @ModuleParamDescribe: the Describe of module param
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module Fetch(
	input								clk,
	input								rst_n,
	input								Stall,
	//IFID <-> Fetch
	input		[`ADDR_WIDTH - 1 : 0]	IFID_NowPC,
	output	reg	[`ADDR_WIDTH - 1 : 0]	Fetch_NextPC,
	//Ctrl -> Fetch
	input								Ctrl_ExcpFlag,
	input		[`ADDR_WIDTH - 1 : 0]	Ctrl_ExcpPC,
	//EX -> Fetch
	input								EX_BranchFlag,
	input		[`ADDR_WIDTH - 1 : 0]	EX_BranchPC,
	//Decode -> Fetch
	input								Decode_16BitFlag

);
		
//PC_select: generate NextPC by prority
	always @(posedge clk)//if slack < 0 ,change to negedge
		if(~rst_n)
			Fetch_NextPC <= `START_PC;
		else if(Stall)
			Fetch_NextPC <= Fetch_NextPC;
		else if(EX_BranchFlag)
			Fetch_NextPC <= EX_BranchPC;
        else if(Ctrl_ExcpFlag)
			Fetch_NextPC <= Ctrl_ExcpPC;
		else if(Decode_16BitFlag)
			Fetch_NextPC <= IFID_NowPC + 2;
		else
			Fetch_NextPC <= Fetch_NextPC + 4;
endmodule
