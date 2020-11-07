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

	wire	[`All_CTRL_WIDTH - 1 : 0]		Decode_AllCtr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_RdAddr;
	wire	[`DATA_WIDTH - 1 : 0]			Decode_Imm;
	wire	[`IMM_SEL_WIDTH - 1 : 0]		Decode_ImmSel;
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		Decode_CsrAddr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_Rs1Addr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_Rs2Addr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		Decode_Rs3Addr;
	wire	[`FUNCT3_WIDTH - 1 : 0]	        Decode_Rm;
	wire	[2 - 1 : 0]						Decode_Stall;
	wire	[4 - 1 : 0]						Decode_Flush;
	wire									Decode_16BitFlag;
	wire 	[`LD_TYPE_WIDTH - 1 : 0 ]		Decode_LdType;
	wire	[2 - 1 : 0]						Decode_Fmt;
	
	wire  	[`SIMD_DATA_WIDTH-1 :0]   		DecodeHazard_Rs1Data;
	wire  	[`SIMD_DATA_WIDTH-1 :0]   		DecodeHazard_Rs2Data;
	wire  	[`SIMD_DATA_WIDTH-1 :0]   		DecodeHazard_Rs3Data;
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
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		IDEX_Rs1Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		IDEX_Rs2Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		IDEX_Rs3Data;
	wire									IDEX_16BitFlag;
	wire	[`ADDR_WIDTH - 1 : 0]			IDEX_NowPC;
				
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		RF_Rs1Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		RF_Rs2Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		RF_Rs3Data;
	
    wire    [`SIMD_DATA_WIDTH - 1 : 0] 		EX_AluData;
    wire           							EX_LdStFlag;
	wire									EX_BranchFlag;
	wire	[`ADDR_WIDTH - 1 : 0]			EX_BranchPC;
	wire									EX_StallReq;
	
    wire    [`SIMD_DATA_WIDTH - 1 : 0]      EXMem_AluData;
    wire    [`SIMD_DATA_WIDTH - 1 : 0]      EXMem_Rs2Data;
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

	wire  	[`DATA_WIDTH-1  :0]          	Dcache_DataRd;
	wire  	[`DATA_WIDTH-1  :0]      		Icache_Instr;

    wire                       				MemWb_WbSel;
    wire  	[`SIMD_DATA_WIDTH-1 :0]   		MemWb_AluData;
    wire  	[`DATA_WIDTH-1 :0]   	    	MemWb_DataRd;
    wire  	[`RF_ADDR_WIDTH-1:0] 			MemWb_RdAddr;
	
	
	wire  	[`SIMD_DATA_WIDTH-1 :0]   		Wb_DataWrt;
    wire                       				MemWb_RdWrtEn;

	wire   	[4:0]   						Ctrl_Stall;	
	wire	[3:0]							Flush;
	  
    wire   [`DATA_WIDTH-1:0]           		Csr_RdData;                             
    wire   [`ADDR_WIDTH-1:0]           		Csr_Evec;
    wire                               		Csr_ExcpFlag;
    wire                               		Csr_Memflush;
    wire                                    Csr_WFIClrFlag;	
		
	Ctrl i_Ctrl(
		.Icache_StallReq(1'b0),
		.Dcache_StallReq(1'b0),
		.Decode_Stall   (Decode_Stall),
		.Mem_LdStFlag   (Mem_DcacheEn),
        .DecodeHazard_StallReq(DecodeHazard_StallReq),//data_hazard
		.EX_LdStFlag    (EX_LdStFlag),
		.Ctrl_Stall     (Ctrl_Stall),
		.EX_BranchFlag  (EX_BranchFlag),
		.EX_StallReq	(EX_StallReq),
		.Csr_ExcpFlag   (Csr_ExcpFlag),
		.Decode_16BitFlag(Decode_16BitFlag),
		.Flush			(Flush) ,
        .Csr_WFIClrFlag (Csr_WFIClrFlag ) ,
        .Csr_Memflush(Csr_Memflush)  
    );
	
//wire Fetchaddr_Invalid;
//wire nomisalign_Br= EX_BranchFlag ;//&!Fetchaddr_Invalid;
	Fetch i_Fetch(
		.clk(clk),
		.rst_n(rst_n),
		.Stall(Ctrl_Stall[0]),
		.IFID_NowPC(IFID_NowPC),
		.Fetch_NextPC(Fetch_NextPC),
		.Ctrl_ExcpFlag(Csr_ExcpFlag),
		.Ctrl_ExcpPC(Csr_Evec),
		.EX_BranchFlag(EX_BranchFlag),
             //.EX_BranchFlag(nomisalign_Br),
		.EX_BranchPC(EX_BranchPC),
		.Decode_16BitFlag(Decode_16BitFlag)

	);
	

  PipeStage3 #(
		.STAGE_WIDTH(`PIPE_IFID_LEN)
	)
	i_IFID(
		.clk(clk),
		.rst_n(rst_n),
		.rst_value(64'h00000000_00000013),//rst and flush with nop
		.Stall(Ctrl_Stall[1]),
		.Flush(Flush[0]),
		.in( {Fetch_NextPC , Icache_Instr} ),
		.out( {IFID_NowPC , IFID_Instr} )
	);
	
	Decode i_Decode(
		.IFID_Instr(IFID_Instr),
		.Decode_AllCtr(Decode_AllCtr),
		.Decode_RdAddr(Decode_RdAddr),
		.Decode_Imm(Decode_Imm),
		.Decode_ImmSel(Decode_ImmSel),
		.Decode_CsrAddr(Decode_CsrAddr),
		.Decode_Rs1Addr(Decode_Rs1Addr),
		.Decode_Rs2Addr(Decode_Rs2Addr),
		.Decode_Rs3Addr(Decode_Rs3Addr),
        .Decode_Rm(Decode_Rm),
		.Decode_Stall(Decode_Stall),
		.Decode_Flush(Decode_Flush),
		.Decode_16BitFlag(Decode_16BitFlag),
		.Decode_LdType(Decode_LdType),
		.Decode_Fmt(Decode_Fmt)
	);
	
	RegFile i_RegFile(
		.clk(clk),
		.rst_n(rst_n),
		.rAddr1(Decode_Rs1Addr),
		.rData1(RF_Rs1Data),
		.rAddr2(Decode_Rs2Addr),
		.rData2(RF_Rs2Data),
		.rAddr3(Decode_Rs3Addr),
		.rData3(RF_Rs3Data),
		.wEN(MemWb_RdWrtEn),
		.wAddr(MemWb_RdAddr),
		.wData(Wb_DataWrt)
	);

	DecodeHazard i_DecodeHazard(
		.clk(clk),
		.rst_n(rst_n),
		.Decode_Rs1Addr(Decode_Rs1Addr),
		.Decode_Rs2Addr(Decode_Rs2Addr),
		.Decode_Rs3Addr(Decode_Rs3Addr),	
		.RF_Rs1Data(RF_Rs1Data),
		.RF_Rs2Data(RF_Rs2Data),
		.RF_Rs3Data(RF_Rs3Data),
		.IDEX_RdAddr(IDEX_RdAddr),
		.IDEX_WbRdEn(IDEX_WbRdEn),
		.EX_AluData(EX_AluData),
		.EXMem_RdAddr(EXMem_RdAddr),
		.EXMem_RdWrtEn(EXMem_RdWrtEn),
		.EXMem_AluData(EXMem_AluData),
		.Dcache_DataRd(Dcache_DataRd),
		.Mem_LdEn(Mem_LdEn),
		.MemWb_RdAddr(MemWb_RdAddr),
		.MemWb_RdWrtEn(MemWb_RdWrtEn),
		.Wb_DataWrt(Wb_DataWrt),
		.Decode_LdType(Decode_LdType),
		.DecodeHazard_StallReq(DecodeHazard_StallReq),
		.DecodeHazard_Rs1Data(DecodeHazard_Rs1Data),
		.DecodeHazard_Rs2Data(DecodeHazard_Rs2Data),
		.DecodeHazard_Rs3Data(DecodeHazard_Rs3Data)
	);
	

   PipeStage #(
		.STAGE_WIDTH(`PIPE_IDEX_LEN)
	)
	i_IDEX(
		.clk(clk),
		.rst_n(rst_n),
		.Stall(Ctrl_Stall[2]),
		.Flush(Flush[1]),
		.in(
			{
				Decode_AllCtr,
				Decode_RdAddr,
				Decode_Rs1Addr,
				Decode_Rs2Addr,
				Decode_Imm,
				Decode_ImmSel,
				Decode_CsrAddr,
				DecodeHazard_Rs1Data,
				DecodeHazard_Rs2Data,
				DecodeHazard_Rs3Data,
				Decode_16BitFlag,
				IFID_NowPC
			} 
		),
		.out(
			{
				IDEX_Sel1,
				IDEX_Sel2,
				IDEX_AluOp,
				IDEX_StType,
				IDEX_LdType,
				IDEX_WbSel,
				IDEX_WbRdEn,
				IDEX_CsrCmd,
				IDEX_CsrIllegal,
				IDEX_RdAddr,
				IDEX_Rs1Addr,
				IDEX_Rs2Addr,
				IDEX_Imm,
				IDEX_ImmSel,
				IDEX_CsrAddr,
				IDEX_Rs1Data,
				IDEX_Rs2Data,
				IDEX_Rs3Data,
				IDEX_16BitFlag,
				IDEX_NowPC
			} 
		)
	);
	
	EX i_EX (
		.IDEX_Rs1Data(IDEX_Rs1Data),
		.IDEX_Rs2Data(IDEX_Rs2Data),
		.IDEX_Sel1(IDEX_Sel1),
		.IDEX_NowPC(IDEX_NowPC),
		.IDEX_Sel2(IDEX_Sel2),
		.IDEX_Imm(IDEX_Imm),
		//.Dcache_DataRd(Dcache_DataRd), 
		//.Mem_LdEn(Mem_LdEn), 
		//.IDEX_Rs1Addr(IDEX_Rs1Addr), 
        //.IDEX_Rs2Addr(IDEX_Rs2Addr), 
		//.EXMem_RdAddr(EXMem_RdAddr),
		.Csr_RdData(Csr_RdData),
		.IDEX_AluOp(IDEX_AluOp),
		.IDEX_LdType(IDEX_LdType),
		.IDEX_StType(IDEX_StType),
		.Mem_DcacheEN(Mem_DcacheEn),
		.IDEX_16BitFlag(IDEX_16BitFlag),
		.clk(clk),
		.rst_n(rst_n),
		.simd_ena(1'b0),
		.simd_ctl(2'b0),
		.EX_AluData(EX_AluData),
		.EX_BranchFlag(EX_BranchFlag),
		.EX_BranchPC(EX_BranchPC),
		.EX_LdStFlag(EX_LdStFlag),
		.EX_StallReq(EX_StallReq)
	);

wire [31:0] EXMEM_NowPC;	
	Csr i_Csr (
        .clk(clk),
        .rst_n(rst_n),
        .Ctrl_Stall(Ctrl_Stall),
        .IFID_NowPC(IFID_NowPC),
		.IFID_Instr(IFID_Instr),
        .Decode_Flush(Decode_Flush),
		.Decode_16BitFlag(Decode_16BitFlag),
        .IDEX_CsrAddr(IDEX_CsrAddr),
        .IDEX_CsrCmd(IDEX_CsrCmd),
        .IDEX_Imm(IDEX_Imm),
        .IDEX_Rs1Data(IDEX_Rs1Data),
        .IDEX_ImmSel(IDEX_ImmSel),
        .IDEX_NowPC(IDEX_NowPC),
        .IDEX_StType(IDEX_StType),
        .IDEX_LdType(IDEX_LdType),
		.EX_BranchPC(EX_BranchPC), //new 
        .EX_BranchFlag(EX_BranchFlag), 
        .EX_AluData(EX_AluData),
		.EXMem_LdType(EXMem_LdType),    
		.EXMem_StType(EXMem_StType),    
		.EXMem_AluData(EXMem_AluData) ,
        .EXMEM_NowPC(EXMEM_NowPC),
        .Csr_RdData(Csr_RdData),
        .Csr_ExcpFlag(Csr_ExcpFlag),
        .Csr_Evec(Csr_Evec),
        .Csr_Memflush(Csr_Memflush),
        .Csr_WFIClrFlag  (Csr_WFIClrFlag ) ,
        .NMI(1'b0),
        .RESET(1'b0),
        .Core_interrupt(3'b0),
        .DBG_interrupt (5'b0),
        .Fetchaddr_Invalid(Fetchaddr_Invalid)//unuse?
	);	
		

	PipeStage #(
		.STAGE_WIDTH(`PIPE_EXMem_LEN)
	)
	i_EXMem(
		.clk(clk),
		.rst_n(rst_n),
		.Stall(Ctrl_Stall[3]),
		.Flush(Csr_Memflush|Flush[2]),	
		.in(
			{
				EX_AluData,
				IDEX_RdAddr,
				IDEX_Rs2Data,
				IDEX_StType,
				IDEX_LdType,
				IDEX_WbRdEn,
				IDEX_WbSel,
                IDEX_NowPC
			} 
		),
		.out(
			{
				EXMem_AluData,
				EXMem_RdAddr,
				EXMem_Rs2Data,
				EXMem_StType,
				EXMem_LdType,				
				EXMem_RdWrtEn,
				EXMem_WbSel,
                EXMEM_NowPC
			} 
		)
	);

	Mem i_Mem(
		.EXMem_LdType(EXMem_LdType),    
		.EXMem_StType(EXMem_StType),    
		.EXMem_AluData(EXMem_AluData),   
		.Mem_LdEN(Mem_LdEn),        
		.Mem_DcacheEN(Mem_DcacheEn),    
		.Mem_DcacheRd(Mem_DcacheRd),  
		.Mem_DcacheSign(Mem_DcacheSign),  
		.Mem_DcacheWidth(Mem_DcacheWidth), 
		.Mem_DcacheAddr(Mem_DcacheAddr),
        .Csr_Memflush(Csr_Memflush)//new   
    ); 	
	
	Dcache i_Dcache(
		.clk(clk),
		.rst_n(rst_n),
		.Mem_DcacheEN(Mem_DcacheEn),    
		.Mem_DcacheRd(Mem_DcacheRd),    
		.Mem_DcacheWidth(Mem_DcacheWidth), 
		.Mem_DcacheAddr(Mem_DcacheAddr),   
		.EXMem_Rs2Data(EXMem_Rs2Data),
		.Mem_DcacheSign(Mem_DcacheSign), 
		.Dcache_DataRd(Dcache_DataRd),
		.Icache_NextPC(Fetch_NextPC),
		.Icache_Instr(Icache_Instr)
	);
	
	PipeStage #(
		.STAGE_WIDTH(`PIPE_MemWb_LEN)
	)
	i_MemWb(
		.clk(clk),
		.rst_n(rst_n),
		.Stall(Ctrl_Stall[4]),
		.Flush(Csr_Memflush|Flush[3]),
		.in(
			{
				EXMem_RdAddr,
				EXMem_RdWrtEn,
				EXMem_AluData,
				Dcache_DataRd,
				EXMem_WbSel
			} 
		),
		.out(
			{
				MemWb_RdAddr,
				MemWb_RdWrtEn,
				MemWb_AluData,
				MemWb_DataRd,
				MemWb_WbSel
			} 
		)
	);

	Wb i_Wb(
		.MemWb_WbSel(MemWb_WbSel),
		.MemWb_AluData(MemWb_AluData),
		.MemWb_DataRd(MemWb_DataRd),
		.Wb_DataWrt(Wb_DataWrt)
    );
		
endmodule