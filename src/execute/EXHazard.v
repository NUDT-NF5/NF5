/*
 * @Author: J-Zenk
 * @Date:   2020-12-22 16:23
 * @Last Modified by: J-Zenk
 * @Last Modified time: 2020-12-22 16:23
 * @Describe: decode data and control message from instruction 
 * @ModuleParamDescribe: the Describe of module param
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module EXHazard(
    //RF -> EXHazard
    input  [`RF_ADDR_WIDTH - 1 : 0]   IDEX_Rs1Addr,
    input  [`RF_ADDR_WIDTH - 1 : 0]   IDEX_Rs2Addr,    
    input  [`RF_ADDR_WIDTH - 1 : 0]   IDEX_Rs3Addr,

    input  [`SIMD_DATA_WIDTH - 1 : 0] RF_Rs1Data,
    input  [`SIMD_DATA_WIDTH - 1 : 0] RF_Rs2Data,
    input  [`SIMD_DATA_WIDTH - 1 : 0] RF_Rs3Data,

    input  [3:0]                      mask,
    input                             mask_ena,
    input                             simd_ena,
    input  [`FUNCT3_WIDTH - 1 : 0]    funct3,
    
    //EXMem -> EXHazard
    input  [`RF_ADDR_WIDTH - 1 : 0]   EXMem_RdAddr,
    //input                                 EXMem_RdWrtEN,
    input  [`SIMD_DATA_WIDTH - 1 : 0] EXMem_AluData,
    
    //Mem -> EXHazard
    input  [`SIMD_DATA_WIDTH - 1 : 0] Dcache_DataRd,
    input                             Mem_LdEN,
    
    //EXHazard -> IDEX
    output reg [`SIMD_DATA_WIDTH - 1 : 0] EXHazard_Rs1Data,
    output reg [`SIMD_DATA_WIDTH - 1 : 0] EXHazard_Rs2Data,
    output     [`SIMD_DATA_WIDTH - 1 : 0] EXHazard_Rs3Data
);
    reg                               rs1Sel;
    reg                               rs2Sel;
    reg                               rs3Sel;

    reg    [`SIMD_DATA_WIDTH - 1:0]   rs1_temp;
    reg    [`SIMD_DATA_WIDTH - 1:0]   rs2_temp;
    wire   [`SIMD_DATA_WIDTH - 1:0]   rs1;
    wire   [`SIMD_DATA_WIDTH - 1:0]   rs2;

    Mux #(
        .SEL_WIDTH(1),
        .SEL_NUM(2),
        .DATA_WIDTH(`SIMD_DATA_WIDTH),
        .DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2+1)
    ) i_Rs1Mux
    (
        .in({Dcache_DataRd, RF_Rs1Data}),
        .sel(rs1Sel),
        .out(rs1)
    );
    
    Mux #(
        .SEL_WIDTH(1),
        .SEL_NUM(2),
        .DATA_WIDTH(`SIMD_DATA_WIDTH),
        .DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2+1)
    ) i_Rs2Mux
    (
        .in({Dcache_DataRd, RF_Rs2Data}),
        .sel(rs2Sel),
        .out(rs2)
    );


    Mux #(
        .SEL_WIDTH(1),
        .SEL_NUM(2),
        .DATA_WIDTH(`SIMD_DATA_WIDTH),
        .DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2+1)
    ) i_Rs3Mux
    (
        .in({Dcache_DataRd, RF_Rs3Data}),
        .sel(rs3Sel),
        .out(EXHazard_Rs3Data)
    );

always @*
    if(IDEX_Rs1Addr != 5'b0)
        if(Mem_LdEN && IDEX_Rs1Addr == EXMem_RdAddr)
            rs1Sel = 1'b1;
        else
            rs1Sel = 1'b0;
    else 
        rs1Sel = 1'b0;

//rs2 forward
always @*
    if(IDEX_Rs2Addr != 5'b0)
        if(Mem_LdEN && IDEX_Rs2Addr == EXMem_RdAddr)
            rs2Sel = 1'b1;
        else
            rs2Sel = 1'b0;
    else 
        rs2Sel = 1'b0;

//rs3 forward
always @*
    if(IDEX_Rs3Addr != 5'b0)
        if(Mem_LdEN && IDEX_Rs3Addr == EXMem_RdAddr)
            rs3Sel = 1'b1;
        else
            rs3Sel = 1'b0;
    else 
        rs3Sel = 1'b0;

always @*
    if(simd_ena && funct3[2])  //horizontal operation
        case(funct3[1:0])
            `SIMD16 : begin
                rs1_temp = {rs1[63:48], rs2[63:48], rs1[31:16], rs2[31:16]};
                rs2_temp = {rs1[47:32], rs2[47:32], rs1[15:0],  rs2[15:0]};
            end
            `SIMD32 : begin
                rs1_temp = {rs1[63:32], rs2[63:32]};
                rs2_temp = {rs1[31:0],  rs2[31:0]};
            end
            default : begin
                rs1_temp = rs1;
                rs2_temp = rs2;
            end
        endcase
    else begin
        rs1_temp = rs1;
        rs2_temp = rs2;
    end

always @*
    if(simd_ena && mask_ena)
        case(funct3[1:0])
            `SIMD16 : begin
                EXHazard_Rs1Data = {{16{mask[3]}}, {16{mask[2]}}, {16{mask[1]}}, {16{mask[0]}}
                                   & rs1_temp};
                EXHazard_Rs2Data = {{16{mask[3]}}, {16{mask[2]}}, {16{mask[1]}}, {16{mask[0]}}
                                   & rs2_temp};
            end
            `SIMD32 : begin
                EXHazard_Rs1Data = {{32{mask[1]}}, {32{mask[0]}}} & rs1_temp;
                EXHazard_Rs2Data = {{32{mask[1]}}, {32{mask[0]}}} & rs2_temp;
            end
            default : begin
                EXHazard_Rs1Data = rs1_temp;
                EXHazard_Rs2Data = rs2_temp;
            end
        endcase
    else begin
        EXHazard_Rs1Data = rs1_temp;
        EXHazard_Rs2Data = rs2_temp;
    end

endmodule
