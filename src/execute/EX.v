/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:EX  module
 */
module EX(
    input  [`SIMD_DATA_WIDTH - 1:0]     IDEX_Rs1Data,
    input  [`SIMD_DATA_WIDTH - 1:0]     IDEX_Rs2Data,
    input  [`SIMD_DATA_WIDTH - 1:0]     IDEX_Rs3Data,
    //signals for mux_aluinput
    input                               IDEX_Sel1,
    input  [`ADDR_WIDTH - 1:0]          IDEX_NowPC,
    input                               IDEX_Sel2,
    input  [`DATA_WIDTH - 1:0]          IDEX_Imm,
    //input for FPU
    input  [`FUNCT3_WIDTH - 1:0]        IDEX_Rm,
    input  [1:0]                        IDEX_Fmt,
    input  [`FRM_WIDTH - 1:0]           Csr_Frm,
    //other input
    input  [`DATA_WIDTH - 1:0]          Csr_RdData,
    input  [`ALU_OP_WIDTH - 1:0]        IDEX_AluOp,
    input  [`LD_TYPE_WIDTH - 1:0]       IDEX_LdType,
    input  [`ST_TYPE_WIDTH - 1:0]       IDEX_StType,
    input                               Mem_DcacheEN,
    input                               IDEX_16BitFlag,
    input                               clk,
    input                               rst_n,
    input                               simd_ena,
    input  [`SIMD_WIDTH - 1:0]          simd_ctl,
    input                               IDEX_BpFlag,
    input                               IDEX_IsBr,
    //output
    output [`SIMD_DATA_WIDTH - 1:0]     EX_AluData,
    output                              EX_BranchFlag,
    output [`ADDR_WIDTH - 1:0]          EX_BranchPC,
    output                              EX_LdStFlag,
    output                              EX_StallReq,
    output [`FPU_EXCEPTION_WIDTH - 1:0] EX_FpuException,
    output                              EX_FpuReady
);

//extra signals
wire       [`SIMD_DATA_WIDTH - 1:0]     s1;
wire       [`SIMD_DATA_WIDTH - 1:0]     s2;

wire                                    div_start;
wire                                    div_ready;

wire                                    alu_ic_en;
wire                                    alu_m_en;
wire       [`SIMD_DATA_WIDTH - 1:0]     AluData_ic;
wire       [`SIMD_DATA_WIDTH - 1:0]     AluData_m;

wire                                    EX_Branch;
wire       [`ADDR_WIDTH - 1:0]          EX_BranchPC_tmp;

wire                                    fpu_vec_i = 1'b0;
wire       [1:0]                        fpu_fmt_i; 
wire       [2:0]                        fpu_rm_i;
wire       [2:0]                        fpu_frm_i;
wire       [`FPU_EXCEPTION_WIDTH - 1:0] fpu_exception;
wire       [`DATA_WIDTH - 1:0]          fpu_result;
wire                                    fpu_stall;
wire                                    fpu_in_valid;
wire                                    fpu_out_valid;
wire                                    fpu_en;

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
                     .simd_ena(simd_ena),
                     .simd_ctl(simd_ctl),
                     .Csr_RdData(Csr_RdData),
                     .IDEX_LdType(IDEX_LdType),
                     .IDEX_StType(IDEX_StType),
                     .Mem_DcacheEN(Mem_DcacheEN),
                     .clk(clk),
                     .rst_n(rst_n),
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
                    .simd_ena(simd_ena),
                    .simd_ctl(simd_ctl),
                    .div_start(div_start),
                    .div_ready(div_ready),
                    .alu_m_en(alu_m_en),
                    .m_data(AluData_m)
);

fpu_warp   rv32f   (
                    .clk_i(clk),
                    .rst_ni(rst_n),
                    .flush_i(1'b0),
                    //.fpu_valid_i(fpu_valid),
                    .fpu_ready_o(),
                    .vec_ena(1'b0),
                    .fpu_op_i(IDEX_AluOp),
                    .operand_0(s1[`DATA_WIDTH - 1:0]),
                    .operand_1(s2[`DATA_WIDTH - 1:0]),
                    .operand_2(IDEX_Rs3Data[`DATA_WIDTH - 1:0]),
                    .fpu_vec_i(fpu_vec_i),
                    .fpu_fmt_i(IDEX_Fmt),
                    .fpu_rm_i(IDEX_Rm),
                    .fpu_frm_i(Csr_Frm),
                    .fpu_result(fpu_result),
                    .fpu_stall(fpu_stall),
                    .fpu_exception(EX_FpuException),
                    .fpu_in_valid(fpu_in_valid),
                    .fpu_out_valid(fpu_out_valid)
);

ex_out       alu_out(
                     .issue_AluData_0(AluData_ic),
                     .issue_AluData_1(64'b0),
                     .issue_AluData_m_0(AluData_m),
                     .issue_AluData_m_1(64'b0),
                     .FpuData({32'b0, fpu_result}),
                     .alu_ic_en_0(alu_ic_en),
                     .alu_ic_en_1(1'b0),
                     .alu_m_en_0(alu_m_en),
                     .alu_m_en_1(1'b0),
                     .fpu_en(fpu_en),
                     .simd_ena(simd_ena),
                     .EX_AluData_0(EX_AluData),
                     .EX_AluData_1()
);

assign EX_FpuReady = fpu_en;
assign EX_StallReq = div_start && (~div_ready) || fpu_stall;
assign fpu_en = fpu_in_valid && fpu_out_valid;
assign EX_BranchFlag = EX_Branch ^ IDEX_BpFlag && IDEX_IsBr;
assign EX_BranchPC = (EX_Branch && EX_BranchFlag) ? EX_BranchPC_tmp : 
                                 (IDEX_16BitFlag) ? IDEX_NowPC + 32'd2 : IDEX_NowPC + 32'd4;

endmodule // EX