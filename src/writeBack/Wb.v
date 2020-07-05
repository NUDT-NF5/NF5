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
    input  wire                       MemWb_WbSel_0,
    input  wire  [`DATA_WIDTH-1 :0]   MemWb_AluData_0,
    input  wire  [`DATA_WIDTH-1 :0]   MemWb_DataRd_0,
    output wire  [`DATA_WIDTH-1 :0]   Wb_DataWrt_0,

    input  wire                       MemWb_WbSel_1,
    input  wire  [`DATA_WIDTH-1 :0]   MemWb_AluData_1,
    input  wire  [`DATA_WIDTH-1 :0]   MemWb_DataRd_1,
    output wire  [`DATA_WIDTH-1 :0]   Wb_DataWrt_1
    );

assign Wb_DataWrt_0 = (MemWb_WbSel_0 == `WB_ALU) ? MemWb_AluData_0 : MemWb_DataRd_0;
assign Wb_DataWrt_1 = (MemWb_WbSel_1 == `WB_ALU) ? MemWb_AluData_1 : MemWb_DataRd_1;

endmodule