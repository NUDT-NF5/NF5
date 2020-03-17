module EXMem(
    input              clk,
    input              rst_n,
    input              Stall,
    input              Flush,
    input       [31:0] EX_AluData,
    input       [4:0]  IDEX_RdAddr,
    input              IDEX_WbSel,
    input       [1:0]  IDEX_StType,
    input       [31:0] New_Rs2Data,
    input       [2:0]  IDEX_LdType,
    input              IDEX_WbRdEn,
    output reg  [31:0] EXMem_AluData,
    output reg  [31:0] EXMem_Rs2Data,
    output reg         EXMem_RdWrtEn,
    output reg  [4:0]  EXMem_RdAddr,
    output reg         EXMem_WbSel,
    output reg  [1:0]  EXMem_StType,
    output reg  [2:0]  EXMem_LdType
);
//76 bits

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        EXMem_AluData <= 32'b0;
    end
    else if(Flush)begin
        EXMem_AluData <= 32'b0;
    end
    else if(~Stall)begin
        EXMem_AluData <= EX_AluData;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        EXMem_RdAddr  <= 32'b0;
        EXMem_WbSel   <= 1'b0;
        EXMem_StType  <= 2'b0;
        EXMem_Rs2Data <= 32'b0;
        EXMem_LdType  <= 3'b0;
        EXMem_RdWrtEn <= 32'b0;
    end
    else if(Flush)begin
        EXMem_RdAddr  <= 32'b0;
        EXMem_WbSel   <= 1'b0;
        EXMem_StType  <= 2'b0;
        EXMem_Rs2Data <= 32'b0;
        EXMem_LdType  <= 3'b0;
        EXMem_RdWrtEn <= 32'b0;
    end
    else if(~Stall)begin
        EXMem_RdAddr  <=  IDEX_RdAddr;
        EXMem_WbSel   <=  IDEX_WbSel;
        EXMem_StType  <=  IDEX_StType;
        EXMem_Rs2Data <=  New_Rs2Data;
        EXMem_LdType  <=  IDEX_LdType;
        EXMem_RdWrtEn <=  IDEX_WbRdEn;
    end
end

endmodule