module ex_out(
    input  [`DATA_WIDTH - 1:0] issue_AluData_0,
    input  [`DATA_WIDTH - 1:0] issue_AluData_1,
    input  [`DATA_WIDTH - 1:0] issue_AluData_m,
    input  [1:0]               m_prio,

    output [`DATA_WIDTH - 1:0] EX_AluData_0,
    output [`DATA_WIDTH - 1:0] EX_AluData_1
);

assign EX_AluData_0 = (m_prio == 2'b10) ? issue_AluData_m :
                      issue_AluData_0;
assign EX_AluData_1 = (m_prio == 2'b11) ? issue_AluData_m :
                      issue_AluData_1;
endmodule
