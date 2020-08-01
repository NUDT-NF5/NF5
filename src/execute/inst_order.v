`include "../src/common/Define.v"
module inst_order(
    input                          clk,
    input                          rst_n,

    input  [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp_0,
    input  [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp_1,
/*    input                          div_start,
    input  [`DATA_WIDTH - 1:0]     s1_0,
    input  [`DATA_WIDTH - 1:0]     s2_0,
    input  [`DATA_WIDTH - 1:0]     s1_1,
    input  [`DATA_WIDTH - 1:0]     s2_1,*/
    input                          exforward_stall,
    input                          Mem_LdEn,
    input                          EX_LdStFlag_0,
    input                          EX_BranchFlag_0,

    output [`ALU_OP_WIDTH - 1:0]   AluOp_0,
    output [`ALU_OP_WIDTH - 1:0]   AluOp_1,
/*    output [`ALU_OP_WIDTH - 1:0]   m_AluOp_0,
    output [`DATA_WIDTH - 1:0]     m_s1,
    output [`DATA_WIDTH - 1:0]     m_s2,*/
    output                         inst_order_Mem_LdEn
//    output [1:0]                   m_prio
);

reg        [`ALU_OP_WIDTH - 1:0]   m_AluOp_reg_0;
reg        [`DATA_WIDTH - 1:0]     m_s1_reg;
reg        [`DATA_WIDTH - 1:0]     m_s2_reg;
reg                                indicator;
reg                                issue0_nop_indciator;

assign AluOp_0 = (issue0_nop_indciator) ? `ALU_OP_WIDTH'b0 : IDEX_AluOp_0;
assign AluOp_1 = (EX_LdStFlag_0 || EX_BranchFlag_0) ? `ALU_OP_WIDTH'b0 : IDEX_AluOp_1;

/*always @(posedge clk)
    if (IDEX_AluOp_0 >= `ALU_MUL && IDEX_AluOp_1 >= `ALU_MUL)begin
        m_AluOp_reg_0 <= IDEX_AluOp_1;
        m_s1_reg <= s1_1;
        m_s2_reg <= s2_1;
        indicator <= 1;
    end
    else begin
        m_AluOp_reg_0 <= 0;
        m_s1_reg <= 0;
        m_s2_reg <= 0;
        indicator <= 0;
    end*/

always @(posedge clk)
    if(exforward_stall)
        issue0_nop_indciator <= 1;
    else
        issue0_nop_indciator <= 0;

/*assign m_AluOp_0 = (indicator) ? m_AluOp_reg_0 : 
                   (IDEX_AluOp_0 >= `ALU_MUL) ? IDEX_AluOp_0 :
                   (IDEX_AluOp_1 >= `ALU_MUL) ? 
                   (EX_LdStFlag_0) ? `ALU_OP_WIDTH'b0 : IDEX_AluOp_1 
                   : `ALU_OP_WIDTH'b0;

assign m_s1      = (indicator) ? m_s1_reg : 
                   (IDEX_AluOp_0 >= `ALU_MUL) ? s1_0 :
                   (IDEX_AluOp_1 >= `ALU_MUL) ? s1_1 : `DATA_WIDTH'b0;

assign m_s2      = (indicator) ? m_s2_reg : 
                   (IDEX_AluOp_0 >= `ALU_MUL) ? s2_0 :
                   (IDEX_AluOp_1 >= `ALU_MUL) ? s2_1 : `DATA_WIDTH'b0;*/

assign inst_order_Mem_LdEn = indicator ? 1'b0 : Mem_LdEn;

/*assign m_prio = (IDEX_AluOp_0 >= `ALU_MUL) ? 2'b10 :
                (IDEX_AluOp_1 >= `ALU_MUL) ? 2'b11 :
                2'b0;*/
endmodule

/*    input                               clk;
    input                               rst_n;

    input  [`DATA_WIDTH - 1:0]     s1_0,
    input  [`DATA_WIDTH - 1:0]     s2_0,
    input  [`DATA_WIDTH - 1:0]     forward_rs1_0,
    input  [`DATA_WIDTH - 1:0]     forward_rs2_0,
    input  [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp_0,

    input  [`DATA_WIDTH - 1:0]     s1_1,
    input  [`DATA_WIDTH - 1:0]     s2_1,
    input  [`DATA_WIDTH - 1:0]     forward_rs1_1,
    input  [`DATA_WIDTH - 1:0]     forward_rs2_1,
    input  [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp_1,

    output [`DATA_WIDTH - 1:0]     i_s1_0,
    output [`DATA_WIDTH - 1:0]     i_s2_0,
    output [`DATA_WIDTH - 1:0]     i_forward_rs1_0,
    output [`DATA_WIDTH - 1:0]     i_forward_rs2_0,
    output [`ALU_OP_WIDTH - 1:0]   i_IDEX_AluOp_0,

    output [`DATA_WIDTH - 1:0]     i_s1_1,
    output [`DATA_WIDTH - 1:0]     i_s2_1,
    output [`DATA_WIDTH - 1:0]     i_forward_rs1_1,
    output [`DATA_WIDTH - 1:0]     i_forward_rs2_1,
    output [`ALU_OP_WIDTH - 1:0]   i_IDEX_AluOp_1,
    output                         inst_ena
);

reg        [`DATA_WIDTH - 1:0]     s1_1_0;
reg        [`DATA_WIDTH - 1:0]     s2_1_0;
reg        [`DATA_WIDTH - 1:0]     forward_rs1_1_0;
reg        [`DATA_WIDTH - 1:0]     forward_rs2_1_0;
reg        [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp_1_0;
reg                                inst1_to_0_indic;

always @(posedge clk)begin
    if(IDEX_AluOp_1 >= `ALU_MUL)begin
        s1_1_0 <= s1_0;
        s2_1_0 <= s2_0;
        forward_rs1_1_0 <= forward_rs1_0;
        forward_rs2_1_0 <= forward_rs2_0;
        IDEX_AluOp_1_0 <= IDEX_AluOp_0;
        inst1_to_0_indic <= 1;
    end
    else begin
        s1_1_0 <= 'b0;
        s2_1_0 <= 'b0;
        forward_rs1_1_0 <= 'b0;
        forward_rs2_1_0 <= 'b0;
        IDEX_AluOp_1_0 <= 'b0;
        inst1_to_0_indic <= 0;
    end
end

always @* begin
    if(IDEX_AluOp_1 >= `ALU_MUL)begin
        inst_ena <= 0;
        i_s1_1 <= 'b0;
        i_s2_1 <= 'b0;
        i_forward_rs1_1 <= 'b0;
        i_forward_rs2_1 <= 'b0;
        i_IDEX_AluOp_1 <= 'b0;
    end
    else begin
        i_s1_1 <= s1_1;
        i_s2_1 <= s2_1;
        i_forward_rs1_1 <= forward_rs1_1;
        i_forward_rs2_1 <= forward_rs2_1;
        i_IDEX_AluOp_1 <= IDEX_AluOp_1;
    end
end

always @* begin
    if(inst1_to_0_indic) begin
        i_s1_0 <= s1_1_0;
        i_s2_0 <= s2_1_0;
        i_forward_rs1_0 <= forward_rs1_1_0;
        i_forward_rs2_0 <= forward_rs2_1_0;
        i_IDEX_AluOp_0 <= IDEX_AluOp_1_0;
    end
    else begin
        i_s1_0 <= s1_0;
        i_s2_0 <= s2_0;
        i_forward_rs1_0 <= forward_rs1_0;
        i_forward_rs2_0 <= forward_rs2_0;
        i_IDEX_AluOp_0 <= IDEX_AluOp_0;
    end
end

endmodule*/
