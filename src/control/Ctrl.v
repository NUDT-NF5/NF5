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
    input  wire  [1:0]   Decode_Stall   ,//Id_Wfi Id_Fence 
    input  wire	      	 DecodeHazard_StallReq ,
    input  wire          Mem_LdStFlag   ,
    input  wire          EX_LdStFlag    ,
    output reg   [4:0]   Ctrl_Stall     ,
    input  wire          EX_BranchFlag  ,
    input  wire          Csr_ExcpFlag   ,
    input  wire          Csr_WFIClrFlag	,//clr wfi_stall
	input  wire			 Decode_16BitFlag ,
    input  wire          EX_StallReq    ,
    output    [3:0]	 Flush,
input  wire	Csr_Memflush             
    );
reg [4:0]stage_flush; 
 reg [4:0]ctrl_flush;  
wire Idfence_ExReq = Decode_Stall[0]& EX_LdStFlag;
wire Idfence_MemReq= Decode_Stall[0]& Mem_LdStFlag;
wire WFI_Req= Csr_WFIClrFlag ? 1'b0 :Decode_Stall[1];
wire DecodeHazard_Stall=DecodeHazard_StallReq &! Csr_Memflush; 
 
 always @ (*) begin
		if(Csr_ExcpFlag|EX_BranchFlag) //wb-mem ex-mem id-ex if-id
			ctrl_flush=4'b0011; 
		else if(Decode_16BitFlag)
			ctrl_flush=4'b0001; 
		else
			ctrl_flush=4'b0000;
 end
assign Flush=ctrl_flush|stage_flush ;

/////////////stall_last ////////
 always @ (*) begin
	if(WFI_Req) 
        Ctrl_Stall = 5'b11111;
    else if(DecodeHazard_Stall)
        Ctrl_Stall = 5'b00011;
    else if(Dcache_StallReq |Idfence_MemReq)
        Ctrl_Stall = 5'b00111;
    else if(Idfence_ExReq)
        Ctrl_Stall = 5'b00011;
    else if(Icache_StallReq)
        Ctrl_Stall = 5'b00001; 
    else if(EX_StallReq)
        Ctrl_Stall = 5'b00111;
    else 
	   Ctrl_Stall = 5'b0;
  end

always @ (*) begin//wb-mem ex-mem id-ex if-id
     if(DecodeHazard_Stall)
        stage_flush = 4'b0010;
    else if(Dcache_StallReq |Idfence_MemReq)
        stage_flush = 4'b0100; 
    else if(Idfence_ExReq)
        stage_flush = 4'b0010; 
    else if(Icache_StallReq)
        stage_flush = 4'b0001; 
    else if(EX_StallReq)
        stage_flush = 4'b0100;
    else 
	  stage_flush = 4'b0;
  end

endmodule



