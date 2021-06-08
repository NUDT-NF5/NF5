 /*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: alu_io module
 */
`include "../src/common/Define.v"
module alu_ic_dispatcher(
    input       [`SIMD_DATA_WIDTH - 1:0] s1,
    input       [`SIMD_DATA_WIDTH - 1:0] s2,
    input       [`SIMD_DATA_WIDTH - 1:0] forward_rs1,
    input       [`SIMD_DATA_WIDTH - 1:0] forward_rs2,
    input       [`ALU_OP_WIDTH - 1:0]    IDEX_AluOp,

    input       [`SIMD_DATA_WIDTH - 1:0] arithmetic_result,
    input       [`ADDR_WIDTH - 1:0]      branch_result,
    input       [`SIMD_DATA_WIDTH - 1:0] logic_result,
    input       [2:0]                    comparator_result,
    input       [2:0]                    ucomparator_result,
    input       [`SIMD_DATA_WIDTH - 1:0] shift_result,
    input       [`SIMD_DATA_WIDTH - 1:0] shuffle_result,

    input       [`DATA_WIDTH - 1:0]      Csr_RdData,
    input       [`LD_TYPE_WIDTH - 1:0]   IDEX_LdType,
    input       [`ST_TYPE_WIDTH - 1:0]   IDEX_StType,
    input                                Mem_DcacheEN,

    input                                clk,
    input                                rst_n,

    output reg  [`SIMD_DATA_WIDTH - 1:0] arithmetic_s1,
    output reg  [`SIMD_DATA_WIDTH - 1:0] arithmetic_s2,
    output reg  [2:0]                    arithop_sp,
    output reg  [`SIMD_DATA_WIDTH - 1:0] logic_s1,
    output reg  [`SIMD_DATA_WIDTH - 1:0] logic_s2,
    output reg  [2:0]                    logic_op, 
    output reg  [`DATA_WIDTH - 1:0]      comparator_s1,
    output reg  [`DATA_WIDTH - 1:0]      comparator_s2,
    output reg  [`SIMD_DATA_WIDTH - 1:0] shift_s1,
    output reg  [4:0]                    shift_s2,
    output reg  [2:0]                    shift_type,
    output reg  [`SIMD_DATA_WIDTH - 1:0] shuffle_rs1,
    output reg  [`SIMD_DATA_WIDTH - 1:0] shuffle_rs2,
    output reg  [`DATA_WIDTH - 1:0]      shuffle_ctl,
    output reg                           shuffle_ctl_en,

    output reg  [`SIMD_DATA_WIDTH - 1:0] EX_AluData,
    output      [`ADDR_WIDTH - 1:0]      EX_BranchPC,
    output reg                           EX_BranchFlag,
    output reg                           alu_ic_en,
    output                               EX_LdStFlag
);

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
            arithmetic_s2 = ~s2;
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
        /*`ALU_SUB : begin
            logic_s1 = s2;
            logic_s2 = 32'hffff_ffff;
            logic_op  = 3'b100;
        end*/
        `ALU_JALR : begin
            logic_s1 = branch_result;
            logic_s2 = 32'hffff_fffe;
            logic_op  = 3'b001;
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
            comparator_s1 = s1[0+:`DATA_WIDTH];
            comparator_s2 = s2[0+:`DATA_WIDTH];
        end
        `ALU_SLTU: begin
            comparator_s1 = s1[0+:`DATA_WIDTH];
            comparator_s2 = s2[0+:`DATA_WIDTH];
        end
        `ALU_BEQ: begin
            comparator_s1 = forward_rs1[0+:`DATA_WIDTH];
            comparator_s2 = forward_rs2[0+:`DATA_WIDTH];
        end
        `ALU_BNE: begin
            comparator_s1 = forward_rs1[0+:`DATA_WIDTH];
            comparator_s2 = forward_rs2[0+:`DATA_WIDTH];
        end
        `ALU_BLT: begin
            comparator_s1 = forward_rs1[0+:`DATA_WIDTH];
            comparator_s2 = forward_rs2[0+:`DATA_WIDTH];
        end
        `ALU_BLTU: begin
            comparator_s1 = forward_rs1[0+:`DATA_WIDTH];
            comparator_s2 = forward_rs2[0+:`DATA_WIDTH];
        end
        `ALU_BGE: begin
            comparator_s1 = forward_rs1[0+:`DATA_WIDTH];
            comparator_s2 = forward_rs2[0+:`DATA_WIDTH];
        end
        `ALU_BGEU: begin
            comparator_s1 = forward_rs1[0+:`DATA_WIDTH];
            comparator_s2 = forward_rs2[0+:`DATA_WIDTH];
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

//shuffle unit
always @(*) begin
    shuffle_ctl    = 32'b0;
    shuffle_ctl_en = 1'b0;
    shuffle_rs1     = 64'b0;
    shuffle_rs2     = 64'b0;
    case (IDEX_AluOp)
        `ALU_SHUFFLE : begin
            shuffle_rs1 = s1;
            shuffle_rs2 = s2;
        end
        `ALU_SHUFFLE_SET : begin
            shuffle_ctl = s2[`DATA_WIDTH - 1:0];
            shuffle_ctl_en = 1'b1;
        end
        default : begin
            shuffle_ctl    = 32'b0;
            shuffle_ctl_en = 1'b0;
            shuffle_rs1     = 64'b0;
            shuffle_rs2     = 64'b0;
        end
    endcase
end

//mask unit
reg [5:0] mask;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        mask = 6'b0;
    else if(IDEX_AluOp == `ALU_MASK_SET)
        mask = s2[5:0];
end

wire [63:0] mask_ext_rev = {{16{~mask[3]}}, {16{~mask[2]}},
                            {16{~mask[1]}}, {16{~mask[0]}}};
wire [63:0] mask_ext = {{16{mask[3]}}, {16{mask[2]}},
                        {16{mask[1]}}, {16{mask[0]}}};

//AluData output selection
always @(*) begin
    case (IDEX_AluOp)
        `ALU_ADD : begin
            EX_AluData = arithmetic_result;
            alu_ic_en = 1'b1;
        end
        `ALU_SUB : begin
            EX_AluData = arithmetic_result;
            alu_ic_en = 1'b1;
        end
        `ALU_AND : begin
            EX_AluData = logic_result;
            alu_ic_en = 1'b1;
        end
        `ALU_OR : begin
            EX_AluData = logic_result;
            alu_ic_en = 1'b1;
        end
        `ALU_XOR : begin
            EX_AluData = logic_result;
            alu_ic_en = 1'b1;
        end
        `ALU_SLL : begin
            EX_AluData = shift_result;
            alu_ic_en = 1'b1;
        end
        `ALU_SRL : begin
            EX_AluData = shift_result;
            alu_ic_en = 1'b1;
        end
        `ALU_SRA : begin
            EX_AluData = shift_result;
            alu_ic_en = 1'b1;
        end
        `ALU_SLT: begin
            EX_AluData = {31'b0, comparator_result[0]};      //if signed rs1 < signed rs2, comparator_result[0] == 1, else comparator_result[0] == 0
            alu_ic_en = 1'b1;
        end
        `ALU_SLTU: begin
            EX_AluData = {31'b0, ucomparator_result[0]};     //if unsigned rs1 < unsigned rs2, ucomparator_result[0] == 1, else comparator_result[0] == 0
            alu_ic_en = 1'b1;
        end
        `ALU_JAL : begin
            EX_AluData = arithmetic_result;
            alu_ic_en = 1'b1;
        end
        `ALU_JALR : begin
            EX_AluData = arithmetic_result;
            alu_ic_en = 1'b1;
        end
        `ALU_COPY_A : begin
            EX_AluData = s1;
            alu_ic_en = 1'b1;
        end
        `ALU_COPY_B : begin
            EX_AluData = s2;
            alu_ic_en = 1'b1;
        end
        `ALU_CSR : begin
            EX_AluData = {32'b0, Csr_RdData};
            alu_ic_en = 1'b1;
        end
        `ALU_SHUFFLE : begin
            EX_AluData = shuffle_result;
            alu_ic_en = 1'b1;
        end
        default : begin
            EX_AluData    = 64'b0;
            alu_ic_en = 1'b0;
        end
    endcase
end

assign EX_AluData_Final = (mask[5:4] == 2'b0) ? EX_AluData & mask_ext_rev :
                          (mask[5:4] == 2'b11) ? EX_AluData | mask_ext    :
                          (mask[5]) ? (EX_AluData & mask_ext_rev) | (s2 & mask_ext) :
                          (mask[4]) ? (EX_AluData & mask_ext_rev) | (s1 & mask_ext) :
                          EX_AluData;

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

assign EX_BranchPC = (IDEX_AluOp == `ALU_JALR) ? logic_result[0+:`ADDR_WIDTH] : branch_result[0+:`ADDR_WIDTH];
assign EX_LdStFlag = ( | {IDEX_LdType, IDEX_StType}) && (~Mem_DcacheEN);  //IDEX_LdType or IDEX_StType contains 1 means the instruction is load or store 

endmodule
