/*
 * @Author: Y-BoBo
 * @Date:   2019-10-28 15:51
 * @Last Modified by: Y-BoBo
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: Writeback module
 */
`include "../src/common/Define.v"
module Wb
(
    input  wire                          MemWb_WbSel,
    input  wire  [`SIMD_DATA_WIDTH-1 :0] MemWb_AluData,
    input  wire  [`SIMD_DATA_WIDTH-1 :0] MemWb_DataRd,
    output wire  [`SIMD_DATA_WIDTH-1 :0] Wb_DataWrt
    );

assign Wb_DataWrt = (MemWb_WbSel == `WB_ALU) ? MemWb_AluData : MemWb_DataRd;

endmodule