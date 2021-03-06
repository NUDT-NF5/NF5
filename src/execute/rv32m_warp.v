`include "../src/common/Define.v"
module rv32m_warp(
    input       [`DATA_WIDTH - 1:0]     s1,
    input       [`DATA_WIDTH - 1:0]     s2,
    input       [`ALU_OP_WIDTH - 1:0]   m_AluOp,
    input                               clk,
    input                               rst_n,

    output                              div_start,
    output                              div_ready,
    output                              alu_m_en,

    output      [`DATA_WIDTH - 1:0]     m_data
);

wire            [2 * `DATA_WIDTH - 1:0] mul_result;
wire            [`DATA_WIDTH:0]         div_quotient;
wire            [`DATA_WIDTH:0]         div_remainder;
wire            [`DATA_WIDTH - 1:0]     arithmetic_result;
wire            [`DATA_WIDTH - 1:0]     branch_result;

wire            [`DATA_WIDTH - 1:0]     arithmetic_s1;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s2;
wire            [2:0]                   arithop_sp;
wire            [`DATA_WIDTH - 1:0]     mul_s1;
wire            [`DATA_WIDTH - 1:0]     mul_s2;
wire            [`DATA_WIDTH:0]         div_s1;
wire            [`DATA_WIDTH:0]         div_s2;

alu_m_dispatcher mdp1(
                    .s1(s1),
                    .s2(s2),
                    .IDEX_AluOp(m_AluOp),
                    .mul_result(mul_result),
                    .div_quotient(div_quotient),
                    .div_remainder(div_remainder),
                    .arithmetic_result(arithmetic_result),
                    .branch_result(branch_result),
                    .arithmetic_s1(arithmetic_s1),
                    .arithmetic_s2(arithmetic_s2),
                    .arithop_sp(arithop_sp),
                    .mul_s1(mul_s1),
                    .mul_s2(mul_s2),
                    .div_s1(div_s1),
                    .div_s2(div_s2),
                    .div_start(div_start),
                    .alu_m_en(alu_m_en),
                    .EX_AluData(m_data)
);

multiplier alu_mul  (.mul_s1(mul_s1), 
                     .mul_s2(mul_s2),
                     .mul_result(mul_result));

divider            #(.DLEN(`DATA_WIDTH + 1),
                     .RLEN(`DATA_WIDTH + 1))
                     alu_div
                    (.clk(clk),
                     .rst_n(rst_n),
                     .div_s1(div_s1),
                     .div_s2(div_s2),
                     .div_start(div_start),
                     .div_quotient(div_quotient),
                     .div_remainder(div_remainder),
                     .div_ready(div_ready));

arithmetic   m_arith(.arithmetic_s1(arithmetic_s1), 
                     .arithmetic_s2(arithmetic_s2), 
                     .IDEX_NowPC(32'b0), 
                     .arithop_sp(arithop_sp), 
                     .IDEX_16BitFlag(1'b0), 
                     .arithmetic_result(arithmetic_result), 
                     .branch_result(branch_result));

endmodule