/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: mux_aluinput  module
 */
module mux_aluinput(
    input                                IDEX_Sel1,
    input       [`SIMD_DATA_WIDTH - 1:0] forward_rs1,
    input       [`ADDR_WIDTH - 1:0]      IDEX_NowPC,
    input                                IDEX_Sel2,
    input       [`SIMD_DATA_WIDTH - 1:0] forward_rs2,
    input       [`DATA_WIDTH - 1:0]      IDEX_Imm,

    output      [`SIMD_DATA_WIDTH - 1:0] s1,
    output      [`SIMD_DATA_WIDTH - 1:0] s2
);

assign s1 = IDEX_Sel1 ? forward_rs1 : {{(`SIMD_DATA_WIDTH - `ADDR_WIDTH){1'b0}}, IDEX_NowPC};
assign s2 = IDEX_Sel2 ? forward_rs2 : {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, IDEX_Imm};

endmodule