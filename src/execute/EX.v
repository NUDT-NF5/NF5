module EX(
    //signals for forward
    /*input       [4:0]  EXMem_RdAddr,
    //input       [31:0] EXMem_AluData,
    input       [31:0] Dcache_DataRd,
    input              Mem_LdEn,
    //input       [4:0]  MemWb_RdAddr,
    //input       [31:0] Wb_DataWrt,
    //input              EXMem_RdWrtEn,
    //input              MemWb_RdWrtEn,*/
    input       [31:0] IDEX_Rs1Data,
    //input       [4:0]  IDEX_Rs1Addr,
    input       [31:0] IDEX_Rs2Data,
    //input       [4:0]  IDEX_Rs2Addr,

    //signals for mux_aluinput
    input              IDEX_Sel1,
    input       [31:0] IDEX_NowPC,
    input              IDEX_Sel2,
    input       [31:0] IDEX_Imm,

    //other input
    input       [31:0] Csr_RdData,
    input       [4:0]  IDEX_AluOp,
    input       [2:0]  IDEX_LdType,
    input       [1:0]  IDEX_StType,
    input              Mem_DcacheEN,
    input              IDEX_16BitFlag,

    //output
    output      [31:0] EX_AluData,
    output             EX_BranchFlag,
    output      [31:0] EX_BranchPC,
    output             EX_LdStFlag
    //output      [31:0] forward_rs1

);

//forward to mux_aluinput
//wire            [31:0] forward_rs1;
//wire            [31:0] forward_rs2;

//mux_aluinput to alu_io
wire            [31:0] s1;
wire            [31:0] s2;

//arithmetic
wire            [31:0] arithmetic_s1;
wire            [31:0] arithmetic_s2;
wire            [2:0]  arithop_sp;
wire            [31:0] arithmetic_result;
wire            [31:0] branch_result;

//logic
wire            [31:0] logic_s1;
wire            [31:0] logic_s2;
wire            [2:0]  logic_op;
wire            [31:0] logic_result;

//compapator
wire            [31:0] comparator_s1;
wire            [31:0] comparator_s2;
wire            [2:0]  comparator_result;
wire            [2:0]  ucomparator_result;

//shift
wire            [31:0] shift_s1;
wire            [4:0]  shift_s2;
wire            [2:0]  shift_type;
wire            [31:0] shift_result;

//multiplier
wire            [31:0] mul_s1;
wire            [31:0] mul_s2;
wire            [63:0] mul_result;
//divider
wire            [31:0] div_s1;
wire            [31:0] div_s2;
wire            [31:0] div_result;

//forward alu_forward (.EXMem_RdAddr(EXMem_RdAddr), .EXMem_AluData(EXMem_AluData), .Dcache_DataRd(Dcache_DataRd), 
//                     .Mem_LdEn(Mem_LdEn), .MemWb_RdAddr(MemWb_RdAddr), .Wb_DataWrt(Wb_DataWrt), .EXMem_RdWrtEn(EXMem_RdWrtEn),
//                     .MemWb_RdWrtEn(MemWb_RdWrtEn), .IDEX_Rs1Data(IDEX_Rs1Data), .IDEX_Rs1Addr(IDEX_Rs1Addr), .IDEX_Rs2Data(IDEX_Rs2Data), 
//                     .IDEX_Rs2Addr(IDEX_Rs2Addr), .forward_rs1(forward_rs1), .forward_rs2(forward_rs2));

mux_aluinput aluin  (.IDEX_Sel1(IDEX_Sel1), 
                     .forward_rs1(IDEX_Rs1Data), 
                     .IDEX_NowPC(IDEX_NowPC), 
                     .IDEX_Sel2(IDEX_Sel2), 
                     .forward_rs2(IDEX_Rs2Data), 
                     .IDEX_Imm(IDEX_Imm), 
                     /*.Dcache_DataRd(Dcache_DataRd), 
                     .Mem_LdEn(Mem_LdEn), 
                     .IDEX_Rs1Addr(IDEX_Rs1Addr), 
                     .IDEX_Rs2Addr(IDEX_Rs2Addr), 
                     .EXMem_RdAddr(EXMem_RdAddr),*/
                     .s1(s1), 
                     .s2(s2));

alu_io alu_i_o      (.s1(s1), 
                     .s2(s2), 
                     .IDEX_AluOp(IDEX_AluOp), 
                     .forward_rs1(IDEX_Rs1Data), 
                     .forward_rs2(IDEX_Rs2Data), 
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
                     .mul_s1(mul_s1), 
                     .mul_s2(mul_s2),
                     .mul_result(mul_result),
                     .div_s1(div_s1), 
                     .div_s2(div_s2),
                     .div_result(div_result),
                     .EX_AluData(EX_AluData), 
                     .EX_BranchPC(EX_BranchPC),
                     .EX_BranchFlag(EX_BranchFlag), 
                     .EX_LdStFlag(EX_LdStFlag));
            
arithmetic alu_arith(.arithmetic_s1(arithmetic_s1), 
                     .arithmetic_s2(arithmetic_s2), 
                     .IDEX_NowPC(IDEX_NowPC), 
                     .arithop_sp(arithop_sp), 
                     .IDEX_16BitFlag(IDEX_16BitFlag), 
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
                     .shift_result(shift_result));

multiplier alu_mul  (.mul_s1(mul_s1), 
                     .mul_s2(mul_s2),
                     .mul_result(mul_result));

divider alu_div     (.div_s1(div_s1), 
                     .div_s2(div_s2),
                     .div_result(div_result));      
 
endmodule // EX