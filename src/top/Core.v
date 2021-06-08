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
	wire                                    IFID_BpFlag;
	wire    [`ADDR_WIDTH - 1 : 0]           BranchPredictor_PC;
	wire                                    BP_BranchFlag;

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
	
    wire    [`SIMD_DATA_WIDTH-1 :0]         EXHazard_Rs1Data;
    wire    [`SIMD_DATA_WIDTH-1 :0]         EXHazard_Rs2Data;
    wire    [`SIMD_DATA_WIDTH-1 :0]         EXHazard_Rs3Data;
    wire                                    DecodeHazard_StallReq = 1'b0;
	
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
    wire                                    IDEX_SimdEN;

	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_RdAddr;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Imm;
	wire  	[`IMM_SEL_WIDTH - 1:0]         	IDEX_ImmSel;  
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		IDEX_CsrAddr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs1Addr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs2Addr;
    wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs3Addr;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		IDEX_Rs1Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		IDEX_Rs2Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		IDEX_Rs3Data;
	wire	[`FUNCT3_WIDTH - 1 : 0]	        IDEX_Rm;
	wire    [2 - 1 : 0]                     IDEX_Fmt;
	wire									IDEX_16BitFlag;
	wire	[`ADDR_WIDTH - 1 : 0]			IDEX_NowPC;
	wire                                    IDEX_BpFlag;
				
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		RF_Rs1Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		RF_Rs2Data;
	wire	[`SIMD_DATA_WIDTH - 1 : 0]		RF_Rs3Data;
	
    wire    [`SIMD_DATA_WIDTH - 1 : 0] 		EX_AluData;
    wire           							EX_LdStFlag;
	wire									EX_BranchFlag;
	wire	[`ADDR_WIDTH - 1 : 0]			EX_BranchPC;
	wire									EX_StallReq;
	wire    [`FPU_EXCEPTION_WIDTH - 1:0]    EX_FpuException;
    wire                                    EX_FpuReady;
	
    wire    [`SIMD_DATA_WIDTH - 1 : 0]      EXMem_AluData;
    wire    [`SIMD_DATA_WIDTH - 1 : 0]      EXMem_Rs2Data;
    wire           							EXMem_RdWrtEn;
    wire    [`RF_ADDR_WIDTH - 1 : 0]		EXMem_RdAddr;
    wire           							EXMem_WbSel;
    wire    [`LD_TYPE_WIDTH - 1:0]          EXMem_StType;
    wire    [`ST_TYPE_WIDTH - 1:0]          EXMem_LdType;
    wire	[`FUNCT3_WIDTH - 1 : 0]	        EXMem_Rm;
    wire                                    EXMem_SimdEN;

    wire                          		 	Mem_LdEn;        
    wire                          		 	Mem_DcacheEn;    
    wire                          		 	Mem_DcacheRd;    
    wire  	[1:0]      			  			Mem_DcacheWidth; 
    wire  	[`ADDR_WIDTH-1  :0]     		Mem_DcacheAddr;
	wire									Mem_DcacheSign;   
	wire 									rd_high;	
	wire 									wr_high;	

	wire  	[`SIMD_DATA_WIDTH-1  :0]        Dcache_DataRd;
	wire  	[`DATA_WIDTH-1  :0]      		Icache_Instr;

    wire                       				MemWb_WbSel;
    wire  	[`SIMD_DATA_WIDTH-1 :0]   		MemWb_AluData;
    wire  	[`SIMD_DATA_WIDTH-1 :0]   	    MemWb_DataRd;
    wire  	[`RF_ADDR_WIDTH-1:0] 			MemWb_RdAddr;
    wire	[`FUNCT3_WIDTH - 1 : 0]	        MemWb_Rm;
    wire                                    MemWb_SimdEN;
	
	
	wire  	[`SIMD_DATA_WIDTH-1 :0]   		Wb_DataWrt;
    wire                       				MemWb_RdWrtEn;

	wire   	[4:0]   						Ctrl_Stall;	
	wire	[3:0]							Flush;
	  
    wire   [`DATA_WIDTH-1:0]           		Csr_RdData;                             
    wire   [`ADDR_WIDTH-1:0]           		Csr_Evec;
    wire                               		Csr_ExcpFlag;
    wire                               		Csr_Memflush;
    wire                                    Csr_WFIClrFlag;	
    wire   [`FRM_WIDTH - 1:0]               Csr_Frm;
    wire   [2:0]                            Csr_Mcause;
		
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
		.rst_value({64'h00000000_00000013, 1'b0}),//rst and flush with nop
		.Stall(Ctrl_Stall[1]),
		.Flush(Flush[0]),
		.in( {Fetch_NextPC , Icache_Instr , BP_BranchFlag} ),
		.out( {IFID_NowPC , IFID_Instr , IFID_BpFlag} )
	);
	
	Decode i_Decode(
		.IFID_Instr(IFID_Instr),
		.clk(clk),
		.rst_n(rst_n),
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
                Decode_Rs3Addr,
				Decode_Imm,
				Decode_ImmSel,
				Decode_CsrAddr,
                Decode_Rm,
                Decode_Fmt,
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
				IDEX_SimdEN,
				IDEX_IsBr,
				IDEX_RdAddr,
				IDEX_Rs1Addr,
				IDEX_Rs2Addr,
                IDEX_Rs3Addr,
				IDEX_Imm,
				IDEX_ImmSel,
				IDEX_CsrAddr,
                IDEX_Rm,
				IDEX_Fmt,
				IDEX_16BitFlag,
				IDEX_NowPC,
				IDEX_BpFlag
			} 
		)
	);

wire [3:0]                    mask = 4'b1111;
wire 						  mask_ena;
wire [`FUNCT3_WIDTH - 1:0]    funct3;
wire [`SIMD_DATA_WIDTH - 1:0] reorgnaized_rs1;
wire [`SIMD_DATA_WIDTH - 1:0] reorgnaized_rs2;
wire wEN1 = IDEX_WbRdEn && ~EX_StallReq && (IDEX_LdType == `LD_XXX);
	RegFile i_RegFile(
		.clk(clk),
		.rst_n(rst_n),
        .Csr_Mcause(Csr_Mcause),
        .Csr_ExcpFlag(Csr_ExcpFlag),
		.rAddr1(IDEX_Rs1Addr),
		.rData1(RF_Rs1Data),
		.rAddr2(IDEX_Rs2Addr),
		.rData2(RF_Rs2Data),
		.rAddr3(IDEX_Rs3Addr),
		.rData3(RF_Rs3Data),
        .horizontal(1'b0),
        .simd_ctl(2'b0),
		.rd_high(rd_high),
		.wEN1(wEN1),
		.wAddr1(IDEX_RdAddr),
		.wData1(EX_AluData),
        .simd_ena1(IDEX_SimdEN),
		.wEN2(EXMem_RdWrtEn),
		.wAddr2(EXMem_RdAddr),
		.wData2(Dcache_DataRd),
        .simd_ena2(EXMem_SimdEN),
		.wr_high(wr_high)
	);

	EXHazard i_EXHazard(
		.IDEX_Rs1Addr(IDEX_Rs1Addr),
		.IDEX_Rs2Addr(IDEX_Rs2Addr),
		.IDEX_Rs3Addr(IDEX_Rs3Addr),	
		.RF_Rs1Data(RF_Rs1Data),
		.RF_Rs2Data(RF_Rs2Data),
		.RF_Rs3Data(RF_Rs3Data),
        .mask(mask),
		.mask_ena(IDEX_Fmt[0]),
		.simd_ena(IDEX_SimdEN),
		.funct3(IDEX_Rm),
		.IDEX_StType(IDEX_StType),
		.EXMem_RdAddr(EXMem_RdAddr),
		.EXMem_AluData(EXMem_AluData),
		.Dcache_DataRd(Dcache_DataRd),
		.Mem_LdEN(Mem_LdEn),
		.EXHazard_Rs1Data(EXHazard_Rs1Data),
		.EXHazard_Rs2Data(EXHazard_Rs2Data),
		.EXHazard_Rs3Data(EXHazard_Rs3Data),
		.rd_high(rd_high)
	);

	EX i_EX (
		.IDEX_Rs1Data(EXHazard_Rs1Data),
		.IDEX_Rs2Data(EXHazard_Rs2Data),
		.IDEX_Rs3Data(EXHazard_Rs3Data),
		.IDEX_Sel1(IDEX_Sel1),
		.IDEX_NowPC(IDEX_NowPC),
		.IDEX_Sel2(IDEX_Sel2),
		.IDEX_Imm(IDEX_Imm),
		//.Dcache_DataRd(Dcache_DataRd), 
		//.Mem_LdEn(Mem_LdEn), 
		//.IDEX_Rs1Addr(IDEX_Rs1Addr), 
        //.IDEX_Rs2Addr(IDEX_Rs2Addr), 
		//.EXMem_RdAddr(EXMem_RdAddr),
        .IDEX_Rm(IDEX_Rm),
        .IDEX_Fmt(IDEX_Fmt),
        .Csr_Frm(Csr_Frm),
		.Csr_RdData(Csr_RdData),
		.IDEX_AluOp(IDEX_AluOp),
		.IDEX_LdType(IDEX_LdType),
		.IDEX_StType(IDEX_StType),
		.Mem_DcacheEN(Mem_DcacheEn),
		.IDEX_16BitFlag(IDEX_16BitFlag),
		.clk(clk),
		.rst_n(rst_n),
		.simd_ena(IDEX_SimdEN),
		.simd_ctl(IDEX_Rm[1:0]),
		.IDEX_BpFlag(IDEX_BpFlag),
		.IDEX_IsBr(IDEX_IsBr),
		.EX_AluData(EX_AluData),
		.EX_BranchFlag(EX_BranchFlag),
		.EX_BranchPC(EX_BranchPC),
		.EX_LdStFlag(EX_LdStFlag),
		.EX_StallReq(EX_StallReq),
		.EX_FpuException(EX_FpuException),
		.EX_FpuReady(EX_FpuReady)
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
        .IDEX_Rs1Data(EXHazard_Rs1Data),
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
        .EX_FpuException(EX_FpuException),
        .EX_FpuReady(EX_FpuReady),
        .Csr_Frm(Csr_Frm),
        .NMI(1'b0),
        .RESET(1'b0),
        .Core_interrupt(3'b0),
        .DBG_interrupt (5'b0),
        .Fetchaddr_Invalid(Fetchaddr_Invalid),//unuse?
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
                IDEX_NowPC,
                IDEX_SimdEN,
                IDEX_Rm
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
                EXMEM_NowPC,
                EXMem_SimdEN,
                EXMem_Rm
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
        .Csr_Memflush(Csr_Memflush),//new 
		.rd_high(),
		.wr_high(wr_high)
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
		
endmodule