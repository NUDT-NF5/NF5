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
	wire	[`FUNCT3_WIDTH - 1 : 0]	        Decode_Rm;
	wire	[2 - 1 : 0]						Decode_Stall;
	wire	[4 - 1 : 0]						Decode_Flush;
	wire									Decode_16BitFlag;
	wire 	[`LD_TYPE_WIDTH - 1 : 0 ]		Decode_LdType;
	
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs1Data;
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs2Data;
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
	wire  	[`DATA_WIDTH-1  :0]      		Icache_Instr;

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
  
//=============Xbar===============
//Xbar
wire          Bus_0_dBitsReady  ; 
wire          Bus_0_dBitsValid  ; 
wire [2:0]    Bus_0_dBitsOpcode ; 
wire [31:0]   Bus_0_dBitsData   ; 
wire [1:0]    Bus_0_dBitsParam  ; 
wire [4:0]    Bus_0_dBitsSource ; 
wire [1:0]    Bus_0_dBitsSink   ; 
wire          Bus_0_dBitsDennied; 
wire          Bus_0_dBitsCorrupt; 
wire [3:0]    Bus_0_dBitsSize   ; 

wire          Bus_0_aBitsReady  ; 
wire          Bus_0_aBitsValid  ; 
wire [31:0]   Bus_0_aBitsAddress; 
wire [2:0]    Bus_0_aBitsOpcode ; 
wire [3:0]    Bus_0_aBitsSize   ; 
wire [3:0]    Bus_0_aBitsMask   ; 
wire [31:0]   Bus_0_aBitsData   ; 
wire [2:0]    Bus_0_aBitsParam  ; 
wire [4:0]    Bus_0_aBitsSource ; 
wire          Bus_0_aBitsCorrupt; 

wire          Bus_1_dBitsReady  ; 
wire          Bus_1_dBitsValid  ; 
wire [2:0]    Bus_1_dBitsOpcode ; 
wire [31:0]   Bus_1_dBitsData   ; 
wire [1:0]    Bus_1_dBitsParam  ; 
wire [4:0]    Bus_1_dBitsSource ; 
wire [1:0]    Bus_1_dBitsSink   ; 
wire          Bus_1_dBitsDennied; 
wire          Bus_1_dBitsCorrupt; 
wire [3:0]    Bus_1_dBitsSize   ; 

wire          Bus_1_aBitsReady  ; 
wire          Bus_1_aBitsValid  ; 
wire [31:0]   Bus_1_aBitsAddress; 
wire [2:0]    Bus_1_aBitsOpcode ; 
wire [3:0]    Bus_1_aBitsSize   ; 
wire [3:0]    Bus_1_aBitsMask   ; 
wire [31:0]   Bus_1_aBitsData   ; 
wire [2:0]    Bus_1_aBitsParam  ; 
wire [4:0]    Bus_1_aBitsSource ; 
wire          Bus_1_aBitsCorrupt; 

wire          Bus_D_dBitsReady  ; 
wire          Bus_D_dBitsValid  ; 
wire [2:0]    Bus_D_dBitsOpcode ; 
wire [31:0]   Bus_D_dBitsData   ; 
wire [1:0]    Bus_D_dBitsParam  ; 
wire [4:0]    Bus_D_dBitsSource ; 
wire [1:0]    Bus_D_dBitsSink   ; 
wire          Bus_D_dBitsDennied; 
wire          Bus_D_dBitsCorrupt; 
wire [3:0]    Bus_D_dBitsSize   ; 

wire          Bus_D_aBitsReady  ; 
wire          Bus_D_aBitsValid  ; 
wire [31:0]   Bus_D_aBitsAddress; 
wire [2:0]    Bus_D_aBitsOpcode ; 
wire [3:0]    Bus_D_aBitsSize   ; 
wire [3:0]    Bus_D_aBitsMask   ; 
wire [31:0]   Bus_D_aBitsData   ; 
wire [2:0]    Bus_D_aBitsParam  ; 
wire [4:0]    Bus_D_aBitsSource ; 
wire          Bus_D_aBitsCorrupt; 

wire          Bus_I_dBitsReady  ; 
wire          Bus_I_dBitsValid  ; 
wire [2:0]    Bus_I_dBitsOpcode ; 
wire [31:0]   Bus_I_dBitsData   ; 
wire [1:0]    Bus_I_dBitsParam  ; 
wire [4:0]    Bus_I_dBitsSource ; 
wire [1:0]    Bus_I_dBitsSink   ; 
wire          Bus_I_dBitsDennied; 
wire          Bus_I_dBitsCorrupt; 
wire [3:0]    Bus_I_dBitsSize   ; 

wire          Bus_I_aBitsReady  ; 
wire          Bus_I_aBitsValid  ; 
wire [31:0]   Bus_I_aBitsAddress; 
wire [2:0]    Bus_I_aBitsOpcode ; 
wire [3:0]    Bus_I_aBitsSize   ; 
wire [3:0]    Bus_I_aBitsMask   ; 
wire [31:0]   Bus_I_aBitsData   ; 
wire [2:0]    Bus_I_aBitsParam  ; 
wire [4:0]    Bus_I_aBitsSource ; 
wire          Bus_I_aBitsCorrupt; 
//================================
 
//Cache snooping
wire  [31:0]  Dcache_DataRd_snoop;
wire          Dcache_Dirty      ;  
wire  [31:0]  Icache_PC	        ;
//Cache stall
wire          Icache_StallReq   ;
wire          Dcache_StallReq   ;

//Xbar addr judgement
wire  [31:0]  Core_CacheAddr_xbar_D;
wire  [31:0]  Core_CacheAddr_xbar_I;
wire          St_EN;
		
	Ctrl i_Ctrl(
		.Icache_StallReq(Icache_StallReq),
		.Dcache_StallReq(Dcache_StallReq),
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
        .Decode_Rm(Decode_Rm),
		.Decode_Stall(Decode_Stall),
		.Decode_Flush(Decode_Flush),
		.Decode_16BitFlag(Decode_16BitFlag),
		.Decode_LdType(Decode_LdType)
	);
	
	RegFile i_RegFile(
		.clk(clk),
		.rst_n(rst_n),
		.rAddr1(Decode_Rs1Addr),
		.rData1(RF_Rs1Data),
		.rAddr2(Decode_Rs2Addr),
		.rData2(RF_Rs2Data),
		.wEN(MemWb_RdWrtEn),
		.wAddr(MemWb_RdAddr),
		.wData(Wb_DataWrt)
	);

	DecodeHazard i_DecodeHazard(
		.clk(clk),
		.rst_n(rst_n),
		.Decode_Rs1Addr(Decode_Rs1Addr),
		.Decode_Rs2Addr(Decode_Rs2Addr),	
		.RF_Rs1Data(RF_Rs1Data),
		.RF_Rs2Data(RF_Rs2Data),
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
        .IDEX_LdType(IDEX_LdType),
		.DecodeHazard_StallReq(DecodeHazard_StallReq),
		.DecodeHazard_Rs1Data(DecodeHazard_Rs1Data),
		.DecodeHazard_Rs2Data(DecodeHazard_Rs2Data)
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
        .Dcache_StallReq(Dcache_StallReq),
		.IDEX_16BitFlag(IDEX_16BitFlag),
		.clk(clk),
		.rst_n(rst_n),
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
        .IDEX_CsrAddr(IDEX_CsrAddr),
        .IDEX_CsrCmd(IDEX_CsrCmd),
        .Csr_RdData(Csr_RdData),
        .Csr_ExcpFlag(Csr_ExcpFlag),
        .Csr_Evec(Csr_Evec),
        .Csr_Memflush(Csr_Memflush),
        .NMI(1'b0),
        .RESET(1'b0),
        .IDEX_NowPC(IDEX_NowPC),
        .IFID_NowPC(IFID_NowPC),
        .IDEX_Imm(IDEX_Imm),
        .IDEX_Rs1Data(IDEX_Rs1Data),
        .IDEX_ImmSel(IDEX_ImmSel),
        .Core_interrupt(3'b0),
        .DBG_interrupt (5'b0),
        .EX_AluData(EX_AluData),
        .IDEX_StType(IDEX_StType),
        .IDEX_LdType(IDEX_LdType),
        .EX_BranchFlag(EX_BranchFlag),
        .Decode_Flush(Decode_Flush),
        .Csr_WFIClrFlag  (Csr_WFIClrFlag ) ,
		.EXMem_LdType(EXMem_LdType),    
		.EXMem_StType(EXMem_StType),    
		.EXMem_AluData(EXMem_AluData) ,
		.EX_BranchPC(EX_BranchPC), //new   
               .EXMEM_NowPC(EXMEM_NowPC),
		.Decode_16BitFlag(Decode_16BitFlag),
               .Fetchaddr_Invalid(Fetchaddr_Invalid),
.IFID_Instr(IFID_Instr)
	);	
		

	PipeStage #(
		.STAGE_WIDTH(`PIPE_EXMem_LEN)
	)
	i_EXMem(
		.clk(clk),
		.rst_n(rst_n),
		.Stall(Ctrl_Stall[3]),
		.Flush(Csr_Memflush|Flush[3]),	
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
        .St_EN(St_EN), 
		.Mem_DcacheEN(Mem_DcacheEn),    
		.Mem_DcacheRd(Mem_DcacheRd),  
		.Mem_DcacheSign(Mem_DcacheSign),  
		.Mem_DcacheWidth(Mem_DcacheWidth), 
		.Mem_DcacheAddr(Mem_DcacheAddr),
            .Csr_Memflush(Csr_Memflush)//new   
    ); 	
	
	/*Dcache i_Dcache(
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
	);*/
	
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


//====================Cache-tilelink======================
  L1D_Cache i_L1D_Cache(
        .clk             	(clk             	),
        .rst_n           	(rst_n           	),
        //core 	 
        .Core_CacheRd    	(Mem_DcacheRd    	),	            
        .Core_CacheEn    	(Mem_DcacheEn    	),	        
        .Core_CacheSign  	(Mem_DcacheSign  	),	          
        .Core_CacheAddr  	(Mem_DcacheAddr  	),	             
        .Core_CacheData  	(EXMem_Rs2Data  	),	            
        .Core_CacheWidth 	(Mem_DcacheWidth 	),	             
        .Cache_DataRd    	(Dcache_DataRd    	),	            
        .Cache_StallReq  	(Dcache_StallReq  	),
                .Core_CacheAddr_xbar  	(Core_CacheAddr_xbar_D  	),
        //Xbar Dcache A channel
        .Bus_aBitsReady  	(Bus_0_aBitsReady  	),	          
        .Bus_aBitsValid  	(Bus_0_aBitsValid  	),	             
        .Bus_aBitsAddress	(Bus_0_aBitsAddress	),	            
        .Bus_aBitsOpcode 	(Bus_0_aBitsOpcode 	),	             
        .Bus_aBitsSize   	(Bus_0_aBitsSize   	),	             
        .Bus_aBitsMask   	(Bus_0_aBitsMask   	),	             
        .Bus_aBitsData   	(Bus_0_aBitsData   	),	             
        .Bus_aBitsParam  	(Bus_0_aBitsParam  	),	             
        .Bus_aBitsSource 	(Bus_0_aBitsSource 	),	             
        .Bus_aBitsCorrupt	(Bus_0_aBitsCorrupt	),

        //Xbar Dcache A channel
        .Bus_dBitsReady  	(Bus_0_dBitsReady   ),	             
        .Bus_dBitsValid  	(Bus_0_dBitsValid   ),	          
        .Bus_dBitsOpcode 	(Bus_0_dBitsOpcode  ),	             
        .Bus_dBitsData   	(Bus_0_dBitsData    ),	             
        .Bus_dBitsParam  	(Bus_0_dBitsParam   ),	             
        .Bus_dBitsSource 	(Bus_0_dBitsSource  ),	             
        .Bus_dBitsSink   	(Bus_0_dBitsSink    ),	            
        .Bus_dBitsDennied	(Bus_0_dBitsDennied ),	             
        .Bus_dBitsCorrupt	(Bus_0_dBitsCorrupt ),	             
        .Bus_dBitsSize   	(Bus_0_dBitsSize    ),
        //Snooping Icache
        .Icache_PC       	(Icache_PC       	),
        .Dcache_DataRd   	(Dcache_DataRd_snoop),
        .Dcache_Dirty		(Dcache_Dirty		)
    );	


/*Dcache i_Dcache(
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
    );*/

    L1I_Cache i_L1I_Cache(
        .clk				 (clk               ),
        .rst_n				 (rst_n             ),
        //core	
        .Core_CacheRd  	 	 (1                 ),  //always read Icache			
        .Core_CacheEn		 (    ~EX_BranchFlag             ),  //always enable Icache			
        .Core_CacheSign	 	 (0                 ),	//every instruction is unsigned		
        .Core_CacheAddr	 	 (Fetch_NextPC	    ),			
        .Core_CacheData 	 (0 	            ),  //always don't write data				
        .Core_CacheWidth	 (2'b10	            ),	//always read 32bits instruction, *this cache cannot support 16bits instructions provisionaly			
        .Cache_DataRd   	 (Icache_Instr   	),				
        .Cache_StallReq 	 (Icache_StallReq 	),
                .Core_CacheAddr_xbar 	 (Core_CacheAddr_xbar_I 	),
        //Xbar Icache A channel				
        .Bus_aBitsReady	 	 (Bus_1_aBitsReady  ),			
        .Bus_aBitsValid 	 (Bus_1_aBitsValid  ),				
        .Bus_aBitsAddress	 (Bus_1_aBitsAddress),				
        .Bus_aBitsOpcode	 (Bus_1_aBitsOpcode ),				
        .Bus_aBitsSize  	 (Bus_1_aBitsSize   ),				
        .Bus_aBitsMask  	 (Bus_1_aBitsMask   ),				
        .Bus_aBitsData  	 (Bus_1_aBitsData   ),				
        .Bus_aBitsParam 	 (Bus_1_aBitsParam  ),				
        .Bus_aBitsSource	 (Bus_1_aBitsSource ),				
        .Bus_aBitsCorrupt	 (Bus_1_aBitsCorrupt),
        //Xbar Icache D channel				
        .Bus_dBitsReady 	 (Bus_1_dBitsReady  ),				
        .Bus_dBitsValid	 	 (Bus_1_dBitsValid  ),			
        .Bus_dBitsOpcode	 (Bus_1_dBitsOpcode ),				
        .Bus_dBitsData  	 (Bus_1_dBitsData   ),				
        .Bus_dBitsParam 	 (Bus_1_dBitsParam  ),				
        .Bus_dBitsSource	 (Bus_1_dBitsSource ),				
        .Bus_dBitsSink  	 (Bus_1_dBitsSink   ),				
        .Bus_dBitsDennied	 (Bus_1_dBitsDennied),				
        .Bus_dBitsCorrupt	 (Bus_1_dBitsCorrupt),				
        .Bus_dBitsSize  	 (Bus_1_dBitsSize   ),

        //Snooping Dcache				
        .Dcache_DataRd		 (Dcache_DataRd_snoop),			
        .Dcache_Dirty   	 (Dcache_Dirty   	),				
        .Icache_PC			 (Icache_PC			)		
    );

SRAM_Top i_SRAM_Top(
       .clk               (clk                ),
       .rst_n             (rst_n              ),
        //Dcache D cahnnel
       .Bus_D_dBitsReady  (Bus_D_dBitsReady  ),
       .Bus_D_dBitsValid  (Bus_D_dBitsValid  ),
       .Bus_D_dBitsOpcode (Bus_D_dBitsOpcode ),
       .Bus_D_dBitsData   (Bus_D_dBitsData   ),
       .Bus_D_dBitsParam  (Bus_D_dBitsParam  ),
       .Bus_D_dBitsSource (Bus_D_dBitsSource ),
       .Bus_D_dBitsSink   (Bus_D_dBitsSink   ),
       .Bus_D_dBitsDennied(Bus_D_dBitsDennied),
       .Bus_D_dBitsCorrupt(Bus_D_dBitsCorrupt),
       .Bus_D_dBitsSize   (Bus_D_dBitsSize   ),
        //Dcache A channel
       .Bus_D_aBitsReady  (Bus_D_aBitsReady  ),
       .Bus_D_aBitsValid  (Bus_D_aBitsValid  ),
       .Bus_D_aBitsAddress(Bus_D_aBitsAddress),
       .Bus_D_aBitsOpcode (Bus_D_aBitsOpcode ),
       .Bus_D_aBitsSize   (Bus_D_aBitsSize   ),
       .Bus_D_aBitsMask   (Bus_D_aBitsMask   ),
       .Bus_D_aBitsData   (Bus_D_aBitsData   ),
       .Bus_D_aBitsParam  (Bus_D_aBitsParam  ),
       .Bus_D_aBitsSource (Bus_D_aBitsSource ),
       .Bus_D_aBitsCorrupt(Bus_D_aBitsCorrupt),
        //Icache D channel
       .Bus_I_dBitsReady  (Bus_I_dBitsReady   ),
       .Bus_I_dBitsValid  (Bus_I_dBitsValid   ),
       .Bus_I_dBitsOpcode (Bus_I_dBitsOpcode  ),
       .Bus_I_dBitsData   (Bus_I_dBitsData    ),
       .Bus_I_dBitsParam  (Bus_I_dBitsParam   ),
       .Bus_I_dBitsSource (Bus_I_dBitsSource  ),
       .Bus_I_dBitsSink   (Bus_I_dBitsSink    ),
       .Bus_I_dBitsDennied(Bus_I_dBitsDennied ),
       .Bus_I_dBitsCorrupt(Bus_I_dBitsCorrupt ),
       .Bus_I_dBitsSize   (Bus_I_dBitsSize    ),
        //Icache A channel
       .Bus_I_aBitsReady  (Bus_I_aBitsReady   ),
       .Bus_I_aBitsValid  (Bus_I_aBitsValid   ),
       .Bus_I_aBitsAddress(Bus_I_aBitsAddress ),
       .Bus_I_aBitsOpcode (Bus_I_aBitsOpcode  ),
       .Bus_I_aBitsSize   (Bus_I_aBitsSize    ),
       .Bus_I_aBitsMask   (Bus_I_aBitsMask    ),
       .Bus_I_aBitsData   (Bus_I_aBitsData    ),
       .Bus_I_aBitsParam  (Bus_I_aBitsParam   ),
       .Bus_I_aBitsSource (Bus_I_aBitsSource  ),
       .Bus_I_aBitsCorrupt(Bus_I_aBitsCorrupt )
);

    Xbar i_Xbar(
        .clk               (clk               ),
        .rst_n             (rst_n             ),
    //-------Dcache--------
        //Dcache D cahnnel
        .Bus_0_dBitsReady  (Bus_0_dBitsReady  ),
        .Bus_0_dBitsValid  (Bus_0_dBitsValid  ),
        .Bus_0_dBitsOpcode (Bus_0_dBitsOpcode ),
        .Bus_0_dBitsData   (Bus_0_dBitsData   ),
        .Bus_0_dBitsParam  (Bus_0_dBitsParam  ),
        .Bus_0_dBitsSource (Bus_0_dBitsSource ),
        .Bus_0_dBitsSink   (Bus_0_dBitsSink   ),
        .Bus_0_dBitsDennied(Bus_0_dBitsDennied),
        .Bus_0_dBitsCorrupt(Bus_0_dBitsCorrupt),
        .Bus_0_dBitsSize   (Bus_0_dBitsSize   ),
        //Dcache A channel
        .Bus_0_aBitsReady  (Bus_0_aBitsReady  ),
        .Bus_0_aBitsValid  (Bus_0_aBitsValid  ),
        .Bus_0_aBitsAddress(Bus_0_aBitsAddress),
                .Core_CacheAddr_xbar_D(Core_CacheAddr_xbar_D),
        .Bus_0_aBitsOpcode (Bus_0_aBitsOpcode ),
        .Bus_0_aBitsSize   (Bus_0_aBitsSize   ),
        .Bus_0_aBitsMask   (Bus_0_aBitsMask   ),
        .Bus_0_aBitsData   (Bus_0_aBitsData   ),
        .Bus_0_aBitsParam  (Bus_0_aBitsParam  ),
        .Bus_0_aBitsSource (Bus_0_aBitsSource ),
        .Bus_0_aBitsCorrupt(Bus_0_aBitsCorrupt),
    //--------Icache--------
        //Icache D channel
        .Bus_1_dBitsReady  (Bus_1_dBitsReady  ),
        .Bus_1_dBitsValid  (Bus_1_dBitsValid  ),
        .Bus_1_dBitsOpcode (Bus_1_dBitsOpcode ),
        .Bus_1_dBitsData   (Bus_1_dBitsData   ),
        .Bus_1_dBitsParam  (Bus_1_dBitsParam  ),
        .Bus_1_dBitsSource (Bus_1_dBitsSource ),
        .Bus_1_dBitsSink   (Bus_1_dBitsSink   ),
        .Bus_1_dBitsDennied(Bus_1_dBitsDennied),
        .Bus_1_dBitsCorrupt(Bus_1_dBitsCorrupt),
        .Bus_1_dBitsSize   (Bus_1_dBitsSize   ),
        //Icache A channel
        .Bus_1_aBitsReady  (Bus_1_aBitsReady  ),
        .Bus_1_aBitsValid  (Bus_1_aBitsValid  ),
        .Bus_1_aBitsAddress(Bus_1_aBitsAddress),
                .Core_CacheAddr_xbar_I(Core_CacheAddr_xbar_I),
        .Bus_1_aBitsOpcode (Bus_1_aBitsOpcode ),
        .Bus_1_aBitsSize   (Bus_1_aBitsSize   ),
        .Bus_1_aBitsMask   (Bus_1_aBitsMask   ),
        .Bus_1_aBitsData   (Bus_1_aBitsData   ),
        .Bus_1_aBitsParam  (Bus_1_aBitsParam  ),
        .Bus_1_aBitsSource (Bus_1_aBitsSource ),
        .Bus_1_aBitsCorrupt(Bus_1_aBitsCorrupt),
    //-------SRAM-----
        //SRAM Dcache D channel
        .Bus_D_dBitsReady  (Bus_D_dBitsReady  ),
        .Bus_D_dBitsValid  (Bus_D_dBitsValid  ),
        .Bus_D_dBitsOpcode (Bus_D_dBitsOpcode ),
        .Bus_D_dBitsData   (Bus_D_dBitsData   ),
        .Bus_D_dBitsParam  (Bus_D_dBitsParam  ),
        .Bus_D_dBitsSource (Bus_D_dBitsSource ),
        .Bus_D_dBitsSink   (Bus_D_dBitsSink   ),
        .Bus_D_dBitsDennied(Bus_D_dBitsDennied),
        .Bus_D_dBitsCorrupt(Bus_D_dBitsCorrupt),
        .Bus_D_dBitsSize   (Bus_D_dBitsSize   ),
        //SRAM Dcache A channel     
        .Bus_D_aBitsReady  (Bus_D_aBitsReady  ),
        .Bus_D_aBitsValid  (Bus_D_aBitsValid  ),
        .Bus_D_aBitsAddress(Bus_D_aBitsAddress),
        .Bus_D_aBitsOpcode (Bus_D_aBitsOpcode ),
        .Bus_D_aBitsSize   (Bus_D_aBitsSize   ),
        .Bus_D_aBitsMask   (Bus_D_aBitsMask   ),
        .Bus_D_aBitsData   (Bus_D_aBitsData   ),
        .Bus_D_aBitsParam  (Bus_D_aBitsParam  ),
        .Bus_D_aBitsSource (Bus_D_aBitsSource ),
        .Bus_D_aBitsCorrupt(Bus_D_aBitsCorrupt),
        //SRAM Icache D channel
        .Bus_I_dBitsReady  (Bus_I_dBitsReady  ),
        .Bus_I_dBitsValid  (Bus_I_dBitsValid  ),
        .Bus_I_dBitsOpcode (Bus_I_dBitsOpcode ),
        .Bus_I_dBitsData   (Bus_I_dBitsData   ),
        .Bus_I_dBitsParam  (Bus_I_dBitsParam  ),
        .Bus_I_dBitsSource (Bus_I_dBitsSource ),
        .Bus_I_dBitsSink   (Bus_I_dBitsSink   ),
        .Bus_I_dBitsDennied(Bus_I_dBitsDennied),
        .Bus_I_dBitsCorrupt(Bus_I_dBitsCorrupt),
        .Bus_I_dBitsSize   (Bus_I_dBitsSize   ),
        //SRAM Icache A channel
        .Bus_I_aBitsReady  (Bus_I_aBitsReady  ),
        .Bus_I_aBitsValid  (Bus_I_aBitsValid  ),
        .Bus_I_aBitsAddress(Bus_I_aBitsAddress),
        .Bus_I_aBitsOpcode (Bus_I_aBitsOpcode ),
        .Bus_I_aBitsSize   (Bus_I_aBitsSize   ),
        .Bus_I_aBitsMask   (Bus_I_aBitsMask   ),
        .Bus_I_aBitsData   (Bus_I_aBitsData   ),
        .Bus_I_aBitsParam  (Bus_I_aBitsParam  ),
        .Bus_I_aBitsSource (Bus_I_aBitsSource ),
        .Bus_I_aBitsCorrupt(Bus_I_aBitsCorrupt)
    );    
//====================================================    
      
		
endmodule
