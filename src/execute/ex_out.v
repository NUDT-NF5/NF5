`include "../src/common/Define.v"
module ex_out(
    input  [`SIMD_DATA_WIDTH - 1:0] issue_AluData_0,
    input  [`SIMD_DATA_WIDTH - 1:0] issue_AluData_1,
    input  [`SIMD_DATA_WIDTH - 1:0] issue_AluData_m_0,
    input  [`SIMD_DATA_WIDTH - 1:0] issue_AluData_m_1,
    input                           alu_ic_en_0,
    input                           alu_ic_en_1,
    input                           alu_m_en_0,
    input                           alu_m_en_1,
    input                           simd_ena,

    output [`SIMD_DATA_WIDTH - 1:0] EX_AluData_0,
    output [`SIMD_DATA_WIDTH - 1:0] EX_AluData_1
);

wire       [`SIMD_DATA_WIDTH - 1:0] EX_AluData_0_tmp;
wire       [`SIMD_DATA_WIDTH - 1:0] EX_AluData_1_tmp;


assign EX_AluData_0_tmp = alu_ic_en_0 ? issue_AluData_0 : issue_AluData_m_0;
assign EX_AluData_1_tmp = alu_ic_en_1 ? issue_AluData_1 : issue_AluData_m_1;

assign EX_AluData_0 = simd_ena ? EX_AluData_0_tmp : {32'b0, EX_AluData_0_tmp[31:0]};
assign EX_AluData_1 = simd_ena ? EX_AluData_1_tmp : {32'b0, EX_AluData_1_tmp[31:0]};

endmodule
