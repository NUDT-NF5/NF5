/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:EX  module
 */
module EX(
    input       [`DATA_WIDTH - 1:0]     IDEX_Rs1Data,
    input       [`DATA_WIDTH - 1:0]     IDEX_Rs2Data,
    //signals for mux_aluinput
    input                               IDEX_Sel1,
    input       [`DATA_WIDTH - 1:0]     IDEX_NowPC,
    input                               IDEX_Sel2,
    input       [`DATA_WIDTH - 1:0]     IDEX_Imm,
    //other input
    input       [`DATA_WIDTH - 1:0]     Csr_RdData,
    input       [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp,
    input       [2:0]                   IDEX_LdType,
    input       [1:0]                   IDEX_StType,
    input                               Mem_DcacheEN,
    input                               Dcache_StallReq,
    input                               IDEX_16BitFlag,
    input                               clk,
    input                               rst_n,
    //output
    output      [`DATA_WIDTH - 1:0]     EX_AluData,
    output                              EX_BranchFlag,
    output      [`ADDR_WIDTH - 1:0]     EX_BranchPC,
    output                              EX_LdStFlag,
    output                              EX_StallReq
);

//mux_aluinput to alu_io
wire            [`DATA_WIDTH - 1:0]     s1;
wire            [`DATA_WIDTH - 1:0]     s2;

//arithmetic
wire            [`DATA_WIDTH - 1:0]     arithmetic_s1;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s2;
wire            [2:0]                   arithop_sp;
wire            [`DATA_WIDTH - 1:0]     arithmetic_result;
wire            [`ADDR_WIDTH - 1:0]     branch_result;

//logic
wire            [`DATA_WIDTH - 1:0]     logic_s1;
wire            [`DATA_WIDTH - 1:0]     logic_s2;
wire            [2:0]                   logic_op;
wire            [`DATA_WIDTH - 1:0]     logic_result;

//compapator
wire            [`DATA_WIDTH - 1:0]     comparator_s1;
wire            [`DATA_WIDTH - 1:0]     comparator_s2;
wire            [2:0]                   comparator_result;
wire            [2:0]                   ucomparator_result;

//shift
wire            [`DATA_WIDTH - 1:0]     shift_s1;
wire            [4:0]                   shift_s2;
wire            [2:0]                   shift_type;
wire            [`DATA_WIDTH - 1:0]     shift_result;

//multiplier
wire            [`DATA_WIDTH - 1:0]     mul_s1;
wire            [`DATA_WIDTH - 1:0]     mul_s2;
wire            [2 * `DATA_WIDTH - 1:0] mul_result;
//divider
wire            [`DATA_WIDTH:0]         div_s1;
wire            [`DATA_WIDTH:0]         div_s2;
wire            [`DATA_WIDTH:0]     div_quotient;
wire            [`DATA_WIDTH:0]     div_remainder;
wire                                    div_start;
wire                                    div_ready;

mux_aluinput aluin  (.IDEX_Sel1(IDEX_Sel1), 
                     .forward_rs1(IDEX_Rs1Data), 
                     .IDEX_NowPC(IDEX_NowPC), 
                     .IDEX_Sel2(IDEX_Sel2), 
                     .forward_rs2(IDEX_Rs2Data), 
                     .IDEX_Imm(IDEX_Imm), 
                     .s1(s1), 
                     .s2(s2));

alu_dispatcher alu_dp(.s1(s1), 
                     .s2(s2), 
                     .IDEX_AluOp(IDEX_AluOp), 
                     .forward_rs1(IDEX_Rs1Data), 
                     .forward_rs2(IDEX_Rs2Data), 
                     .arithmetic_result(arithmetic_result), 
                     .branch_result(branch_result), 
                     .logic_result(logic_result), 
                     .comparator_result(comparator_result), 
                     .ucomparator_result(ucomparator_result), 
                     .shift_result(shift_result), 
                     .Csr_RdData(Csr_RdData), 
                     .IDEX_LdType(IDEX_LdType), 
                     .IDEX_StType(IDEX_StType), 
                     .Mem_DcacheEN(Mem_DcacheEN), 
                     .Dcache_StallReq(Dcache_StallReq),
                     .arithmetic_s1(arithmetic_s1), 
                     .arithmetic_s2(arithmetic_s2), 
                     .arithop_sp(arithop_sp), 
                     .logic_s1(logic_s1), 
                     .logic_s2(logic_s2), 
                     .logic_op(logic_op), 
                     .comparator_s1(comparator_s1), 
                     .comparator_s2(comparator_s2), 
                     .shift_s1(shift_s1), 
                     .shift_s2(shift_s2), 
                     .shift_type(shift_type), 
                     .mul_s1(mul_s1), 
                     .mul_s2(mul_s2),
                     .mul_result(mul_result),
                     .div_s1(div_s1), 
                     .div_s2(div_s2),
                     .div_quotient(div_quotient),
                     .div_remainder(div_remainder),
                     .div_start(div_start),
                     .EX_AluData(EX_AluData), 
                     .EX_BranchPC(EX_BranchPC),
                     .EX_BranchFlag(EX_BranchFlag), 
                     .EX_LdStFlag(EX_LdStFlag));
            
arithmetic alu_arith(.arithmetic_s1(arithmetic_s1), 
                     .arithmetic_s2(arithmetic_s2), 
                     .IDEX_NowPC(IDEX_NowPC), 
                     .arithop_sp(arithop_sp), 
                     .IDEX_16BitFlag(IDEX_16BitFlag), 
                     .arithmetic_result(arithmetic_result), 
                     .branch_result(branch_result));

logicm alu_logic    (.logic_s1(logic_s1), 
                     .logic_s2(logic_s2), 
                     .logic_op(logic_op), 
                     .logic_result(logic_result));

comparator alu_comp (.comparator_s1(comparator_s1), 
                     .comparator_s2(comparator_s2), 
                     .comparator_result(comparator_result),
                     .ucomparator_result(ucomparator_result));
 
shift alu_shift     (.shift_s1(shift_s1), 
                     .shift_s2(shift_s2), 
                     .shift_type(shift_type), 
                     .shift_result(shift_result));

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

assign EX_StallReq = div_start && (~div_ready);

endmodule // EX