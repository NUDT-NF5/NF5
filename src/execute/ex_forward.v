module ex_forward(
    input    [`ADDR_WIDTH - 1 : 0]    issue0_rdaddr,
    input                             issue0_RdWrtEn,
    input                             inst_order_Mem_LdEn,
    input    [`ADDR_WIDTH - 1 : 0]    issue1_rs1addr,
    input    [`ADDR_WIDTH - 1 : 0]    issue1_rs2addr,
    input    [2:0]                    IDEX_LdType_0,
    input    [`DATA_WIDTH - 1:0]      s1_1,
    input    [`DATA_WIDTH - 1:0]      s2_1,

    input    [`DATA_WIDTH - 1:0]      issue0_data,
    output   [`DATA_WIDTH - 1:0]      issue1_forward_rs1,
    output   [`DATA_WIDTH - 1:0]      issue1_forward_rs2,
    output                            exforward_stall
);

assign issue1_forward_rs1 = (issue0_RdWrtEn && (issue0_rdaddr == issue1_rs1addr)
                             && issue0_rdaddr != 0) ?
                             issue0_data : s1_1;
assign issue1_forward_rs2 = (issue0_RdWrtEn && (issue0_rdaddr == issue1_rs1addr)
                             && issue0_rdaddr != 0) ?
                             issue0_data : s2_1;
assign exforward_stall    = ((inst_order_Mem_LdEn && (issue0_rdaddr == issue1_rs1addr)) ||
                             (inst_order_Mem_LdEn && (issue0_rdaddr == issue1_rs2addr))) ?
                             1'b1 : 1'b0;

endmodule