module rv32ic_warp(
    input       [`SIMD_DATA_WIDTH - 1:0] s1,
    input       [`SIMD_DATA_WIDTH - 1:0] s2,
    input       [`SIMD_DATA_WIDTH - 1:0] forward_rs1,
    input       [`SIMD_DATA_WIDTH - 1:0] forward_rs2,
    input       [`ALU_OP_WIDTH - 1:0]    IDEX_AluOp,
    input       [`ADDR_WIDTH - 1:0]      IDEX_NowPC,
    input                                IDEX_16BitFlag,
    input                                simd_ena,
    input       [`SIMD_WIDTH - 1:0]      simd_ctl,

    input       [`DATA_WIDTH - 1:0]      Csr_RdData,
    input       [`LD_TYPE_WIDTH - 1:0]   IDEX_LdType,
    input       [`ST_TYPE_WIDTH - 1:0]   IDEX_StType,
    input                                Mem_DcacheEN,

    output      [`SIMD_DATA_WIDTH - 1:0] EX_AluData,
    output      [`ADDR_WIDTH - 1:0]      EX_BranchPC,
    output                               EX_BranchFlag,
    output                               alu_ic_en,
    output                               EX_LdStFlag
);

//arithmetic
wire            [`SIMD_DATA_WIDTH - 1:0] arithmetic_s1;
wire            [`SIMD_DATA_WIDTH - 1:0] arithmetic_s2;
wire            [2:0]                    arithop_sp;
wire            [`SIMD_DATA_WIDTH - 1:0] arithmetic_result;
wire            [`ADDR_WIDTH - 1:0]      branch_result;

//logic
wire            [`SIMD_DATA_WIDTH - 1:0] logic_s1;
wire            [`SIMD_DATA_WIDTH - 1:0] logic_s2;
wire            [2:0]                    logic_op;
wire            [`SIMD_DATA_WIDTH - 1:0] logic_result;

//compapator
wire            [`DATA_WIDTH - 1:0]      comparator_s1;
wire            [`DATA_WIDTH - 1:0]      comparator_s2;
wire            [2:0]                    comparator_result;
wire            [2:0]                    ucomparator_result;

//shift
wire            [`SIMD_DATA_WIDTH - 1:0] shift_s1;
wire            [4:0]                    shift_s2;
wire            [2:0]                    shift_type;
wire            [`SIMD_DATA_WIDTH - 1:0] shift_result;

alu_ic_dispatcher idp0(
                     .s1(s1),
                     .s2(s2), 
                     .IDEX_AluOp(IDEX_AluOp), 
                     .forward_rs1(forward_rs1), 
                     .forward_rs2(forward_rs2), 
                     .arithmetic_result(arithmetic_result), 
                     .branch_result(branch_result), 
                     .logic_result(logic_result), 
                     .comparator_result(comparator_result), 
                     .ucomparator_result(ucomparator_result), 
                     .shift_result(shift_result), 
                     .Csr_RdData(Csr_RdData), 
                     .IDEX_LdType(IDEX_LdType), 
                     .IDEX_StType(IDEX_StType), 
                     .Mem_DcacheEN(Mem_DcacheEN), 
                     .arithmetic_s1(arithmetic_s1), 
                     .arithmetic_s2(arithmetic_s2), 
                     .arithop_sp(arithop_sp), 
                     .logic_s1(logic_s1), 
                     .logic_s2(logic_s2), 
                     .logic_op(logic_op), 
                     .comparator_s1(comparator_s1), 
                     .comparator_s2(comparator_s2), 
                     .shift_s1(shift_s1), 
                     .shift_s2(shift_s2), 
                     .shift_type(shift_type), 
                     .EX_AluData(EX_AluData), 
                     .EX_BranchPC(EX_BranchPC),
                     .EX_BranchFlag(EX_BranchFlag), 
                     .alu_ic_en(alu_ic_en),
                     .EX_LdStFlag(EX_LdStFlag));

arithmetic alu_arith(.arithmetic_s1(arithmetic_s1), 
                     .arithmetic_s2(arithmetic_s2), 
                     .IDEX_NowPC(IDEX_NowPC), 
                     .arithop_sp(arithop_sp), 
                     .IDEX_16BitFlag(IDEX_16BitFlag), 
                     .simd_ena(simd_ena),
                     .simd_ctl(simd_ctl),
                     .arithmetic_result(arithmetic_result), 
                     .branch_result(branch_result));

logicm alu_logic    (.logic_s1(logic_s1), 
                     .logic_s2(logic_s2), 
                     .logic_op(logic_op), 
                     .logic_result(logic_result));

comparator alu_comp (.comparator_s1(comparator_s1), 
                     .comparator_s2(comparator_s2), 
                     .comparator_result(comparator_result),
                     .ucomparator_result(ucomparator_result));
 
shift alu_shift     (.shift_s1(shift_s1), 
                     .shift_s2(shift_s2), 
                     .shift_type(shift_type), 
                     .simd_ena(simd_ena),
                     .simd_ctl(simd_ctl),
                     .shift_result(shift_result));

endmodule