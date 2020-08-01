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
    input       [`ADDR_WIDTH - 1:0]     IDEX_NowPC_0,
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

    input       [`DATA_WIDTH - 1:0]     Dcache_DataRd_0,
    input                               MemWb_RdWrtEn_0,
    input       [`RF_ADDR_WIDTH - 1:0]  MemWb_RdAddr_0,

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
wire            [`ALU_OP_WIDTH - 1:0]   AluOp_0;
wire            [`ALU_OP_WIDTH - 1:0]   AluOp_1;
//wire            [`ALU_OP_WIDTH - 1:0]   m_AluOp_0;
//wire            [`DATA_WIDTH - 1:0]     m_s1;
//wire            [`DATA_WIDTH - 1:0]     m_s2;
wire            [`DATA_WIDTH - 1:0]     forward_s1_1;
wire            [`DATA_WIDTH - 1:0]     forward_s2_1;
wire                                    exforward_stall;
wire                                    inst_order_Mem_LdEn;
//wire            [1:0]                   m_prio;
//wire                                    inst_order_stall

wire            [`DATA_WIDTH - 1:0]     issue_AluData_0;
wire            [`DATA_WIDTH - 1:0]     issue_AluData_1;
wire            [`DATA_WIDTH - 1:0]     issue_AluData_m_0;
wire            [`DATA_WIDTH - 1:0]     issue_AluData_m_1;
wire            [`DATA_WIDTH - 1:0]     arithmetic_result_m;
wire            [`DATA_WIDTH - 1:0]     branch_result_m;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s1_2;
wire            [`DATA_WIDTH - 1:0]     arithmetic_s2_2;
wire            [2:0]                   arithop_sp_2;
wire            [`DATA_WIDTH - 1:0]     issue_AluData_m;

wire                                    alu_ic_en_0;
wire                                    alu_ic_en_1;
wire                                    alu_m_en_0;
wire                                    alu_m_en_1;

wire                                    div_start_0;
wire                                    div_start_1;
wire                                    div_ready_0;
wire                                    div_ready_1;

wire                                    div_start = div_start_0 || div_start_1;
wire                                    div_ready = div_ready_0 || div_ready_1;

mux_aluinput aluin  (
                     .IDEX_Sel1_0(IDEX_Sel1_0),
                     .forward_rs1_0(IDEX_Rs1Data_0),
                     .IDEX_NowPC_0(IDEX_NowPC_0),
                     .IDEX_Sel2_0(IDEX_Sel2_0),
                     .forward_rs2_0(IDEX_Rs2Data_0),
                     .IDEX_Imm_0(IDEX_Imm_0),
                     .IDEX_Sel1_1(IDEX_Sel1_1),
                     .forward_rs1_1(forward_s1_1),
                     .IDEX_NowPC_1(IDEX_NowPC_1),
                     .IDEX_Sel2_1(IDEX_Sel2_1),
                     .forward_rs2_1(forward_s2_1),
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
                     .s1_1(IDEX_Rs1Data_1),
                     .s2_1(IDEX_Rs2Data_1),
                     .clk(clk),
                     .rst_n(rst_n),
                     .Dcache_DataRd_0(Dcache_DataRd_0),
                     .MemWb_RdWrtEn_0(MemWb_RdWrtEn_0),
                     .MemWb_RdAddr_0(MemWb_RdAddr_0),
                     .issue0_data(EX_AluData_0),
                     .issue1_forward_rs1(forward_s1_1),
                     .issue1_forward_rs2(forward_s2_1),
                     .exforward_stall(exforward_stall)
);

/*inst_order  inst    (.clk(clk),
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
                     .m_prio(m_prio));*/

rv32ic_warp   rv32ic0(
                     .s1(s1_0),
                     .s2(s2_0),
                     .forward_rs1(IDEX_Rs1Data_0),
                     .forward_rs2(IDEX_Rs2Data_0),
                     .IDEX_AluOp(IDEX_AluOp_0),
                     .IDEX_NowPC(IDEX_NowPC_0),
                     .IDEX_16BitFlag(IDEX_16BitFlag_0),
                     .Csr_RdData(Csr_RdData_0),
                     .IDEX_LdType(IDEX_LdType_0),
                     .IDEX_StType(IDEX_StType_0),
                     .Mem_DcacheEN(Mem_DcacheEN_0),
                     .EX_AluData(issue_AluData_0),
                     .EX_BranchPC(EX_BranchPC_0),
                     .EX_BranchFlag(EX_BranchFlag_0),
                     .alu_ic_en(alu_ic_en_0),
                     .EX_LdStFlag(EX_LdStFlag_0)
);

rv32ic_warp   rv32ic1(
                     .s1(s1_1),
                     .s2(s2_1),
                     .forward_rs1(forward_s1_1),
                     .forward_rs2(forward_s2_1),
                     .IDEX_AluOp(IDEX_AluOp_1),
                     .IDEX_NowPC(IDEX_NowPC_1),
                     .IDEX_16BitFlag(IDEX_16BitFlag_1),
                     .Csr_RdData(Csr_RdData_1),
                     .IDEX_LdType(IDEX_LdType_1),
                     .IDEX_StType(IDEX_StType_1),
                     .Mem_DcacheEN(Mem_DcacheEN_1),
                     .EX_AluData(issue_AluData_1),
                     .EX_BranchPC(EX_BranchPC_1),
                     .EX_BranchFlag(EX_BranchFlag_1),
                     .alu_ic_en(alu_ic_en_1),
                     .EX_LdStFlag(EX_LdStFlag_1)
);

rv32m_warp rv32m0  (
                    .s1(s1_0),
                    .s2(s2_0),
                    .m_AluOp(IDEX_AluOp_0),
                    .clk(clk),
                    .rst_n(rst_n),
                    .div_start(div_start_0),
                    .div_ready(div_ready_0),
                    .alu_m_en(alu_m_en_0),
                    .m_data(issue_AluData_m_0)
);

rv32m_warp rv32m1  (
                    .s1(forward_s1_1),
                    .s2(forward_s2_1),
                    .m_AluOp(IDEX_AluOp_1),
                    .clk(clk),
                    .rst_n(rst_n),
                    .div_start(div_start_1),
                    .div_ready(div_ready_1),
                    .alu_m_en(alu_m_en_1),
                    .m_data(issue_AluData_m_1)
);

ex_out       alu_out(
                     .issue_AluData_0(issue_AluData_0),
                     .issue_AluData_1(issue_AluData_1),
                     .issue_AluData_m_0(issue_AluData_m_0),
                     .issue_AluData_m_1(issue_AluData_m_1),
                     .alu_ic_en_0(alu_ic_en_0),
                     .alu_ic_en_1(alu_ic_en_1),
                     .alu_m_en_0(alu_m_en_0),
                     .alu_m_en_1(alu_m_en_1),
                     .EX_AluData_0(EX_AluData_0),
                     .EX_AluData_1(EX_AluData_1)
);

assign EX_StallReq = div_start && (~div_ready);

endmodule // EX