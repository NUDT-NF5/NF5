/*
 * @Author: Kefan-Xu
 * @Date:   2019-10-30 10:00
 * @Last Modified by: Kefan-Xu
 * @Last Modified time: 2019-10-30 10:00
 * @Describe: ctrl  for all module
 */
`include "../src/common/Define.v"
module Ctrl(
    input  wire          Icache_StallReq,
    input  wire          Dcache_StallReq,
    input  wire  [1:0]   Decode_Stall_0   ,//Id_Wfi Id_Fence 
    input  wire          DecodeHazard_StallReq,
    input  wire          Mem_LdStFlag_0   ,
    input  wire          EX_LdStFlag_0    ,
    input  wire          EX_BranchFlag_0  ,
    input  wire          Csr_ExcpFlag   ,
    input  wire          Csr_WFIClrFlag    ,//clr wfi_stall
    input  wire          Decode_16BitFlag_0 ,
    input  wire  [`ADDR_WIDTH - 1:0] EX_BranchPC_0,
    input  wire          EX_StallReq    ,
    output reg   [4:0]   Ctrl_Stall     ,
    output [3:0]         issue_select,

    input  wire  [1:0]   Decode_Stall_1   ,//Id_Wfi Id_Fence 
    //input  wire          DecodeHazard_StallReq_1 ,
    input  wire          Mem_LdStFlag_1   ,
    input  wire          EX_LdStFlag_1    ,
    input  wire          EX_BranchFlag_1  ,
    input  wire          Decode_16BitFlag_1 ,
    input  wire  [`ADDR_WIDTH - 1:0] EX_BranchPC_1,
    output wire  [`ADDR_WIDTH - 1:0] EX_BranchPC,
    input                IDEX_stall,

    output       [3:0]   Flush,
    output               EX_BranchFlag,
    input  wire          Csr_Memflush             
    );
reg [4:0]stage_flush; 
reg [4:0]ctrl_flush;  
wire Idfence_ExReq_0 = Decode_Stall_0[0]& EX_LdStFlag_0;
wire Idfence_MemReq_0= Decode_Stall_0[0]& Mem_LdStFlag_0;
wire Idfence_ExReq_1 = Decode_Stall_1[0]& EX_LdStFlag_1;
wire Idfence_ExReq = Idfence_ExReq_0 || Idfence_ExReq_1;
wire Idfence_MemReq_1= Decode_Stall_1[0]& Mem_LdStFlag_1;
wire Idfence_MemReq  = Idfence_MemReq_0 || Idfence_MemReq_1;
wire WFI_Req= Csr_WFIClrFlag ? 1'b0 :Decode_Stall_0[1] || Decode_Stall_1[1];
//wire DecodeHazard_Stall=DecodeHazard_StallReq_0 || DecodeHazard_StallReq_1 &! Csr_Memflush; 
reg  [3:0] ctrl_issue_select;
reg  [3:0] stage_issue_select;

assign EX_BranchFlag = EX_BranchFlag_0 || EX_BranchFlag_1;
assign EX_BranchPC = (EX_BranchFlag_0 && EX_BranchFlag_1) ? EX_BranchPC_0 : 
                     EX_BranchFlag_0 ? EX_BranchPC_0 : EX_BranchPC_1;

assign issue_select = ctrl_issue_select | stage_issue_select;

 always @ (*) begin
        if(Csr_ExcpFlag|EX_BranchFlag_0)begin //wb-mem ex-mem id-ex if-id
            ctrl_flush = 4'b0111;
            ctrl_issue_select = 4'b0011; 
        end
        else if(Csr_ExcpFlag|EX_BranchFlag_1)begin //wb-mem ex-mem id-ex if-id
            ctrl_flush = 4'b0011;
            ctrl_issue_select = 4'b0011; 
        end
        else if(Decode_16BitFlag_0)begin
            ctrl_flush=4'b0011; 
            ctrl_issue_select = 4'b0001; 
        end
        else if(Decode_16BitFlag_1)begin
            ctrl_flush=4'b0001; 
            ctrl_issue_select = 4'b0001; 
        end
        else begin
            ctrl_flush=4'b0000;
            ctrl_issue_select = 4'b0; 
        end
 end
assign Flush=ctrl_flush|stage_flush ;

/////////////stall_last ////////
 always @ (*) begin
    if(WFI_Req) 
        Ctrl_Stall = 5'b11111;
    else if(DecodeHazard_StallReq)
        Ctrl_Stall = 5'b00011;
    else if(Dcache_StallReq |Idfence_MemReq)
        Ctrl_Stall = 5'b00111;
    else if(Idfence_ExReq | IDEX_stall)
        Ctrl_Stall = 5'b00011;
    else if(Icache_StallReq)
        Ctrl_Stall = 5'b00001; 
    else if(EX_StallReq)
        Ctrl_Stall = 5'b00111;
    else 
       Ctrl_Stall = 5'b0;
  end

always @ (*) begin//wb-mem ex-mem id-ex if-id
    if(DecodeHazard_StallReq)begin
        stage_flush = 4'b0010;
        stage_issue_select = 4'b0010;
    end
    else if(Dcache_StallReq |Idfence_MemReq_0)begin
        stage_flush = 4'b0010; 
        stage_issue_select = 4'b0010;
    end
    else if(Dcache_StallReq |Idfence_MemReq_1)begin
        stage_flush = 4'b0100; 
        stage_issue_select = 4'b0;
    end
    else if(Idfence_ExReq_0)begin
        stage_flush = 4'b0001;
        stage_issue_select = 4'b0001;
    end 
    else if(Idfence_ExReq_1)begin
        stage_flush = 4'b0010;
        stage_issue_select = 4'b0;
    end
    else if(Icache_StallReq)begin
        stage_flush = 4'b0001; 
        stage_issue_select = 4'b0;
    end
    else if(EX_StallReq)begin
        stage_flush = 4'b0100;
        stage_issue_select = 4'b0;
    end
    else begin
      stage_flush = 4'b0;
      stage_issue_select = 4'b0;
    end
  end

endmodule



