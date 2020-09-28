/*
 * @Date:               2019-10-29 14:38
 * @Last Modified by:   Bo Yuan
 * @Last Modified time: 2019-10-29 14:38
 */
`include "../src/common/Define.v"
module Wb
(
    input  wire                       MemWb_WbSel,
    input  wire  [`DATA_WIDTH-1 :0]   MemWb_AluData,
    input  wire  [`DATA_WIDTH-1 :0]   MemWb_DataRd,
    output wire  [`DATA_WIDTH-1 :0]   Wb_DataWrt
    );

assign Wb_DataWrt = (MemWb_WbSel == `WB_ALU) ? MemWb_AluData : MemWb_DataRd;

endmodule