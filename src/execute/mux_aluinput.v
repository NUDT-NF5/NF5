/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: mux_aluinput  module
 */
module mux_aluinput(
    input              IDEX_Sel1,
    input       [31:0] forward_rs1,
    input       [31:0] IDEX_NowPC,
    input              IDEX_Sel2,
    input       [31:0] forward_rs2,
    input       [31:0] IDEX_Imm,

    output      [31:0] s1,
    output      [31:0] s2
);


assign s1 = IDEX_Sel1 ? forward_rs1 : IDEX_NowPC;
assign s2 = IDEX_Sel2 ? forward_rs2 : IDEX_Imm;

endmodule