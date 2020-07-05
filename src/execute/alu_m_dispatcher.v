 /*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: alu_io module
 */
`include "../src/common/Define.v"
module alu_m_dispatcher(
    input       [`DATA_WIDTH - 1:0]     s1,
    input       [`DATA_WIDTH - 1:0]     s2,
    input       [`ALU_OP_WIDTH - 1:0]   IDEX_AluOp,

    input       [2 * `DATA_WIDTH - 1:0] mul_result,
    input       [`DATA_WIDTH:0]         div_quotient,
    input       [`DATA_WIDTH:0]         div_remainder,
    input       [`DATA_WIDTH - 1:0]     arithmetic_result,
    input       [`DATA_WIDTH - 1:0]     branch_result,

    output reg  [`DATA_WIDTH - 1:0]     arithmetic_s1,
    output reg  [`DATA_WIDTH - 1:0]     arithmetic_s2,
    output reg  [2:0]                   arithop_sp,
    output reg  [`DATA_WIDTH - 1:0]     mul_s1,
    output reg  [`DATA_WIDTH - 1:0]     mul_s2,
    output reg  [`DATA_WIDTH:0]         div_s1,
    output reg  [`DATA_WIDTH:0]         div_s2,
    output reg                          div_start,

    output reg  [`DATA_WIDTH - 1:0]     EX_AluData
);

wire [63:0] mul_result_tmp;

//arithmetic input selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_MULH   : begin
            arithop_sp = 3'b101;
            case ({s1[31], s2[31]})
                2'b01 : begin
                    arithmetic_s1 = 0;
                    arithmetic_s2 = ~s2;
                end
                2'b10 : begin
                    arithmetic_s1 = ~s1;
                    arithmetic_s2 = 0;
                end
                2'b11 : begin
                    arithmetic_s1 = ~s1;
                    arithmetic_s2 = ~s2;
                end
                default : begin
                    arithmetic_s1 = 0;
                    arithmetic_s2 = 0;
                end
            endcase
        end
        `ALU_MULHSU : begin
            arithop_sp = 3'b101;
            case (s1[31])
                1'b1 : begin
                  arithmetic_s1 = ~s1;
                  arithmetic_s2 = 0;
                end
                default : begin
                    arithmetic_s1 = 0;
                    arithmetic_s2 = 0;
                end
            endcase
        end
        default: begin
            arithmetic_s1 = 32'b0;
            arithmetic_s2 = 32'b0;
            arithop_sp = 2'b0;
        end
    endcase
end

//temp m instruction ex
always @(*) begin
    case(IDEX_AluOp) 
        `ALU_MUL    : begin
            mul_s1 = s1;
            mul_s2 = s2;
        end
        `ALU_MULH   : begin
            case ({s1[31], s2[31]})
                2'b01 : begin
                    mul_s1 = s1;
                    mul_s2 = branch_result;
                end
                2'b10 : begin
                    mul_s1 = arithmetic_result;
                    mul_s2 = s2;
                end
                2'b11 : begin
                    mul_s1 = arithmetic_result;
                    mul_s2 = branch_result;
                end
                default : begin
                    mul_s1 = s1;
                    mul_s2 = s2;
                end
            endcase
        end
        `ALU_MULHSU : begin
            case (s1[31])
                1'b1 : begin
                    mul_s1 = arithmetic_result;
                    mul_s2 = s2;
                end
                default : begin
                    mul_s1 = s1;
                    mul_s2 = s2;
                end
            endcase
        end
        `ALU_MULHU  : begin
            mul_s1 = s1;
            mul_s2 = s2;
        end
        default : begin
            mul_s1 = 32'b0;
            mul_s2 = 32'b0;
        end
    endcase
end

always @(*) begin
    case (IDEX_AluOp)
        `ALU_DIV    : begin
            div_s1 = {s1[`DATA_WIDTH - 1], s1};
            div_s2 = {s2[`DATA_WIDTH - 1], s2};
            div_start = 1'b1;
        end
        `ALU_DIVU   : begin
            div_s1 = {1'b0, s1};
            div_s2 = {1'b0, s2};
            div_start = 1'b1;
        end
        `ALU_REM    : begin
            div_s1 = {s1[`DATA_WIDTH - 1], s1};
            div_s2 = {s2[`DATA_WIDTH - 1], s2};
            div_start = 1'b1;
        end
        `ALU_REMU   : begin
            div_s1 = {1'b0, s1};
            div_s2 = {1'b0, s2};
            div_start = 1'b1;
        end 
        default: begin
            div_s1 = 33'b0;
            div_s2 = 33'b0;
            div_start = 1'b0;
        end
    endcase
end

assign mul_result_tmp = ~mul_result + 1;

//AluData output selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_MUL    : begin
            EX_AluData = mul_result[31:0];
        end
        `ALU_MULH   : begin
            if(s1[31] != s2[31])
                EX_AluData = mul_result_tmp[63:32];
            else
                EX_AluData = mul_result[63:32];
        end
        `ALU_MULHSU : begin
            if(s1[31])
                EX_AluData = mul_result_tmp[63:32];
            else
                EX_AluData = mul_result[63:32];
        end
        `ALU_MULHU  : begin
            EX_AluData = mul_result[63:32];
        end
        `ALU_DIV    : begin
            //if(|s2)
                EX_AluData = div_quotient[`DATA_WIDTH - 1:0];
            //else
            //    EX_AluData = 32'hffff_ffff;
        end
        `ALU_DIVU   : begin
            //if(|s2)
                EX_AluData = div_quotient[`DATA_WIDTH - 1:0];
            //else
            //    EX_AluData = 32'hffff_ffff;
        end
        `ALU_REM    : begin
            //if(|s2)
                EX_AluData = div_remainder[`DATA_WIDTH - 1:0];
            //else
            //    EX_AluData = s1;
        end
        `ALU_REMU   : begin
            //if(|s2)
                EX_AluData = div_remainder[`DATA_WIDTH - 1:0];
            //else
            //    EX_AluData = s1;
        end 
        default : begin
            EX_AluData    = 32'b0;
        end
    endcase
end

endmodule
