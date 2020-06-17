/*
 * @Author: Sue
 * @Date:   2019-10-28 15:51
 * @Last Modified by: mikey.zhaopeng
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: simple TB for all module
 */
`include "../src/common/Define.v"
module Core(
	input									clk,
	input									rst_n
);
	wire	[`ADDR_WIDTH - 1 : 0]			Fetch_NextPC;

	wire	[`ADDR_WIDTH - 1 : 0]			IFID_NowPC;
	wire	[`INSTR_WIDTH - 1 : 0]			IFID_Instr;

	//part 1
	wire	[`All_CTRL_WIDTH - 1 : 0]		Decode_AllCtr_0;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_RdAddr_0;
	wire	[`DATA_WIDTH - 1 : 0]			Decode_Imm_0;
	wire	[`IMM_SEL_WIDTH - 1 : 0]		Decode_ImmSel_0;
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		Decode_CsrAddr_0;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_Rs1Addr_0;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_Rs2Addr_0;
	wire	[`FUNCT3_WIDTH - 1 : 0]	        Decode_Rm_0;
	wire	[2 - 1 : 0]						Decode_Stall_0;
	wire	[4 - 1 : 0]						Decode_Flush_0;
	wire									Decode_16BitFlag_0;
	wire 	[`LD_TYPE_WIDTH - 1 : 0 ]		Decode_LdType_0;

	//part 2
	wire	[`All_CTRL_WIDTH - 1 : 0]		Decode_AllCtr_1;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_RdAddr_1;
	wire	[`DATA_WIDTH - 1 : 0]			Decode_Imm_1;
	wire	[`IMM_SEL_WIDTH - 1 : 0]		Decode_ImmSel_1;
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		Decode_CsrAddr_1;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_Rs1Addr_1;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_Rs2Addr_1;
	wire	[`FUNCT3_WIDTH - 1 : 0]	        Decode_Rm_1;
	wire	[2 - 1 : 0]						Decode_Stall_1;
	wire	[4 - 1 : 0]						Decode_Flush_1;
	wire									Decode_16BitFlag_1;
	wire 	[`LD_TYPE_WIDTH - 1 : 0 ]		Decode_LdType_1;

	wire 	[2 - 1 : 0]						Decode_NextPC;

	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs1Data_0;
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs2Data_0;
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs1Data_1;
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs2Data_1;
	wire	     							DecodeHazard_StallReq;
	
	wire	[`PC_SEL_WIDTH - 1 : 0 ]		IDEX_PcSel;
	wire	[`A_SEL_WIDTH - 1 : 0 ]			IDEX_Sel1;
	wire	[`B_SEL_WIDTH - 1 : 0 ]			IDEX_Sel2;
	wire	[`ALU_OP_WIDTH - 1 : 0 ]		IDEX_AluOp;
	wire	[`ST_TYPE_WIDTH - 1 : 0 ]		IDEX_StType;
	wire	[`LD_TYPE_WIDTH - 1 : 0 ]		IDEX_LdType;
	wire	[`WB_SEL_WIDTH - 1 : 0 ]		IDEX_WbSel;
	wire	[`BOOL_WIDTH - 1 : 0 ]			IDEX_WbRdEn;
	wire	[`CSR_CMD_WIDTH - 1 : 0 ]		IDEX_CsrCmd;
	wire	[`BOOL_WIDTH - 1 : 0 ]			IDEX_CsrIllegal;

	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_RdAddr;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Imm;
	wire  	[`IMM_SEL_WIDTH - 1:0]         	IDEX_ImmSel;  
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		IDEX_CsrAddr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs1Addr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs2Addr;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Rs1Data;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Rs2Data;
	wire									IDEX_16BitFlag;
	wire	[`ADDR_WIDTH - 1 : 0]			IDEX_NowPC;
				
	wire	[`DATA_WIDTH - 1 : 0]			RF_Rs1Data;
	wire	[`DATA_WIDTH - 1 : 0]			RF_Rs2Data;
	
    wire    [31:0] 							EX_AluData;
    wire           							EX_LdStFlag;
	wire									EX_BranchFlag;
	wire	[`ADDR_WIDTH - 1 : 0]			EX_BranchPC;
	wire									EX_StallReq;
	
    wire    [31:0] 							EXMem_AluData;
    wire    [31:0] 							EXMem_Rs2Data;
    wire           							EXMem_RdWrtEn;
    wire    [4:0]  							EXMem_RdAddr;
    wire           							EXMem_WbSel;
    wire    [1:0]  							EXMem_StType;
    wire    [2:0]  							EXMem_LdType;

    wire                          		 	Mem_LdEn;        
    wire                          		 	Mem_DcacheEn;    
    wire                          		 	Mem_DcacheRd;    
    wire  	[1:0]      			  			Mem_DcacheWidth; 
    wire  	[`ADDR_WIDTH-1  :0]     		Mem_DcacheAddr;
	wire									Mem_DcacheSign;   

	wire  	[`DATA_WIDTH-1  :0]      		Dcache_DataRd;
	wire  	[`INSTR_WIDTH-1  :0]      		Icache_Instr;

    wire                       				MemWb_WbSel;
    wire  	[`DATA_WIDTH-1 :0]   			MemWb_AluData;
    wire  	[`DATA_WIDTH-1 :0]   			MemWb_DataRd;
    wire  	[`RF_ADDR_WIDTH-1:0] 			MemWb_RdAddr;
	
	
	wire  	[`DATA_WIDTH-1 :0]   			Wb_DataWrt;
    wire                       				MemWb_RdWrtEn;

	wire   	[4:0]   						Ctrl_Stall;	
	wire	[3:0]							Flush;
	  
    wire   [`DATA_WIDTH-1:0]           		Csr_RdData;                             
    wire   [`ADDR_WIDTH-1:0]           		Csr_Evec;
    wire                               		Csr_ExcpFlag;
    wire                               		Csr_Memflush;
    wire                                    Csr_WFIClrFlag;	
		
	// Ctrl i_Ctrl(
	// 	.Icache_StallReq(1'b0),
	// 	.Dcache_StallReq(1'b0),
	// 	.Decode_Stall   (Decode_Stall),
	// 	.Mem_LdStFlag   (Mem_DcacheEn),
 //        .DecodeHazard_StallReq(DecodeHazard_StallReq),//data_hazard
	// 	.EX_LdStFlag    (EX_LdStFlag),
	// 	.Ctrl_Stall     (Ctrl_Stall),
	// 	.EX_BranchFlag  (EX_BranchFlag),
	// 	.EX_StallReq	(EX_StallReq),
	// 	.Csr_ExcpFlag   (Csr_ExcpFlag),
	// 	.Decode_16BitFlag(Decode_16BitFlag),
	// 	.Flush			(Flush) ,
 //        .Csr_WFIClrFlag (Csr_WFIClrFlag ) ,
 //        .Csr_Memflush(Csr_Memflush)  
 //    );
	
//wire Fetchaddr_Invalid;
//wire nomisalign_Br= EX_BranchFlag ;//&!Fetchaddr_Invalid;
	
	Fetch i_Fetch(
		.clk(clk),
		.rst_n(rst_n),
		.Stall(1'b0),//need to edit control
		.IFID_NowPC(IFID_NowPC),
		.Fetch_NextPC(Fetch_NextPC),
		.Ctrl_ExcpFlag(1'b0),//need to edit control
		.Ctrl_ExcpPC(32'h0000_0008),//need to edit control
		.EX_BranchFlag(1'b0),//need to edit ex
             //.EX_BranchFlag(nomisalign_Br),
		.EX_BranchPC(32'h0000_000b),//need to edit ex
		.Decode_NextPC(Decode_NextPC)//the low 16bit of IFID_Instr is 16-bit instr

	);

  PipeStage3 #(
		.STAGE_WIDTH(`PIPE_IFID_LEN)
	)
	i_IFID(
		.clk(clk),
		.rst_n(rst_n),
		.rst_value(96'h00000000_00000013_00000013),//rst and flush with 2 nops
		.Stall(1'b0),//need to edit control
		.Flush(1'b0),//need to edit control
		.in( {Fetch_NextPC , Icache_Instr} ),
		.out( {IFID_NowPC , IFID_Instr} )
	);

	Decode i_Decode(
		// .IFID_Instr(64'h00000013_00000013), // 32/32
		// .IFID_Instr(64'h57c157c1_00000013), // 16/16/32
		// .IFID_Instr(64'h57c157c1_57c157c1), // 16/16/16/16
		// .IFID_Instr(64'h00000013_57c157c1), // 32/16/16
		// .IFID_Instr(64'h57c10000_001357c1), // 16/32/16
		.IFID_Instr(IFID_Instr),
		//part 0
		.Decode_AllCtr_0(Decode_AllCtr_0),
		.Decode_RdAddr_0(Decode_RdAddr_0),
		.Decode_Imm_0(Decode_Imm_0),
		.Decode_ImmSel_0(Decode_ImmSel_0),
		.Decode_CsrAddr_0(Decode_CsrAddr_0),
		.Decode_Rs1Addr_0(Decode_Rs1Addr_0),
		.Decode_Rs2Addr_0(Decode_Rs2Addr_0),
        .Decode_Rm_0(Decode_Rm_0),
		.Decode_Stall_0(Decode_Stall_0),
		.Decode_Flush_0(Decode_Flush_0),
		.Decode_16BitFlag_0(Decode_16BitFlag_0),
		.Decode_LdType_0(Decode_LdType_0),
		//part 1
		.Decode_AllCtr_1(Decode_AllCtr_1),
		.Decode_RdAddr_1(Decode_RdAddr_1),
		.Decode_Imm_1(Decode_Imm_1),
		.Decode_ImmSel_1(Decode_ImmSel_1),
		.Decode_CsrAddr_1(Decode_CsrAddr_1),
		.Decode_Rs1Addr_1(Decode_Rs1Addr_1),
		.Decode_Rs2Addr_1(Decode_Rs2Addr_1),
        .Decode_Rm_1(Decode_Rm_1),
		.Decode_Stall_1(Decode_Stall_1),
		.Decode_Flush_1(Decode_Flush_1),
		.Decode_16BitFlag_1(Decode_16BitFlag_1),
		.Decode_LdType_1(Decode_LdType_1),
		.Decode_NextPC(Decode_NextPC)
	);
	
	// RegFile i_RegFile(
	// 	.clk(clk),
	// 	.rst_n(rst_n),
	// 	.rAddr1(Decode_Rs1Addr),
	// 	.rData1(RF_Rs1Data),
	// 	.rAddr2(Decode_Rs2Addr),
	// 	.rData2(RF_Rs2Data),
	// 	.wEN(MemWb_RdWrtEn),
	// 	.wAddr(MemWb_RdAddr),
	// 	.wData(Wb_DataWrt)
	// );

// 	DecodeHazard i_DecodeHazard(
// 		.clk(clk),
// 		.rst_n(rst_n),
// 		.Decode_Rs1Addr(Decode_Rs1Addr),
// 		.Decode_Rs2Addr(Decode_Rs2Addr),	
// 		.RF_Rs1Data(RF_Rs1Data),
// 		.RF_Rs2Data(RF_Rs2Data),
// 		.IDEX_RdAddr(IDEX_RdAddr),
// 		.IDEX_WbRdEn(IDEX_WbRdEn),
// 		.EX_AluData(EX_AluData),
// 		.EXMem_RdAddr(EXMem_RdAddr),
// 		.EXMem_RdWrtEn(EXMem_RdWrtEn),
// 		.EXMem_AluData(EXMem_AluData),
// 		.Dcache_DataRd(Dcache_DataRd),
// 		.Mem_LdEn(Mem_LdEn),
// 		.MemWb_RdAddr(MemWb_RdAddr),
// 		.MemWb_RdWrtEn(MemWb_RdWrtEn),
// 		.Wb_DataWrt(Wb_DataWrt),
// 		.Decode_LdType(Decode_LdType),
// 		.DecodeHazard_StallReq(DecodeHazard_StallReq),
// 		.DecodeHazard_Rs1Data(DecodeHazard_Rs1Data),
// 		.DecodeHazard_Rs2Data(DecodeHazard_Rs2Data)
// 	);
	

//    PipeStage #(
// 		.STAGE_WIDTH(`PIPE_IDEX_LEN)
// 	)
// 	i_IDEX(
// 		.clk(clk),
// 		.rst_n(rst_n),
// 		.Stall(Ctrl_Stall[2]),
// 		.Flush(Flush[1]),
// 		.in(
// 			{
// 				Decode_AllCtr,
// 				Decode_RdAddr,
// 				Decode_Rs1Addr,
// 				Decode_Rs2Addr,
// 				Decode_Imm,
// 				Decode_ImmSel,
// 				Decode_CsrAddr,
// 				DecodeHazard_Rs1Data,
// 				DecodeHazard_Rs2Data,
// 				Decode_16BitFlag,
// 				IFID_NowPC
// 			} 
// 		),
// 		.out(
// 			{
// 				IDEX_Sel1,
// 				IDEX_Sel2,
// 				IDEX_AluOp,
// 				IDEX_StType,
// 				IDEX_LdType,
// 				IDEX_WbSel,
// 				IDEX_WbRdEn,
// 				IDEX_CsrCmd,
// 				IDEX_CsrIllegal,
// 				IDEX_RdAddr,
// 				IDEX_Rs1Addr,
// 				IDEX_Rs2Addr,
// 				IDEX_Imm,
// 				IDEX_ImmSel,
// 				IDEX_CsrAddr,
// 				IDEX_Rs1Data,
// 				IDEX_Rs2Data,
// 				IDEX_16BitFlag,
// 				IDEX_NowPC
// 			} 
// 		)
// 	);
	
// 	EX i_EX (
// 		.IDEX_Rs1Data(IDEX_Rs1Data),
// 		.IDEX_Rs2Data(IDEX_Rs2Data),
// 		.IDEX_Sel1(IDEX_Sel1),
// 		.IDEX_NowPC(IDEX_NowPC),
// 		.IDEX_Sel2(IDEX_Sel2),
// 		.IDEX_Imm(IDEX_Imm),
// 		//.Dcache_DataRd(Dcache_DataRd), 
// 		//.Mem_LdEn(Mem_LdEn), 
// 		//.IDEX_Rs1Addr(IDEX_Rs1Addr), 
//         //.IDEX_Rs2Addr(IDEX_Rs2Addr), 
// 		//.EXMem_RdAddr(EXMem_RdAddr),
// 		.Csr_RdData(Csr_RdData),
// 		.IDEX_AluOp(IDEX_AluOp),
// 		.IDEX_LdType(IDEX_LdType),
// 		.IDEX_StType(IDEX_StType),
// 		.Mem_DcacheEN(Mem_DcacheEn),
// 		.IDEX_16BitFlag(IDEX_16BitFlag),
// 		.clk(clk),
// 		.rst_n(rst_n),
// 		.EX_AluData(EX_AluData),
// 		.EX_BranchFlag(EX_BranchFlag),
// 		.EX_BranchPC(EX_BranchPC),
// 		.EX_LdStFlag(EX_LdStFlag),
// 		.EX_StallReq(EX_StallReq)
// 	);
// wire [31:0] EXMEM_NowPC;	
// 	Csr i_Csr (
//         .clk(clk),
//         .rst_n(rst_n),
//         .Ctrl_Stall(Ctrl_Stall),
//         .IDEX_CsrAddr(IDEX_CsrAddr),
//         .IDEX_CsrCmd(IDEX_CsrCmd),
//         .Csr_RdData(Csr_RdData),
//         .Csr_ExcpFlag(Csr_ExcpFlag),
//         .Csr_Evec(Csr_Evec),
//         .Csr_Memflush(Csr_Memflush),
//         .NMI(1'b0),
//         .RESET(1'b0),
//         .IDEX_NowPC(IDEX_NowPC),
//         .IFID_NowPC(IFID_NowPC),
//         .IDEX_Imm(IDEX_Imm),
//         .IDEX_Rs1Data(IDEX_Rs1Data),
//         .IDEX_ImmSel(IDEX_ImmSel),
//         .Core_interrupt(3'b0),
//         .DBG_interrupt (5'b0),
//         .EX_AluData(EX_AluData),
//         .IDEX_StType(IDEX_StType),
//         .IDEX_LdType(IDEX_LdType),
//         .EX_BranchFlag(EX_BranchFlag),
//         .Decode_Flush(Decode_Flush),
//         .Csr_WFIClrFlag  (Csr_WFIClrFlag ) ,
// 		.EXMem_LdType(EXMem_LdType),    
// 		.EXMem_StType(EXMem_StType),    
// 		.EXMem_AluData(EXMem_AluData) ,
// 		.EX_BranchPC(EX_BranchPC), //new   
//                .EXMEM_NowPC(EXMEM_NowPC),
// 		.Decode_16BitFlag(Decode_16BitFlag),
//                .Fetchaddr_Invalid(Fetchaddr_Invalid),
// .IFID_Instr(IFID_Instr)
// 	);	
		

// 	PipeStage #(
// 		.STAGE_WIDTH(`PIPE_EXMem_LEN)
// 	)
// 	i_EXMem(
// 		.clk(clk),
// 		.rst_n(rst_n),
// 		.Stall(Ctrl_Stall[3]),
// 		.Flush(Csr_Memflush|Flush[2]),	
// 		.in(
// 			{
// 				EX_AluData,
// 				IDEX_RdAddr,
// 				IDEX_Rs2Data,
// 				IDEX_StType,
// 				IDEX_LdType,
// 				IDEX_WbRdEn,
// 				IDEX_WbSel,
//                           IDEX_NowPC
// 			} 
// 		),
// 		.out(
// 			{
// 				EXMem_AluData,
// 				EXMem_RdAddr,
// 				EXMem_Rs2Data,
// 				EXMem_StType,
// 				EXMem_LdType,				
// 				EXMem_RdWrtEn,
// 				EXMem_WbSel,
//                           EXMEM_NowPC
// 			} 
// 		)
// 	);

// 	Mem i_Mem(
// 		.EXMem_LdType(EXMem_LdType),    
// 		.EXMem_StType(EXMem_StType),    
// 		.EXMem_AluData(EXMem_AluData),   
// 		.Mem_LdEN(Mem_LdEn),        
// 		.Mem_DcacheEN(Mem_DcacheEn),    
// 		.Mem_DcacheRd(Mem_DcacheRd),  
// 		.Mem_DcacheSign(Mem_DcacheSign),  
// 		.Mem_DcacheWidth(Mem_DcacheWidth), 
// 		.Mem_DcacheAddr(Mem_DcacheAddr),
//             .Csr_Memflush(Csr_Memflush)//new   
//     ); 	
	
	// Dcache i_Dcache(
	// 	.clk(clk),
	// 	.rst_n(rst_n),
	// 	.Mem_DcacheEN(Mem_DcacheEn),    
	// 	.Mem_DcacheRd(Mem_DcacheRd),    
	// 	.Mem_DcacheWidth(Mem_DcacheWidth), 
	// 	.Mem_DcacheAddr(Mem_DcacheAddr),   
	// 	.EXMem_Rs2Data(EXMem_Rs2Data),
	// 	.Mem_DcacheSign(Mem_DcacheSign), 
	// 	.Dcache_DataRd(Dcache_DataRd),
	// 	.Icache_NextPC(Fetch_NextPC),
	// 	.Icache_Instr(Icache_Instr)
	// );
	
// 	PipeStage #(
// 		.STAGE_WIDTH(`PIPE_MemWb_LEN)
// 	)
// 	i_MemWb(
// 		.clk(clk),
// 		.rst_n(rst_n),
// 		.Stall(Ctrl_Stall[4]),
// 		.Flush(Csr_Memflush|Flush[3]),
// 		.in(
// 			{
// 				EXMem_RdAddr,
// 				EXMem_RdWrtEn,
// 				EXMem_AluData,
// 				Dcache_DataRd,
// 				EXMem_WbSel
// 			} 
// 		),
// 		.out(
// 			{
// 				MemWb_RdAddr,
// 				MemWb_RdWrtEn,
// 				MemWb_AluData,
// 				MemWb_DataRd,
// 				MemWb_WbSel
// 			} 
// 		)
// 	);

// 	Wb i_Wb(
// 		.MemWb_WbSel(MemWb_WbSel),
// 		.MemWb_AluData(MemWb_AluData),
// 		.MemWb_DataRd(MemWb_DataRd),
// 		.Wb_DataWrt(Wb_DataWrt)
//     );
		
endmodule