`include "../common/Define.v"
module ex_out(
    input  [`DATA_WIDTH - 1:0] issue_AluData_0,
    input  [`DATA_WIDTH - 1:0] issue_AluData_1,
    input  [`DATA_WIDTH - 1:0] issue_AluData_m_0,
    input  [`DATA_WIDTH - 1:0] issue_AluData_m_1,
    input                      alu_ic_en_0,
    input                      alu_ic_en_1,
    input                      alu_m_en_0,
    input                      alu_m_en_1,

    output [`DATA_WIDTH - 1:0] EX_AluData_0,
    output [`DATA_WIDTH - 1:0] EX_AluData_1
);

assign EX_AluData_0 = (alu_ic_en_0) ? issue_AluData_0 :
                      issue_AluData_m_0;
assign EX_AluData_1 = (alu_ic_en_1) ? issue_AluData_1 :
                      issue_AluData_m_1;
endmodule
