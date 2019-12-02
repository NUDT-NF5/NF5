/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: alu_io module
 */
`include "../src/common/Define.v"
module alu_io(
    input       [31:0] s1,
    input       [31:0] s2,
    input       [31:0] forward_rs1,
    input       [31:0] forward_rs2,
    input       [4:0]  IDEX_AluOp,

    input       [31:0] arithmetic_result,
    input       [31:0] branch_result,
    input       [31:0] logic_result,
    input       [2:0]  comparator_result,
    input       [2:0]  ucomparator_result,
    input       [31:0] shift_result,
    input       [63:0] mul_result,
    input       [31:0] div_result,

    input       [31:0] Csr_RdData,
    input       [2:0]  IDEX_LdType,
    input       [1:0]  IDEX_StType,
    input              Mem_DcacheEN,

    output reg  [31:0] arithmetic_s1,
    output reg  [31:0] arithmetic_s2,
    output reg  [2:0]  arithop_sp,
    output reg  [31:0] logic_s1,
    output reg  [31:0] logic_s2,
    output reg  [2:0]  logic_op, 
    output reg  [31:0] comparator_s1,
    output reg  [31:0] comparator_s2,
    output reg  [31:0] shift_s1,
    output reg  [4:0]  shift_s2,
    output reg  [2:0]  shift_type,
    output reg  [31:0] mul_s1,
    output reg  [31:0] mul_s2,
    output reg  [31:0] div_s1,
    output reg  [31:0] div_s2,

    output reg  [31:0] EX_AluData,
    output      [31:0] EX_BranchPC,
    output reg         EX_BranchFlag,
    output             EX_LdStFlag
);

wire [63:0] mul_result_tmp;
wire [31:0] div_result_tmp;

//arithmetic input selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_ADD : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 2'b0;
        end
        `ALU_SUB : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = logic_result;
            arithop_sp = 3'b010;
        end
        `ALU_BEQ : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b001;
        end
        `ALU_BNE : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b001;
        end
        `ALU_BLT : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b001;
        end
        `ALU_BLTU : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b001;
        end
        `ALU_BGE : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b001;
        end
        `ALU_BGEU : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b001;
        end
        `ALU_JAL : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b001;
        end
        `ALU_JALR : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = s2;
            arithop_sp = 3'b100;
        end
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
        `ALU_DIV    : begin
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
        `ALU_REM    : begin
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
        `ALU_REMU   : begin
            arithmetic_s1 = s1;
            arithmetic_s2 = logic_result;
            arithop_sp = 3'b010;
        end 
        default: begin
            arithmetic_s1 = 32'b0;
            arithmetic_s2 = 32'b0;
            arithop_sp = 2'b0;
        end
    endcase
end

//logic io selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_AND : begin
            logic_s1 = s1;
            logic_s2 = s2;
            logic_op  = 3'b001;
        end
        `ALU_OR : begin
            logic_s1 = s1;
            logic_s2 = s2;
            logic_op  = 3'b010;
        end
        `ALU_XOR : begin
            logic_s1 = s1;
            logic_s2 = s2;
            logic_op  = 3'b100;
        end
        `ALU_SUB : begin
            logic_s1 = s2;
            logic_s2 = 32'hffff_ffff;
            logic_op  = 3'b100;
        end
        `ALU_JALR : begin
            logic_s1 = branch_result;
            logic_s2 = 32'hffff_fffe;
            logic_op  = 3'b001;
        end
        `ALU_REM  : begin
            logic_s1 = div_result;
            logic_s2 = 32'hffff_ffff;
            logic_op  = 3'b100;
        end
        `ALU_REMU : begin
            logic_s1 = mul_result;
            logic_s2 = 32'hffff_ffff;
            logic_op  = 3'b100;
        end 
        default: begin
            logic_s1 = 32'b0;
            logic_s2 = 32'b0;
            logic_op = 3'b0;
        end
    endcase
end

//comparator io selection
always @(*) begin
    case(IDEX_AluOp)
        `ALU_SLT: begin
            comparator_s1 = s1;
            comparator_s2 = s2;
        end
        `ALU_SLTU: begin
            comparator_s1 = s1;
            comparator_s2 = s2;
        end
        `ALU_BEQ: begin
            comparator_s1 = forward_rs1;
            comparator_s2 = forward_rs2;
        end
        `ALU_BNE: begin
            comparator_s1 = forward_rs1;
            comparator_s2 = forward_rs2;
        end
        `ALU_BLT: begin
            comparator_s1 = forward_rs1;
            comparator_s2 = forward_rs2;
        end
        `ALU_BLTU: begin
            comparator_s1 = forward_rs1;
            comparator_s2 = forward_rs2;
        end
        `ALU_BGE: begin
            comparator_s1 = forward_rs1;
            comparator_s2 = forward_rs2;
        end
        `ALU_BGEU: begin
            comparator_s1 = forward_rs1;
            comparator_s2 = forward_rs2;
        end
        default : begin
            comparator_s1 = 32'b0;
            comparator_s2 = 32'b0;
        end 
    endcase
end

//shift io selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_SLL : begin
            shift_s1   = s1;
            shift_s2   = s2[4:0];
            shift_type = 3'b001;
        end
        `ALU_SRL : begin
            shift_s1   = s1;
            shift_s2   = s2[4:0];
            shift_type = 3'b010;
        end
        `ALU_SRA : begin
            shift_s1   = s1;
            shift_s2   = s2[4:0];
            shift_type = 3'b100;
        end
        default : begin
            shift_s1   = 32'b0;
            shift_s2   = 5'b0;
            shift_type = 3'b0;
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
        `ALU_REM    : begin
            case ({s1[31], s2[31]})
                2'b01 : begin
                    mul_s1 = ~s2 + 1;
                    mul_s2 = div_result;
                end
                2'b10 : begin
                    mul_s1 = div_result;
                    mul_s2 = s2;
                end
                2'b11 : begin
                    mul_s1 = ~s2 + 1;
                    mul_s2 = div_result;
                end
                default : begin
                    mul_s1 = div_result;
                    mul_s2 = s2;
                end
            endcase
        end
        `ALU_REMU   : begin
            mul_s1 = div_result;
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
            case ({s1[31], s2[31]})
                2'b01 : begin
                    div_s1 = s1;
                    div_s2 = branch_result;
                end
                2'b10 : begin
                    div_s1 = arithmetic_result;
                    div_s2 = s2;
                end
                2'b11 : begin
                    div_s1 = arithmetic_result;
                    div_s2 = branch_result;
                end
                default : begin
                    div_s1 = s1;
                    div_s2 = s2;
                end
            endcase
        end
        `ALU_DIVU   : begin
            div_s1 = s1;
            div_s2 = s2;
        end
        `ALU_REM    : begin
            case ({s1[31], s2[31]})
                2'b01 : begin
                    div_s1 = s1;
                    div_s2 = branch_result;
                end
                2'b10 : begin
                    div_s1 = arithmetic_result;
                    div_s2 = s2;
                end
                2'b11 : begin
                    div_s1 = arithmetic_result;
                    div_s2 = branch_result;
                end
                default : begin
                    div_s1 = s1;
                    div_s2 = s2;
                end
            endcase
        end
        `ALU_REMU   : begin
            div_s1 = s1;
            div_s2 = s2;
        end 
        default: begin
            div_s1 = 32'b0;
            div_s2 = 32'b0;
        end
    endcase
end

assign mul_result_tmp = ~mul_result + 1;
assign div_result_tmp = ~div_result + 1;

//AluData output selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_ADD : begin
            EX_AluData = arithmetic_result;
        end
        `ALU_SUB : begin
            EX_AluData = arithmetic_result;
        end
        `ALU_AND : begin
            EX_AluData = logic_result;
        end
        `ALU_OR : begin
            EX_AluData = logic_result;
        end
        `ALU_XOR : begin
            EX_AluData = logic_result;
        end
        `ALU_SLL : begin
            EX_AluData = shift_result;
        end
        `ALU_SRL : begin
            EX_AluData = shift_result;
        end
        `ALU_SRA : begin
            EX_AluData = shift_result;
        end
        `ALU_SLT: begin
            EX_AluData = {31'b0, comparator_result[0]};      //if signed rs1 < signed rs2, comparator_result[0] == 1, else comparator_result[0] == 0
        end
        `ALU_SLTU: begin
            EX_AluData = {31'b0, ucomparator_result[0]};     //if unsigned rs1 < unsigned rs2, ucomparator_result[0] == 1, else comparator_result[0] == 0
        end
        `ALU_JAL : begin
            EX_AluData = arithmetic_result;
        end
        `ALU_JALR : begin
            EX_AluData = arithmetic_result;
        end
        `ALU_COPY_A : begin
            EX_AluData = s1;
        end
        `ALU_COPY_B : begin
            EX_AluData = s2;
        end
        `ALU_CSR : begin
            EX_AluData = Csr_RdData;
        end
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
            if(|s2)
                if(s1[31] != s2[31])
                    EX_AluData = div_result_tmp;
                else
                    EX_AluData = div_result;
            else
                EX_AluData = 32'hffff_ffff;
        end
        `ALU_DIVU   : begin
            if(|s2)
                EX_AluData = div_result;
            else
                EX_AluData = 32'hffff_ffff;
        end
        `ALU_REM    : begin
            if(|s2)
                case ({s1[31], s2[31]})
                    2'b00 :
                        EX_AluData = s1 - mul_result;
                    2'b01 :
                        EX_AluData = s1 - mul_result;
                    default: 
                        EX_AluData = s1 + mul_result;
                endcase
            else
                EX_AluData = s1;
        end
        `ALU_REMU   : begin
            if(|s2)
                EX_AluData = arithmetic_result;
            else
                EX_AluData = s1;
        end 
        default : begin
            EX_AluData    = 32'b0;
        end
    endcase
end

//BranchFlag output selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_BEQ : begin
            EX_BranchFlag = comparator_result[1];                        //comparator_result[1] == 1: rs1 == rs2
        end
        `ALU_BNE : begin
            EX_BranchFlag = comparator_result[2] | comparator_result[0]; //comparator_result[2] == 1: rs1 > rs2, comparator_result[0] == 1: rs1 > rs2
        end
        `ALU_BLT : begin
            EX_BranchFlag = comparator_result[0];
        end
        `ALU_BLTU : begin
            EX_BranchFlag = ucomparator_result[0];
        end
        `ALU_BGE : begin
            EX_BranchFlag = comparator_result[2] | comparator_result[1];
        end
        `ALU_BGEU : begin
            EX_BranchFlag = ucomparator_result[2] | ucomparator_result[1];
        end
        `ALU_JAL : begin
            EX_BranchFlag = 1'b1;
        end
        `ALU_JALR : begin
            EX_BranchFlag = 1'b1;
        end
        default : begin
            EX_BranchFlag = 1'b0;
        end
    endcase
end

assign EX_BranchPC = (IDEX_AluOp == `ALU_JALR) ? logic_result : branch_result;
assign EX_LdStFlag = ( | {IDEX_LdType, IDEX_StType}) && (~Mem_DcacheEN);  //IDEX_LdType or IDEX_StType contains 1 means the instruction is load or store 

endmodule
