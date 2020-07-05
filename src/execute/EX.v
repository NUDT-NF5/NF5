/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:EX  module
 */
 `include "../src/common/Define.v"
module EX(
    input       [`DATA_WIDTH - 1:0]     IDEX_Rs1Data_0,
    input       [`DATA_WIDTH - 1:0]     IDEX_Rs2Data_0,
    //signals for mux_aluinput
    input                               IDEX_Sel1_0,
    input       [`DATA_WIDTH - 1:0]     IDEX_NowPC_0,
    input                               IDEX_Sel2_0,
    input       [`DATA_WIDTH - 1:0]     IDEX_Imm_0,
    //other input
    input       [`DATA_WIDTH - 1:0]     Csr_RdData_0,
    input       [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp_0,
    input       [2:0]                   IDEX_LdType_0,
    input       [1:0]                   IDEX_StType_0,
    input                               Mem_DcacheEN_0,
    input                               IDEX_16BitFlag_0,
    input                               IDEX_WbRdEn_0,

    input       [`DATA_WIDTH - 1:0]     IDEX_Rs1Data_1,
    input       [`DATA_WIDTH - 1:0]     IDEX_Rs2Data_1,
    //signals for mux_aluinput
    input                               IDEX_Sel1_1,
    input       [`DATA_WIDTH - 1:0]     IDEX_NowPC_1,
    input                               IDEX_Sel2_1,
    input       [`DATA_WIDTH - 1:0]     IDEX_Imm_1,
    //other input
    input       [`DATA_WIDTH - 1:0]     Csr_RdData_1,
    input       [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp_1,
    input       [2:0]                   IDEX_LdType_1,
    input       [1:0]                   IDEX_StType_1,
    input                               Mem_DcacheEN_1,
    input                               IDEX_16BitFlag_1,

    input                               clk,
    input                               rst_n,
    input       [`RF_ADDR_WIDTH - 1:0]  IDEX_RdAddr_0,
    input       [`RF_ADDR_WIDTH - 1:0]  IDEX_Rs1Addr_1,
    input       [`RF_ADDR_WIDTH - 1:0]  IDEX_Rs2Addr_1,

    //output
    output      [`DATA_WIDTH - 1:0]     EX_AluData_0,
    output                              EX_BranchFlag_0,
    output      [`ADDR_WIDTH - 1:0]     EX_BranchPC_0,
    output                              EX_LdStFlag_0,

    output      [`DATA_WIDTH - 1:0]     EX_AluData_1,
    output                              EX_BranchFlag_1,
    output      [`ADDR_WIDTH - 1:0]     EX_BranchPC_1,
    output                              EX_LdStFlag_1,
    output                              EX_StallReq
);

//mux_aluinput to alu_io
wire            [`DATA_WIDTH - 1:0]     s1_0;
wire            [`DATA_WIDTH - 1:0]     s2_0;

wire            [`DATA_WIDTH - 1:0]     s1_1;
wire            [`DATA_WIDTH - 1:0]     s2_1;

//inst_order
wire            [`ALU_OP_WIDTH - 1:0]   ic_AluOp_0;
wire            [`ALU_OP_WIDTH - 1:0]   ic_AluOp_1;
wire            [`ALU_OP_WIDTH - 1:0]   m_AluOp_0;
wire            [`DATA_WIDTH - 1:0]     m_s1;
wire            [`DATA_WIDTH - 1:0]     m_s2;
wire            [`DATA_WIDTH - 1:0]     forward_s1_1;
wire            [`DATA_WIDTH - 1:0]     forward_s2_1;
wire                                    exforward_stall;
wire                                    inst_order_Mem_LdEn;
wire            [1:0]                   m_prio;
//wire                                    inst_order_stall

wire            [`DATA_WIDTH - 1:0]     issue_AluData_0;
wire            [`DATA_WIDTH - 1:0]     issue_AluData_1;
wire            [`DATA_WIDTH - 1:0]     arithmetic_result_m;
wire            [`DATA_WIDTH - 1:0]     branch_result_m;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s1_2;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s2_2;
wire            [2:0]                   arithop_sp_2;
wire            [`DATA_WIDTH - 1:0]     issue_AluData_m;

//arithmetic
wire            [`DATA_WIDTH - 1:0]     arithmetic_s1_0;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s2_0;
wire            [2:0]                   arithop_sp_0;
wire            [`DATA_WIDTH - 1:0]     arithmetic_result_0;
wire            [`ADDR_WIDTH - 1:0]     branch_result_0;

//logic
wire            [`DATA_WIDTH - 1:0]     logic_s1_0;
wire            [`DATA_WIDTH - 1:0]     logic_s2_0;
wire            [2:0]                   logic_op_0;
wire            [`DATA_WIDTH - 1:0]     logic_result_0;

//compapator
wire            [`DATA_WIDTH - 1:0]     comparator_s1_0;
wire            [`DATA_WIDTH - 1:0]     comparator_s2_0;
wire            [2:0]                   comparator_result_0;
wire            [2:0]                   ucomparator_result_0;

//shift
wire            [`DATA_WIDTH - 1:0]     shift_s1_0;
wire            [4:0]                   shift_s2_0;
wire            [2:0]                   shift_type_0;
wire            [`DATA_WIDTH - 1:0]     shift_result_0;

//arithmetic
wire            [`DATA_WIDTH - 1:0]     arithmetic_s1_1;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s2_1;
wire            [2:0]                   arithop_sp_1;
wire            [`DATA_WIDTH - 1:0]     arithmetic_result_1;
wire            [`ADDR_WIDTH - 1:0]     branch_result_1;

//logic
wire            [`DATA_WIDTH - 1:0]     logic_s1_1;
wire            [`DATA_WIDTH - 1:0]     logic_s2_1;
wire            [2:0]                   logic_op_1;
wire            [`DATA_WIDTH - 1:0]     logic_result_1;

//compapator
wire            [`DATA_WIDTH - 1:0]     comparator_s1_1;
wire            [`DATA_WIDTH - 1:0]     comparator_s2_1;
wire            [2:0]                   comparator_result_1;
wire            [2:0]                   ucomparator_result_1;

//shift
wire            [`DATA_WIDTH - 1:0]     shift_s1_1;
wire            [4:0]                   shift_s2_1;
wire            [2:0]                   shift_type_1;
wire            [`DATA_WIDTH - 1:0]     shift_result_1;

//multiplier
wire            [`DATA_WIDTH - 1:0]     mul_s1;
wire            [`DATA_WIDTH - 1:0]     mul_s2;
wire            [2 * `DATA_WIDTH - 1:0] mul_result;
//divider
wire            [`DATA_WIDTH:0]         div_s1;
wire            [`DATA_WIDTH:0]         div_s2;
wire            [`DATA_WIDTH:0]         div_quotient;
wire            [`DATA_WIDTH:0]         div_remainder;
wire                                    div_start;
wire                                    div_ready;

mux_aluinput aluin  (
                     .IDEX_Sel1_0(IDEX_Sel1_0),
                     .forward_rs1_0(IDEX_Rs1Data_0),
                     .IDEX_NowPC_0(IDEX_NowPC_0),
                     .IDEX_Sel2_0(IDEX_Sel2_0),
                     .forward_rs2_0(IDEX_Rs2Data_0),
                     .IDEX_Imm_0(IDEX_Imm_0),
                     .IDEX_Sel1_1(IDEX_Sel1_1),
                     .forward_rs1_1(IDEX_Rs1Data_1),
                     .IDEX_NowPC_1(IDEX_NowPC_1),
                     .IDEX_Sel2_1(IDEX_Sel2_1),
                     .forward_rs2_1(IDEX_Rs2Data_1),
                     .IDEX_Imm_1(IDEX_Imm_1),
                     .s1_0(s1_0),
                     .s2_0(s2_0),
                     .s1_1(s1_1),
                     .s2_1(s2_1)
);

ex_forward    forward(
                     .issue0_rdaddr(IDEX_RdAddr_0),
                     .issue0_RdWrtEn(IDEX_WbRdEn_0),
                     .inst_order_Mem_LdEn(inst_order_Mem_LdEn),
                     .issue1_rs1addr(IDEX_Rs1Addr_1),
                     .issue1_rs2addr(IDEX_Rs2Addr_1),
                     .IDEX_LdType_0(IDEX_LdType_0),
                     .s1_1(s1_1),
                     .s2_1(s2_1),
                     .issue0_data(EX_AluData_0),
                     .issue1_forward_rs1(forward_s1_1),
                     .issue1_forward_rs2(forward_s2_1),
                     .exforward_stall(exforward_stall)
);

inst_order  inst    (.clk(clk),
                     .rst_n(rst_n),
                     .IDEX_AluOp_0(IDEX_AluOp_0),
                     .IDEX_AluOp_1(IDEX_AluOp_1),
                     .div_start(div_start),
                     .s1_0(s1_0),
                     .s2_0(s2_0),
                     .s1_1(forward_s1_1),
                     .s2_1(forward_s2_1),
                     .exforward_stall(exforward_stall),
                     .Mem_LdEn(Mem_DcacheEN_0),
                     .EX_LdStFlag_0(EX_LdStFlag_0),
                     .EX_BranchFlag_0(EX_BranchFlag_0),
                     .ic_AluOp_0(ic_AluOp_0),
                     .ic_AluOp_1(ic_AluOp_1),
                     .m_AluOp_0(m_AluOp_0),
                     .m_s1(m_s1),
                     .m_s2(m_s2),
                     .inst_order_Mem_LdEn(inst_order_Mem_LdEn),
                     .m_prio(m_prio));

/*alu_dispatcher alu_dp(.s1(s1), 
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
                     .EX_LdStFlag(EX_LdStFlag));*/

alu_ic_dispatcher idp0(
                     .s1(s1_0),
                     .s2(s2_0), 
                     .IDEX_AluOp(ic_AluOp_0), 
                     .forward_rs1(IDEX_Rs1Data_0), 
                     .forward_rs2(IDEX_Rs2Data_0), 
                     .arithmetic_result(arithmetic_result_0), 
                     .branch_result(branch_result_0), 
                     .logic_result(logic_result_0), 
                     .comparator_result(comparator_result_0), 
                     .ucomparator_result(ucomparator_result_0), 
                     .shift_result(shift_result_0), 
                     .Csr_RdData(Csr_RdData_0), 
                     .IDEX_LdType(IDEX_LdType_0), 
                     .IDEX_StType(IDEX_StType_0), 
                     .Mem_DcacheEN(Mem_DcacheEN_0), 
                     .arithmetic_s1(arithmetic_s1_0), 
                     .arithmetic_s2(arithmetic_s2_0), 
                     .arithop_sp(arithop_sp_0), 
                     .logic_s1(logic_s1_0), 
                     .logic_s2(logic_s2_0), 
                     .logic_op(logic_op_0), 
                     .comparator_s1(comparator_s1_0), 
                     .comparator_s2(comparator_s2_0), 
                     .shift_s1(shift_s1_0), 
                     .shift_s2(shift_s2_0), 
                     .shift_type(shift_type_0), 
                     .EX_AluData(issue_AluData_0), 
                     .EX_BranchPC(EX_BranchPC_0),
                     .EX_BranchFlag(EX_BranchFlag_0), 
                     .EX_LdStFlag(EX_LdStFlag_0));

alu_ic_dispatcher idp1(
                     .s1(forward_s1_1),
                     .s2(forward_s2_1), 
                     .IDEX_AluOp(ic_AluOp_1), 
                     .forward_rs1(IDEX_Rs1Data_1), 
                     .forward_rs2(IDEX_Rs2Data_1), 
                     .arithmetic_result(arithmetic_result_1), 
                     .branch_result(branch_result_1), 
                     .logic_result(logic_result_1), 
                     .comparator_result(comparator_result_1), 
                     .ucomparator_result(ucomparator_result_1), 
                     .shift_result(shift_result_1), 
                     .Csr_RdData(Csr_RdData_1),
                     .IDEX_LdType(IDEX_LdType_1), 
                     .IDEX_StType(IDEX_StType_1), 
                     .Mem_DcacheEN(Mem_DcacheEN_1), 
                     .arithmetic_s1(arithmetic_s1_1), 
                     .arithmetic_s2(arithmetic_s2_1), 
                     .arithop_sp(arithop_sp_1), 
                     .logic_s1(logic_s1_1), 
                     .logic_s2(logic_s2_1), 
                     .logic_op(logic_op_1), 
                     .comparator_s1(comparator_s1_1), 
                     .comparator_s2(comparator_s2_1), 
                     .shift_s1(shift_s1_1), 
                     .shift_s2(shift_s2_1), 
                     .shift_type(shift_type_1), 
                     .EX_AluData(issue_AluData_1), 
                     .EX_BranchPC(EX_BranchPC_1),
                     .EX_BranchFlag(EX_BranchFlag_1), 
                     .EX_LdStFlag(EX_LdStFlag_1));

alu_m_dispatcher mdp(
                    .s1(m_s1),
                    .s2(m_s2),
                    .IDEX_AluOp(m_AluOp_0),
                    .mul_result(mul_result),
                    .div_quotient(div_quotient),
                    .div_remainder(div_remainder),
                    .arithmetic_result(arithmetic_result_m),
                    .branch_result(branch_result_m),
                    .arithmetic_s1(arithmetic_s1_2),
                    .arithmetic_s2(arithmetic_s2_2),
                    .arithop_sp(arithop_sp_2),
                    .mul_s1(mul_s1),
                    .mul_s2(mul_s2),
                    .div_s1(div_s1),
                    .div_s2(div_s2),
                    .div_start(div_start),
                    .EX_AluData(issue_AluData_m)
);

arithmetic   m_arith(.arithmetic_s1(arithmetic_s1_2), 
                     .arithmetic_s2(arithmetic_s2_2), 
                     .IDEX_NowPC(32'b0), 
                     .arithop_sp(arithop_sp_2), 
                     .IDEX_16BitFlag(1'b0), 
                     .arithmetic_result(arithmetic_result_m), 
                     .branch_result(branch_result_m));
            
arithmetic alu_arith0(.arithmetic_s1(arithmetic_s1_0), 
                     .arithmetic_s2(arithmetic_s2_0), 
                     .IDEX_NowPC(IDEX_NowPC_0), 
                     .arithop_sp(arithop_sp_0), 
                     .IDEX_16BitFlag(IDEX_16BitFlag_0), 
                     .arithmetic_result(arithmetic_result_0), 
                     .branch_result(branch_result_0));

logicm alu_logic0   (.logic_s1(logic_s1_0), 
                     .logic_s2(logic_s2_0), 
                     .logic_op(logic_op_0), 
                     .logic_result(logic_result_0));

comparator alu_comp0(.comparator_s1(comparator_s1_0), 
                     .comparator_s2(comparator_s2_0), 
                     .comparator_result(comparator_result_0),
                     .ucomparator_result(ucomparator_result_0));
 
shift alu_shift0    (.shift_s1(shift_s1_0), 
                     .shift_s2(shift_s2_0), 
                     .shift_type(shift_type_0), 
                     .shift_result(shift_result_0));

arithmetic alu_arith1(.arithmetic_s1(arithmetic_s1_1), 
                     .arithmetic_s2(arithmetic_s2_1), 
                     .IDEX_NowPC(IDEX_NowPC_1), 
                     .arithop_sp(arithop_sp_1), 
                     .IDEX_16BitFlag(IDEX_16BitFlag_1), 
                     .arithmetic_result(arithmetic_result_1), 
                     .branch_result(branch_result_1));

logicm alu_logic1   (.logic_s1(logic_s1_1), 
                     .logic_s2(logic_s2_1), 
                     .logic_op(logic_op_1), 
                     .logic_result(logic_result_1));

comparator alu_comp1(.comparator_s1(comparator_s1_1), 
                     .comparator_s2(comparator_s2_1), 
                     .comparator_result(comparator_result_1),
                     .ucomparator_result(ucomparator_result_1));
 
shift alu_shift1    (.shift_s1(shift_s1_1), 
                     .shift_s2(shift_s2_1), 
                     .shift_type(shift_type_1), 
                     .shift_result(shift_result_1));

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

ex_out       alu_out(
                     .issue_AluData_0(issue_AluData_0),
                     .issue_AluData_1(issue_AluData_1),
                     .issue_AluData_m(issue_AluData_m),
                     .m_prio(m_prio),
                     .EX_AluData_0(EX_AluData_0),
                     .EX_AluData_1(EX_AluData_1)
);

assign EX_StallReq = div_start && (~div_ready);

endmodule // EX