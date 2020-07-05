/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: mux_aluinput  module
 */
module mux_aluinput(
    input              IDEX_Sel1_0,
    input       [31:0] forward_rs1_0,
    input       [31:0] IDEX_NowPC_0,
    input              IDEX_Sel2_0,
    input       [31:0] forward_rs2_0,
    input       [31:0] IDEX_Imm_0,

    input              IDEX_Sel1_1,
    input       [31:0] forward_rs1_1,
    input       [31:0] IDEX_NowPC_1,
    input              IDEX_Sel2_1,
    input       [31:0] forward_rs2_1,
    input       [31:0] IDEX_Imm_1,

    output      [31:0] s1_0,
    output      [31:0] s2_0,

    output      [31:0] s1_1,
    output      [31:0] s2_1

);

assign s1_0 = IDEX_Sel1_0 ? forward_rs1_0 : IDEX_NowPC_0;
assign s2_0 = IDEX_Sel2_0 ? forward_rs2_0 : IDEX_Imm_0;

assign s1_1 = IDEX_Sel1_1 ? forward_rs1_1 : IDEX_NowPC_1;
assign s2_1 = IDEX_Sel2_1 ? forward_rs2_1 : IDEX_Imm_1;

endmodule