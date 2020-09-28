module mux_aluinput(
    input              IDEX_Sel1,
    input       [31:0] forward_rs1,
    input       [31:0] IDEX_NowPC,
    input              IDEX_Sel2,
    input       [31:0] forward_rs2,
    input       [31:0] IDEX_Imm,
//forward from Dcache
    //input       [31:0] Dcache_DataRd,
    //input              Mem_LdEn,
    /*input       [4:0]  IDEX_Rs1Addr,
    input       [4:0]  IDEX_Rs2Addr,
    input       [4:0]  EXMem_RdAddr,*/

    output      [31:0] s1,
    output      [31:0] s2
);

//wire            [31:0] dforward_rs1;
//wire            [31:0] dforward_rs2;

//assign dforward_rs1 = ((IDEX_Rs1Addr == EXMem_RdAddr) && Mem_LdEn) ? Dcache_DataRd : forward_rs1;
//assign dforward_rs2 = ((IDEX_Rs2Addr == EXMem_RdAddr) && Mem_LdEn) ? Dcache_DataRd : forward_rs2;

assign s1 = IDEX_Sel1 ? forward_rs1 : IDEX_NowPC;
assign s2 = IDEX_Sel2 ? forward_rs2 : IDEX_Imm;

endmodule