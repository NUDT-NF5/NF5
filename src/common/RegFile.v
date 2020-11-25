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
	output	[`SIMD_DATA_WIDTH - 1 : 0]	rData1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr2,
	output	[`SIMD_DATA_WIDTH - 1 : 0]	rData2,
	input	[`RF_ADDR_WIDTH - 1 : 0]	rAddr3,
	output	[`SIMD_DATA_WIDTH - 1 : 0]	rData3,
	input 								simd_ena,
	input                               horizontal,
	input   [`SIMD_WIDTH - 1 : 0]       simd_ctl,

	input								wEN,
	input	[`RF_ADDR_WIDTH - 1 : 0]	wAddr,
	input	[`SIMD_DATA_WIDTH - 1 : 0]	wData
);
	reg [`SIMD_DATA_WIDTH - 1 : 0] regFiles [0 : `RF_NUMBER - 1];
	
	assign	rData1 = regFiles[rAddr1];
	assign	rData2 = regFiles[rAddr2];
	assign	rData3 = regFiles[rAddr3];

	integer i;
	always @(posedge clk)
    	if(~rst_n)
          for(i = 0 ; i < `RF_NUMBER ;i = i + 1)
			regFiles[i] <= `SIMD_DATA_WIDTH'b0;
		else if(wEN && (wAddr != 0))
			if(horizontal && simd_ena)
				case (simd_ctl)
					`SIMD16: begin
						regFiles[wAddr]     <= {{48{1'b0}}, wData[15:0]};
						regFiles[wAddr + 1] <= {{48{1'b0}}, wData[31:16]};
						regFiles[wAddr + 2] <= {{48{1'b0}}, wData[47:32]};
						regFiles[wAddr + 3] <= {{48{1'b0}}, wData[63:48]};
						regFiles[0] <= `SIMD_DATA_WIDTH'b0;
					end
					`SIMD32: begin
						regFiles[wAddr]     <= {{32{1'b0}}, wData[31:0]};
						regFiles[wAddr + 1] <= {{32{1'b0}}, wData[63:32]};
						regFiles[0] <= `SIMD_DATA_WIDTH'b0;
					end
					default: regFiles[wAddr] <= wData;
				endcase
			else
				regFiles[wAddr] <= wData;

endmodule