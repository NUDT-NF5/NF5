 /*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: alu_io module
 */
`include "../src/common/Define.v"
module alu_m_dispatcher(
    input       [`SIMD_DATA_WIDTH - 1:0]     s1,
    input       [`SIMD_DATA_WIDTH - 1:0]     s2,
    input       [`ALU_OP_WIDTH - 1:0]        IDEX_AluOp,

    input       [2 * `SIMD_DATA_WIDTH - 1:0] mul_result,
    input       [`DATA_WIDTH:0]              div_quotient,
    input       [`DATA_WIDTH:0]              div_remainder,
    //input       [`SIMD_DATA_WIDTH - 1:0]     arithmetic_result,
    //input       [`SIMD_DATA_WIDTH - 1:0]     branch_result,
    input                                    simd_ena,
    input       [`SIMD_WIDTH - 1:0]          simd_ctl,

    //output reg  [`SIMD_DATA_WIDTH - 1:0]     arithmetic_s1,
    //output reg  [`SIMD_DATA_WIDTH - 1:0]     arithmetic_s2,
    //output reg  [2:0]                        arithop_sp,
    output reg  [`SIMD_DATA_WIDTH - 1:0]     mul_s1,
    output reg  [`SIMD_DATA_WIDTH - 1:0]     mul_s2,
    output reg  [`DATA_WIDTH:0]              div_s1,
    output reg  [`DATA_WIDTH:0]              div_s2,
    output reg                               div_start,
    output reg                               alu_m_en,
    output reg  [1:0]                        mul_sign,

    output reg  [`SIMD_DATA_WIDTH - 1:0]     EX_AluData
);

//arithmetic input selection
/*always @(*) begin
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
end*/

//temp m instruction ex
always @(*) begin
    case(IDEX_AluOp) 
        `ALU_MUL    : begin
            mul_s1 = s1;
            mul_s2 = s2;
            mul_sign = 2'b0;
        end
        `ALU_MULH   : begin
            mul_s1 = s1;
            mul_s2 = s2;
            mul_sign = 2'b11;
        end
        `ALU_MULHSU : begin
            mul_s1 = s1;
            mul_s2 = s2;
            mul_sign = 2'b10;
        end
        `ALU_MULHU  : begin
            mul_s1 = s1;
            mul_s2 = s2;
            mul_sign = 2'b0;
        end
        default : begin
            mul_s1 = `SIMD_DATA_WIDTH'b0;
            mul_s2 = `SIMD_DATA_WIDTH'b0;
            mul_sign = 2'b0;
        end
    endcase
end

always @(*) begin
    case (IDEX_AluOp)
        `ALU_DIV    : begin
            div_s1 = {s1[`DATA_WIDTH - 1], s1[0+:`DATA_WIDTH]};
            div_s2 = {s2[`DATA_WIDTH - 1], s2[0+:`DATA_WIDTH]};
            div_start = 1'b1;
        end
        `ALU_DIVU   : begin
            div_s1 = {1'b0, s1[0+:`DATA_WIDTH]};
            div_s2 = {1'b0, s2[0+:`DATA_WIDTH]};
            div_start = 1'b1;
        end
        `ALU_REM    : begin
            div_s1 = {s1[`DATA_WIDTH - 1], s1[0+:`DATA_WIDTH]};
            div_s2 = {s2[`DATA_WIDTH - 1], s2[0+:`DATA_WIDTH]};
            div_start = 1'b1;
        end
        `ALU_REMU   : begin
            div_s1 = {1'b0, s1[0+:`DATA_WIDTH]};
            div_s2 = {1'b0, s2[0+:`DATA_WIDTH]};
            div_start = 1'b1;
        end 
        default: begin
            div_s1 = {(`DATA_WIDTH + 1'b1){1'b0}};
            div_s2 = {(`DATA_WIDTH + 1'b1){1'b0}};
            div_start = 1'b0;
        end
    endcase
end

//AluData output selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_MUL    : begin
            alu_m_en = 1'b1;
            if(simd_ena)
                case(simd_ctl)
                    2'b01:
                        EX_AluData = {mul_result[64+:32], mul_result[0+:32]};
                    2'b10:
                        EX_AluData = {mul_result[0+:16], mul_result[32+:16], mul_result[64+:16], mul_result[96+:16]};
                    default:
                        EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
                endcase
            else 
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
        end
        `ALU_MULH   : begin
            alu_m_en = 1'b1;
            if(simd_ena)
                case(simd_ctl)
                    2'b01:
                        EX_AluData = {mul_result[64+:32], mul_result[0+:32]};
                    2'b10:
                        EX_AluData = {mul_result[0+:16], mul_result[32+:16], mul_result[64+:16], mul_result[96+:16]};
                    default:
                        EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
                endcase
            else 
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
        end
        `ALU_MULHSU : begin
            alu_m_en = 1'b1;
            if(simd_ena)
                case(simd_ctl)
                    2'b01:
                        EX_AluData = {mul_result[64+:32], mul_result[0+:32]};
                    2'b10:
                        EX_AluData = {mul_result[0+:16], mul_result[32+:16], mul_result[64+:16], mul_result[96+:16]};
                    default:
                        EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
                endcase
            else 
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
        end
        `ALU_MULHU  : begin
            alu_m_en = 1'b1;
            if(simd_ena)
                case(simd_ctl)
                    2'b01:
                        EX_AluData = {mul_result[64+:32], mul_result[0+:32]};
                    2'b10:
                        EX_AluData = {mul_result[0+:16], mul_result[32+:16], mul_result[64+:16], mul_result[96+:16]};
                    default:
                        EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
                endcase
            else 
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, mul_result[0+:`DATA_WIDTH]};
        end
        `ALU_DIV    : begin
            alu_m_en = 1'b1;
            //if(|s2)
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, div_quotient[`DATA_WIDTH - 1:0]};
            //else
            //    EX_AluData = 32'hffff_ffff;
        end
        `ALU_DIVU   : begin
            alu_m_en = 1'b1;
            //if(|s2)
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, div_quotient[`DATA_WIDTH - 1:0]};
            //else
            //    EX_AluData = 32'hffff_ffff;
        end
        `ALU_REM    : begin
            alu_m_en = 1'b1;
            //if(|s2)
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, div_remainder[`DATA_WIDTH - 1:0]};
            //else
            //    EX_AluData = s1;
        end
        `ALU_REMU   : begin
            alu_m_en = 1'b1;
            //if(|s2)
                EX_AluData = {{(`SIMD_DATA_WIDTH - `DATA_WIDTH){1'b0}}, div_remainder[`DATA_WIDTH - 1:0]};
            //else
            //    EX_AluData = s1;
        end
        default : begin
            alu_m_en = 1'b0;
            EX_AluData    = {`SIMD_DATA_WIDTH{1'b0}};
        end
    endcase
end

endmodule
