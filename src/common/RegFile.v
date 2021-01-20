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
	output	[`SIMD_DATA_WIDTH - 1 : 0]	rData1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr2,
	output	[`SIMD_DATA_WIDTH - 1 : 0]	rData2,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr3,
	output	[`SIMD_DATA_WIDTH - 1 : 0]	rData3,
	input                               horizontal,
	input   [`SIMD_WIDTH - 1 : 0]       simd_ctl,
	input                               rd_high,

	input								wEN1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr1,
	input	[`SIMD_DATA_WIDTH - 1 : 0]	wData1,
	input 								simd_ena1,

	input								wEN2,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr2,
	input	[`SIMD_DATA_WIDTH - 1 : 0]	wData2,
	input 								simd_ena2
);
	reg     [`DATA_WIDTH - 1 : 0]       regFiles [0 : `RF_NUMBER*2 - 1];

    wire    [`RF_ADDR_WIDTH : 0]        true_rAddr1   = {rAddr1, 1'b0};
    wire    [`RF_ADDR_WIDTH : 0]        true_rAddr1_h = {rAddr1, 1'b1};
    wire    [`RF_ADDR_WIDTH : 0]        true_rAddr2   = {rAddr2, 1'b0};
    wire    [`RF_ADDR_WIDTH : 0]        true_rAddr2_h = {rAddr2, 1'b1};
    wire    [`RF_ADDR_WIDTH : 0]        true_rAddr3   = {rAddr3, 1'b0};
    wire    [`RF_ADDR_WIDTH : 0]        true_rAddr3_h = {rAddr3, 1'b1};
    wire    [`RF_ADDR_WIDTH : 0]        true_wAddr1    = {wAddr1,  1'b0};
    wire    [`RF_ADDR_WIDTH : 0]        true_wAddr_h1  = {wAddr1,  1'b1};
	wire    [`RF_ADDR_WIDTH : 0]        true_wAddr2    = {wAddr2,  1'b0};
    wire    [`RF_ADDR_WIDTH : 0]        true_wAddr_h2  = {wAddr2,  1'b1};
	
	wire   wEn1   = wEN1 && ~(Csr_Mcause == 'h6 && Csr_ExcpFlag);
	wire   wEn2   = wEN2;

    assign rData1 = simd_ena1 ? {regFiles[true_rAddr1_h], regFiles[true_rAddr1]} : 
                    rd_high   ? {32'b0, regFiles[true_rAddr1_h]}                :
                                {32'b0, regFiles[true_rAddr1]};
	assign rData2 = simd_ena1 ? {regFiles[true_rAddr2_h], regFiles[true_rAddr2]} : 
                    rd_high   ? {32'b0, regFiles[true_rAddr2_h]}                :
                                {32'b0, regFiles[true_rAddr2]};
    assign rData3 = simd_ena1 ? {regFiles[true_rAddr3_h], regFiles[true_rAddr3]} : 
                    rd_high   ? {32'b0, regFiles[true_rAddr3_h]}                :
                                {32'b0, regFiles[true_rAddr3]};

	integer i;
	always @(posedge clk)
    	if(~rst_n)
          for(i = 0 ; i < `RF_NUMBER*2 ;i = i + 1)
			regFiles[i] <= `SIMD_DATA_WIDTH'b0;
		else if(wEn1 && wEn2 && (wAddr1 != 0) && (wAddr2 != 0)) begin
			if(simd_ena2)begin
				regFiles[true_wAddr2]   <= wData2[`DATA_WIDTH - 1 : 0];
				regFiles[true_wAddr_h2] <= wData2[`DATA_WIDTH+:`DATA_WIDTH];
			end
			else begin
				regFiles[true_wAddr2] <= wData2[`DATA_WIDTH - 1 : 0];
			end
			if(simd_ena1)begin
				regFiles[true_wAddr1]   <= wData1[`DATA_WIDTH - 1 : 0];
				regFiles[true_wAddr_h1] <= wData1[`DATA_WIDTH+:`DATA_WIDTH];
			end
			else
				regFiles[true_wAddr1] <= wData1[`DATA_WIDTH - 1 : 0];
		end
		else if(wEn1 && (wAddr1 != 0))
			if(simd_ena1)begin
				regFiles[true_wAddr1]   <= wData1[`DATA_WIDTH - 1 : 0];
				regFiles[true_wAddr_h1] <= wData1[`DATA_WIDTH+:`DATA_WIDTH];
			end
			else
				regFiles[true_wAddr1] <= wData1[`DATA_WIDTH - 1 : 0];
		else if(wEn2 && (wAddr2 != 0))
			if(simd_ena2)begin
				regFiles[true_wAddr2]   <= wData2[`DATA_WIDTH - 1 : 0];
				regFiles[true_wAddr_h2] <= wData2[`DATA_WIDTH+:`DATA_WIDTH];
			end
			else
				regFiles[true_wAddr2] <= wData2[`DATA_WIDTH - 1 : 0];

endmodule