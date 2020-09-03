`include "../src/common/Define.v"
module ex_forward(
    input    [`RF_ADDR_WIDTH - 1:0]   issue0_rdaddr,
    input                             issue0_RdWrtEn,
    input    [`RF_ADDR_WIDTH - 1:0]   issue1_rs1addr,
    input    [`RF_ADDR_WIDTH - 1:0]   issue1_rs2addr,
    input    [2:0]                    IDEX_LdType_0,
    input    [`DATA_WIDTH - 1:0]      s1_1,
    input    [`DATA_WIDTH - 1:0]      s2_1,

    input    [`RF_ADDR_WIDTH - 1:0]   issue0_rs1addr,
    input    [`RF_ADDR_WIDTH - 1:0]   issue0_rs2addr,
    input    [`DATA_WIDTH - 1:0]      s1_0,
    input    [`DATA_WIDTH - 1:0]      s2_0,

    input                             clk,
    input                             rst_n,
    input    [`DATA_WIDTH - 1:0]      Dcache_DataRd_0,
    input                             EXMem_RdWrtEn_0,
    input    [`RF_ADDR_WIDTH - 1:0]   EXMem_RdAddr_0,
    input                             Mem_LdEN_0,
    
    input    [`DATA_WIDTH - 1:0]      Dcache_DataRd_1,
    input                             EXMem_RdWrtEn_1,
    input    [`RF_ADDR_WIDTH - 1:0]   EXMem_RdAddr_1,
    input                             Mem_LdEN_1,

    input    [`DATA_WIDTH - 1:0]      issue0_data,
    output   [`DATA_WIDTH - 1:0]      issue0_forward_rs1,
    output   [`DATA_WIDTH - 1:0]      issue0_forward_rs2,
    output   [`DATA_WIDTH - 1:0]      issue1_forward_rs1,
    output   [`DATA_WIDTH - 1:0]      issue1_forward_rs2
);

assign issue0_forward_rs1 = s1_0;
assign issue0_forward_rs2 = s2_0;

assign issue1_forward_rs1 = (issue0_RdWrtEn && (issue0_rdaddr == issue1_rs1addr) && issue0_rdaddr != 0) ? issue0_data : 
                            (Mem_LdEN_0 && EXMem_RdAddr_0 == issue1_rs1addr && EXMem_RdAddr_0 != 0) ? Dcache_DataRd_0 : 
                            (Mem_LdEN_1 && EXMem_RdAddr_1 == issue1_rs1addr && EXMem_RdAddr_1 != 0) ? Dcache_DataRd_1 : s1_1;
/*assign issue1_forward_rs2 = (issue0_RdWrtEn && (issue0_rdaddr == issue1_rs2addr)
                             && issue0_rdaddr != 0) ?
                             issue0_data : (MemWb_RdWrtEn_0 && EXMem_RdAddr_0 == issue1_rs2addr && exforward_stall_delay && EXMem_RdAddr_0 != 0) ?
                             Dcache_DataRd_0 : s2_1;*/

assign issue1_forward_rs2 = (issue0_RdWrtEn && (issue0_rdaddr == issue1_rs2addr) && issue0_rdaddr != 0) ? issue0_data : 
                            (Mem_LdEN_0 && EXMem_RdAddr_0 == issue1_rs2addr && EXMem_RdAddr_0 != 0) ? Dcache_DataRd_0 : 
                            (Mem_LdEN_1 && EXMem_RdAddr_1 == issue1_rs2addr && EXMem_RdAddr_1 != 0) ? Dcache_DataRd_1 : s2_1;

endmodule