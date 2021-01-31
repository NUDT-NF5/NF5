/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:EX  module
 */
 `include "../common/Define.v"
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
    input                               IDEX_16BitFlag,
    input                               clk,
    input                               rst_n,
    input                               IDEX_BpFlag,
    input                               IDEX_IsBr,
    //output
    output      [`DATA_WIDTH - 1:0]     EX_AluData,
    output                              EX_BranchFlag,
    output      [`ADDR_WIDTH - 1:0]     EX_BranchPC,
    output                              EX_LdStFlag,
    output                              EX_StallReq
);

//extra signals
wire            [`DATA_WIDTH - 1:0]     s1;
wire            [`DATA_WIDTH - 1:0]     s2;

wire                                    div_start;
wire                                    div_ready;

wire                                    alu_ic_en;
wire                                    alu_m_en;
wire            [`DATA_WIDTH - 1:0]     AluData_ic;
wire            [`DATA_WIDTH - 1:0]     AluData_m;

wire                                    EX_Branch;
wire       [`ADDR_WIDTH - 1:0]          EX_BranchPC_tmp;

mux_aluinput aluin  (.IDEX_Sel1(IDEX_Sel1), 
                     .forward_rs1(IDEX_Rs1Data), 
                     .IDEX_NowPC(IDEX_NowPC), 
                     .IDEX_Sel2(IDEX_Sel2), 
                     .forward_rs2(IDEX_Rs2Data), 
                     .IDEX_Imm(IDEX_Imm), 
                     .s1(s1), 
                     .s2(s2));

rv32ic_warp rv32ic  (
                     .s1(s1),
                     .s2(s2),
                     .forward_rs1(IDEX_Rs1Data),
                     .forward_rs2(IDEX_Rs2Data),
                     .IDEX_AluOp(IDEX_AluOp),
                     .IDEX_NowPC(IDEX_NowPC),
                     .IDEX_16BitFlag(IDEX_16BitFlag),
                     .Csr_RdData(Csr_RdData),
                     .IDEX_LdType(IDEX_LdType),
                     .IDEX_StType(IDEX_StType),
                     .Mem_DcacheEN(Mem_DcacheEN),
                     .EX_AluData(AluData_ic),
                     .EX_BranchPC(EX_BranchPC_tmp),
                     .EX_BranchFlag(EX_Branch),
                     .alu_ic_en(alu_ic_en),
                     .EX_LdStFlag(EX_LdStFlag)
);

rv32m_warp rv32m   (
                    .s1(s1),
                    .s2(s2),
                    .m_AluOp(IDEX_AluOp),
                    .clk(clk),
                    .rst_n(rst_n),
                    .div_start(div_start),
                    .div_ready(div_ready),
                    .alu_m_en(alu_m_en),
                    .m_data(AluData_m)
);

ex_out       alu_out(
                     .issue_AluData_0(AluData_ic),
                     .issue_AluData_1(32'b0),
                     .issue_AluData_m_0(AluData_m),
                     .issue_AluData_m_1(32'b0),
                     .alu_ic_en_0(alu_ic_en),
                     .alu_ic_en_1(1'b0),
                     .alu_m_en_0(alu_m_en),
                     .alu_m_en_1(1'b0),
                     .EX_AluData_0(EX_AluData),
                     .EX_AluData_1()
);

assign EX_StallReq = div_start && (~div_ready);
assign EX_BranchFlag = EX_Branch ^ IDEX_BpFlag && IDEX_IsBr;
assign EX_BranchPC = (EX_Branch && EX_BranchFlag) ? EX_BranchPC_tmp : IDEX_NowPC + 32'd4;

endmodule // EX