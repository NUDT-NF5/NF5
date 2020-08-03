`include "../src/common/Define.v"
module ex_forward(
    input    [`RF_ADDR_WIDTH - 1:0]   issue0_rdaddr,
    input                             issue0_RdWrtEn,
    input                             inst_order_Mem_LdEn,
    input    [`RF_ADDR_WIDTH - 1:0]   issue1_rs1addr,
    input    [`RF_ADDR_WIDTH - 1:0]   issue1_rs2addr,
    input    [2:0]                    IDEX_LdType_0,
    input    [`DATA_WIDTH - 1:0]      s1_1,
    input    [`DATA_WIDTH - 1:0]      s2_1,
    input                             clk,
    input                             rst_n,
    input    [`DATA_WIDTH - 1:0]      Dcache_DataRd_0,
    input                             MemWb_RdWrtEn_0,
    input    [`RF_ADDR_WIDTH - 1:0]   MemWb_RdAddr_0,

    input    [`DATA_WIDTH - 1:0]      issue0_data,
    output   [`DATA_WIDTH - 1:0]      issue1_forward_rs1,
    output   [`DATA_WIDTH - 1:0]      issue1_forward_rs2,
    output                            exforward_stall
);
reg exforward_stall_delay;

/*always @*
    if(issue0_RdWrtEn && (issue0_rdaddr == issue1_rs1addr) && issue0_rdaddr != 0)
        case(alu_ic_en_0)
            1'b1: 
                issue1_forward_rs1 = issue_AluData_0;
            default:
                issue1_forward_rs1 = issue_AluData_m_0;
        endcase
    else if (MemWb_RdWrtEn_0 && MemWb_RdAddr_0 == issue1_rs1addr && exforward_stall_delay)
        issue1_forward_rs1 = Dcache_DataRd_0;
    else
        issue1_forward_rs1 = s1_1;

always @*
    if(issue0_RdWrtEn && (issue0_rdaddr == issue1_rs2addr) && issue0_rdaddr != 0)
        case(alu_ic_en_0)
            1'b1: 
                issue1_forward_rs2 = issue_AluData_0;
            default:
                issue1_forward_rs2 = issue_AluData_m_0;
        endcase
    else if (MemWb_RdWrtEn_0 && MemWb_RdAddr_0 == issue1_rs2addr && exforward_stall_delay)
        issue1_forward_rs2 = Dcache_DataRd_0;
    else
        issue1_forward_rs2 = s2_1;*/

assign issue1_forward_rs1 = (issue0_RdWrtEn && (issue0_rdaddr == issue1_rs1addr)
                             && issue0_rdaddr != 0) ?
                             issue0_data : (MemWb_RdWrtEn_0 && MemWb_RdAddr_0 == issue1_rs1addr && exforward_stall_delay && MemWb_RdAddr_0 != 0) ?
                             Dcache_DataRd_0 : s1_1;
assign issue1_forward_rs2 = (issue0_RdWrtEn && (issue0_rdaddr == issue1_rs2addr)
                             && issue0_rdaddr != 0) ?
                             issue0_data : (MemWb_RdWrtEn_0 && MemWb_RdAddr_0 == issue1_rs2addr && exforward_stall_delay && MemWb_RdAddr_0 != 0) ?
                             Dcache_DataRd_0 : s2_1;
assign exforward_stall    = ((inst_order_Mem_LdEn && (issue0_rdaddr == issue1_rs1addr)) ||
                             (inst_order_Mem_LdEn && (issue0_rdaddr == issue1_rs2addr))) ?
                             1'b1 : 1'b0;
always @(posedge clk or negedge rst_n)
    if(~rst_n)
        exforward_stall_delay <= 1'b0;
    else if(exforward_stall)
        exforward_stall_delay <= 1'b1;
    else
        exforward_stall_delay <= 1'b0;

endmodule