/*
 * @Author: Sue
 * @Date:   2019-10-28 15:51
 * @Last Modified by: mikey.zhaopeng
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: simple TB for all module
 */
`include "../common/Define.v"
module Core
#(
    // Parameters of Axi Master Bus Interface M00_AXI
    parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
    parameter integer C_M00_AXI_BURST_LEN	    = 16,
    parameter integer C_M00_AXI_ID_WIDTH	    = 2,
    parameter integer C_M00_AXI_ADDR_WIDTH	    = 32,
    parameter integer C_M00_AXI_DATA_WIDTH	    = 32,
    parameter integer C_M00_AXI_AWUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_ARUSER_WIDTH	= 0,
    parameter integer C_M00_AXI_WUSER_WIDTH	    = 0,
    parameter integer C_M00_AXI_RUSER_WIDTH	    = 0,
    parameter integer C_M00_AXI_BUSER_WIDTH	    = 0
)
(
	input									     clk             ,
    input                                        rst_n           ,
    //========Icache signal===========
    output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_awid    ,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]     m00_axi_awaddr  ,
    output wire [7 : 0]                          m00_axi_awlen   ,
    output wire [2 : 0]                          m00_axi_awsize  ,
    output wire [1 : 0]                          m00_axi_awburst ,
    output wire                                  m00_axi_awlock  ,
    output wire [3 : 0]                          m00_axi_awcache ,
    output wire [2 : 0]                          m00_axi_awprot  ,
    output wire [3 : 0]                          m00_axi_awqos   ,
    output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0]   m00_axi_awuser  ,
    output wire                                  m00_axi_awvalid ,
    input  wire                                  m00_axi_awready ,
                                            
    output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_wid     ,
	output wire [C_M00_AXI_DATA_WIDTH-1   : 0]   m00_axi_wdata   ,
    output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0]   m00_axi_wstrb   ,
    output wire                                  m00_axi_wlast   ,
    output wire [C_M00_AXI_WUSER_WIDTH-1 : 0]    m00_axi_wuser   ,
    output wire                                  m00_axi_wvalid  ,
    input  wire                                  m00_axi_wready  ,
                                        
    input  wire [C_M00_AXI_ID_WIDTH-1 : 0]       m00_axi_bid     ,
    input  wire [1 : 0]                          m00_axi_bresp   ,
    input  wire [C_M00_AXI_BUSER_WIDTH-1 : 0]    m00_axi_buser   ,
    input  wire                                  m00_axi_bvalid  ,
    output wire                                  m00_axi_bready  ,
                                        
    output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_arid    ,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]     m00_axi_araddr  ,
    output wire [7 : 0]                          m00_axi_arlen   ,
    output wire [2 : 0]                          m00_axi_arsize  ,
    output wire [1 : 0]                          m00_axi_arburst ,
    output wire                                  m00_axi_arlock  ,
    output wire [3 : 0]                          m00_axi_arcache ,
    output wire [2 : 0]                          m00_axi_arprot  ,
    output wire [3 : 0]                          m00_axi_arqos   ,
    output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0]   m00_axi_aruser  ,
    output wire                                  m00_axi_arvalid ,
    input  wire                                  m00_axi_arready ,
                                            
    input  wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_rid     ,
    input  wire [C_M00_AXI_DATA_WIDTH-1 : 0]     m00_axi_rdata   ,
    input  wire [1 : 0]                          m00_axi_rresp   ,
    input  wire                                  m00_axi_rlast   ,
    input  wire [C_M00_AXI_RUSER_WIDTH-1 : 0]    m00_axi_ruser   ,
    input  wire                                  m00_axi_rvalid  ,
    output wire                                  m00_axi_rready  ,
    //========Dcache sugnal===========
    output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m01_axi_awid    ,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]     m01_axi_awaddr  ,
    output wire [7 : 0]                          m01_axi_awlen   ,
    output wire [2 : 0]                          m01_axi_awsize  ,
    output wire [1 : 0]                          m01_axi_awburst ,
    output wire                                  m01_axi_awlock  ,
    output wire [3 : 0]                          m01_axi_awcache ,
    output wire [2 : 0]                          m01_axi_awprot  ,
    output wire [3 : 0]                          m01_axi_awqos   ,
    output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0]   m01_axi_awuser  ,
    output wire                                  m01_axi_awvalid ,
    input  wire                                  m01_axi_awready ,

	output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m01_axi_wid     ,                                        
    output wire [C_M00_AXI_DATA_WIDTH-1   : 0]   m01_axi_wdata   ,
    output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0]   m01_axi_wstrb   ,
    output wire                                  m01_axi_wlast   ,
    output wire [C_M00_AXI_WUSER_WIDTH-1 : 0]    m01_axi_wuser   ,
    output wire                                  m01_axi_wvalid  ,
    input  wire                                  m01_axi_wready  ,
                                    
    input  wire [C_M00_AXI_ID_WIDTH-1 : 0]       m01_axi_bid     ,
    input  wire [1 : 0]                          m01_axi_bresp   ,
    input  wire [C_M00_AXI_BUSER_WIDTH-1 : 0]    m01_axi_buser   ,
    input  wire                                  m01_axi_bvalid  ,
    output wire                                  m01_axi_bready  ,
                                        
    output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m01_axi_arid    ,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]     m01_axi_araddr  ,
    output wire [7 : 0]                          m01_axi_arlen   ,
    output wire [2 : 0]                          m01_axi_arsize  ,
    output wire [1 : 0]                          m01_axi_arburst ,
    output wire                                  m01_axi_arlock  ,
    output wire [3 : 0]                          m01_axi_arcache ,
    output wire [2 : 0]                          m01_axi_arprot  ,
    output wire [3 : 0]                          m01_axi_arqos   ,
    output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0]   m01_axi_aruser  ,
    output wire                                  m01_axi_arvalid ,
    input  wire                                  m01_axi_arready ,
                                            
    input  wire [C_M00_AXI_ID_WIDTH-1   : 0]     m01_axi_rid     ,
    input  wire [C_M00_AXI_DATA_WIDTH-1 : 0]     m01_axi_rdata   ,
    input  wire [1 : 0]                          m01_axi_rresp   ,
    input  wire                                  m01_axi_rlast   ,
    input  wire [C_M00_AXI_RUSER_WIDTH-1 : 0]    m01_axi_ruser   ,
    input  wire                                  m01_axi_rvalid  ,
    output wire                                  m01_axi_rready  
);
	wire	[`ADDR_WIDTH - 1 : 0]			Fetch_NextPC;

	wire	[`ADDR_WIDTH - 1 : 0]			IFID_NowPC;
	wire	[`INSTR_WIDTH - 1 : 0]			IFID_Instr;
	wire    [`ADDR_WIDTH - 1 : 0]           BranchPredictor_PC;
    wire                                    BP_BranchFlag;

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
	
	wire  	[`DATA_WIDTH-1 :0]   			EXHazard_Rs1Data;
	wire  	[`DATA_WIDTH-1 :0]   			EXHazard_Rs2Data;
	//wire  	[`DATA_WIDTH-1 :0]   			EXHazard_Rs3Data;
	wire	     							DecodeHazard_StallReq = 1'b0;
	
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
	wire                                    IDEX_BpFlag;
	wire                                    IDEX_IsBr;
				
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
		.BranchPredictor_PC(BranchPredictor_PC),
        .BP_BranchFlag(BP_BranchFlag),
		.IFID_NowPC(IFID_NowPC),
		.Fetch_NextPC(Fetch_NextPC),
		.Ctrl_ExcpFlag(Csr_ExcpFlag),
		.Ctrl_ExcpPC(Csr_Evec),
		.EX_BranchFlag(EX_BranchFlag),
             //.EX_BranchFlag(nomisalign_Br),
		.EX_BranchPC(EX_BranchPC),
		.Decode_16BitFlag(Decode_16BitFlag)

	);
	
	BranchPredictor i_BranchPredictor(
        .Icache_Instr(Icache_Instr),
        .Fetch_NextPC(Fetch_NextPC),
        .BranchPredictor_PC(BranchPredictor_PC),
        .BP_BranchFlag(BP_BranchFlag)
    );
	

  PipeStage3 #(
		.STAGE_WIDTH(`PIPE_IFID_LEN)
	)
	i_IFID(
		.clk(clk),
		.rst_n(rst_n),
		.rst_value({64'h80000000_00000013, 1'b0}),//rst and flush with nop
		.Stall(Ctrl_Stall[1]),
		.Flush(Flush[0]),
		.in( {Fetch_NextPC , Icache_Instr, BP_BranchFlag} ),
		.out( {IFID_NowPC , IFID_Instr, IFID_BpFlag} )
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
				Decode_16BitFlag,
				IFID_NowPC,
				IFID_BpFlag
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
				IDEX_IsBr,
				IDEX_RdAddr,
				IDEX_Rs1Addr,
				IDEX_Rs2Addr,
				IDEX_Imm,
				IDEX_ImmSel,
				IDEX_CsrAddr,
				IDEX_16BitFlag,
				IDEX_NowPC,
				IDEX_BpFlag
			} 
		)
	);

	EXHazard i_EXHazard(
		.IDEX_Rs1Addr(IDEX_Rs1Addr),
		.IDEX_Rs2Addr(IDEX_Rs2Addr),
		.IDEX_Rs3Addr(32'b0),	
		.RF_Rs1Data(RF_Rs1Data),
		.RF_Rs2Data(RF_Rs2Data),
		.RF_Rs3Data(RF_Rs3Data),
		.EXMem_RdAddr(EXMem_RdAddr),
		.EXMem_AluData(EXMem_AluData),
		.Dcache_DataRd(Dcache_DataRd),
		.Mem_LdEN(Mem_LdEn),
		.EXHazard_Rs1Data(EXHazard_Rs1Data),
		.EXHazard_Rs2Data(EXHazard_Rs2Data),
		.EXHazard_Rs3Data()
	);

	RegFile i_RegFile(
		.clk(clk),
		.rst_n(rst_n),
		.Csr_Mcause(Csr_Mcause),
		.Csr_ExcpFlag(Csr_ExcpFlag),
		.Dcache_StallReq(Dcache_StallReq),
		.rAddr1(IDEX_Rs1Addr),
		.rData1(RF_Rs1Data),
		.rAddr2(IDEX_Rs2Addr),
		.rData2(RF_Rs2Data),
		//.rAddr3(IDEX_Rs3Addr),
		//.rData3(RF_Rs3Data),
		.wEN1(IDEX_WbRdEn),
		.wAddr1(IDEX_RdAddr),
		.wData1(EX_AluData),
		.wEN2(EXMem_RdWrtEn),
		.wAddr2(EXMem_RdAddr),
		.wData2(Dcache_DataRd)
	);
	
	EX i_EX (
		.IDEX_Rs1Data(EXHazard_Rs1Data),
		.IDEX_Rs2Data(EXHazard_Rs2Data),
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
		.IDEX_BpFlag(IDEX_BpFlag),
		.IDEX_IsBr(IDEX_IsBr),
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
        .IDEX_Rs1Data(EXHazard_Rs1Data),
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
.IFID_Instr(IFID_Instr),
.Csr_Mcause(Csr_Mcause)
	);	
		

	PipeStageMem #(
		.STAGE_WIDTH(`PIPE_EXMem_LEN)
	)
	i_EXMem(
		.clk(clk),
		.rst_n(rst_n),
		.Stall(Ctrl_Stall[3]),
		.Flush(Csr_Memflush|Flush[2]),	
        .IDEX_StType(IDEX_StType),
        .IDEX_LdType(IDEX_LdType),
		.in(
			{
				EX_AluData,
				IDEX_RdAddr,
				EXHazard_Rs2Data,
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


//====================Cache-axi======================
L1I_Cache L1I_Cache_i
(
     .clk             (clk               ),  
     .rst_n           (rst_n             ),  
     .Core_CacheRd    (1                 ),  
     .Core_CacheEn    ( ~EX_BranchFlag   ),  
     .Core_CacheSign  (0                 ),  
     .Core_CacheAddr  (Fetch_NextPC      ),  
     .Core_CacheData  (0                 ),  
     .Core_CacheWidth (2'b10             ),  
     .Cache_DataRd    (Icache_Instr      ),  
     .Cache_StallReq  (Icache_StallReq   ),  

     .Dcache_DataRd   (Dcache_DataRd_snoop),  
     .Dcache_Dirty    (Dcache_Dirty      ),  
     .Icache_PC       (Icache_PC         ),  

     .m00_axi_aclk    (clk               ),  
     .m00_axi_aresetn (rst_n             ),  

     .m00_axi_awid    (m00_axi_awid      ),  
     .m00_axi_awaddr  (m00_axi_awaddr    ),  
     .m00_axi_awlen   (m00_axi_awlen     ),  
     .m00_axi_awsize  (m00_axi_awsize    ),  
     .m00_axi_awburst (m00_axi_awburst   ),  
     .m00_axi_awlock  (m00_axi_awlock    ),  
     .m00_axi_awcache (m00_axi_awcache   ),  
     .m00_axi_awprot  (m00_axi_awprot    ),  
     .m00_axi_awqos   (m00_axi_awqos     ),  
     .m00_axi_awuser  (m00_axi_awuser    ),  
     .m00_axi_awvalid (m00_axi_awvalid   ),  
     .m00_axi_awready (m00_axi_awready   ),  

     .m00_axi_wid     (m00_axi_wid       ),  
	 .m00_axi_wdata   (m00_axi_wdata     ),  
     .m00_axi_wstrb   (m00_axi_wstrb     ),  
     .m00_axi_wlast   (m00_axi_wlast     ),  
     .m00_axi_wuser   (m00_axi_wuser     ),  
     .m00_axi_wvalid  (m00_axi_wvalid    ),  
     .m00_axi_wready  (m00_axi_wready    ),  

     .m00_axi_bid     (m00_axi_bid       ),  
     .m00_axi_bresp   (m00_axi_bresp     ),  
     .m00_axi_buser   (m00_axi_buser     ),  
     .m00_axi_bvalid  (m00_axi_bvalid    ),  
     .m00_axi_bready  (m00_axi_bready    ),  

     .m00_axi_arid    (m00_axi_arid      ),  
     .m00_axi_araddr  (m00_axi_araddr    ),  
     .m00_axi_arlen   (m00_axi_arlen     ),  
     .m00_axi_arsize  (m00_axi_arsize    ),  
     .m00_axi_arburst (m00_axi_arburst   ),  
     .m00_axi_arlock  (m00_axi_arlock    ),  
     .m00_axi_arcache (m00_axi_arcache   ),  
     .m00_axi_arprot  (m00_axi_arprot    ),  
     .m00_axi_arqos   (m00_axi_arqos     ),  
     .m00_axi_aruser  (m00_axi_aruser    ),  
     .m00_axi_arvalid (m00_axi_arvalid   ),  
     .m00_axi_arready (m00_axi_arready   ),  

     .m00_axi_rid     (m00_axi_rid       ),  
     .m00_axi_rdata   (m00_axi_rdata     ),  
     .m00_axi_rresp   (m00_axi_rresp     ),  
     .m00_axi_rlast   (m00_axi_rlast     ),  
     .m00_axi_ruser   (m00_axi_ruser     ),  
     .m00_axi_rvalid  (m00_axi_rvalid    ),  
     .m00_axi_rready  (m00_axi_rready    )
);

L1D_Cache L1D_Cache_i
(
    .clk            (clk            ),  
    .rst_n          (rst_n          ),  
    .Core_CacheRd   (Mem_DcacheRd   ),  
    .Core_CacheEn   (Mem_DcacheEn   ),  
    .Core_CacheSign (Mem_DcacheSign ),  
    .Core_CacheAddr (Mem_DcacheAddr ),  
    .Core_CacheData (EXMem_Rs2Data  ),  
    .Core_CacheWidth(Mem_DcacheWidth),  
    .Cache_DataRd   (Dcache_DataRd  ),  
    .Cache_StallReq (Dcache_StallReq),  
    .Dcache_DataRd  (Dcache_DataRd_snoop),  
    .Dcache_Dirty   (Dcache_Dirty   ),  
    .Icache_PC      (Icache_PC      ),  
    .m00_axi_aclk   (clk            ),  
    .m00_axi_aresetn(rst_n          ),  
                                     
    .m00_axi_awid   (m01_axi_awid   ),  
    .m00_axi_awaddr (m01_axi_awaddr ),  
    .m00_axi_awlen  (m01_axi_awlen  ),  
    .m00_axi_awsize (m01_axi_awsize ),  
    .m00_axi_awburst(m01_axi_awburst),  
    .m00_axi_awlock (m01_axi_awlock ),  
    .m00_axi_awcache(m01_axi_awcache),  
    .m00_axi_awprot (m01_axi_awprot ),  
    .m00_axi_awqos  (m01_axi_awqos  ),  
    .m00_axi_awuser (m01_axi_awuser ),  
    .m00_axi_awvalid(m01_axi_awvalid),  
    .m00_axi_awready(m01_axi_awready),  

	.m00_axi_wid    (m01_axi_wid    ),  
    .m00_axi_wdata  (m01_axi_wdata  ),  
    .m00_axi_wstrb  (m01_axi_wstrb  ),  
    .m00_axi_wlast  (m01_axi_wlast  ),  
    .m00_axi_wuser  (m01_axi_wuser  ),  
    .m00_axi_wvalid (m01_axi_wvalid ),  
    .m00_axi_wready (m01_axi_wready ),  

    .m00_axi_bid    (m01_axi_bid    ),  
    .m00_axi_bresp  (m01_axi_bresp  ),  
    .m00_axi_buser  (m01_axi_buser  ),  
    .m00_axi_bvalid (m01_axi_bvalid ),  
    .m00_axi_bready (m01_axi_bready ),  

    .m00_axi_arid   (m01_axi_arid   ),  
    .m00_axi_araddr (m01_axi_araddr ),  
    .m00_axi_arlen  (m01_axi_arlen  ),  
    .m00_axi_arsize (m01_axi_arsize ),  
    .m00_axi_arburst(m01_axi_arburst),  
    .m00_axi_arlock (m01_axi_arlock ),  
    .m00_axi_arcache(m01_axi_arcache),  
    .m00_axi_arprot (m01_axi_arprot ),  
    .m00_axi_arqos  (m01_axi_arqos  ),  
    .m00_axi_aruser (m01_axi_aruser ),  
    .m00_axi_arvalid(m01_axi_arvalid),  
    .m00_axi_arready(m01_axi_arready),  

    .m00_axi_rid    (m01_axi_rid    ),  
    .m00_axi_rdata  (m01_axi_rdata  ),  
    .m00_axi_rresp  (m01_axi_rresp  ),  
    .m00_axi_rlast  (m01_axi_rlast  ),  
    .m00_axi_ruser  (m01_axi_ruser  ),  
    .m00_axi_rvalid (m01_axi_rvalid ),  
    .m00_axi_rready (m01_axi_rready )  
);
//====================================================    
      
		
endmodule
