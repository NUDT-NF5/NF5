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

	wire	[`ADDR_WIDTH - 1 : 0]			IFID_NowPC_0;
	wire	[`ADDR_WIDTH - 1 : 0]			IFID_NowPC_1;
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

	wire                                    Decode_Unicorn;
	wire 	[`PC_PLUS_WIDTH - 1 : 0]        Decode_NextPC;

	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs1Data_0;
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs2Data_0;
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs1Data_1;
	wire  	[`DATA_WIDTH-1 :0]   			DecodeHazard_Rs2Data_1;
	wire	     							DecodeHazard_StallReq;
	
	wire	[`PC_SEL_WIDTH - 1 : 0 ]		IDEX_PcSel_0;
	wire	[`A_SEL_WIDTH - 1 : 0 ]			IDEX_Sel1_0;
	wire	[`B_SEL_WIDTH - 1 : 0 ]			IDEX_Sel2_0;
	wire	[`ALU_OP_WIDTH - 1 : 0 ]		IDEX_AluOp_0;
	wire	[`ST_TYPE_WIDTH - 1 : 0 ]		IDEX_StType_0;
	wire	[`LD_TYPE_WIDTH - 1 : 0 ]		IDEX_LdType_0;
	wire	[`WB_SEL_WIDTH - 1 : 0 ]		IDEX_WbSel_0;
	wire	[`BOOL_WIDTH - 1 : 0 ]			IDEX_WbRdEn_0;
	wire	[`CSR_CMD_WIDTH - 1 : 0 ]		IDEX_CsrCmd_0;
	wire	[`BOOL_WIDTH - 1 : 0 ]			IDEX_CsrIllegal_0;

	wire	[`PC_SEL_WIDTH - 1 : 0 ]		IDEX_PcSel_1;
	wire	[`A_SEL_WIDTH - 1 : 0 ]			IDEX_Sel1_1;
	wire	[`B_SEL_WIDTH - 1 : 0 ]			IDEX_Sel2_1;
	wire	[`ALU_OP_WIDTH - 1 : 0 ]		IDEX_AluOp_1;
	wire	[`ST_TYPE_WIDTH - 1 : 0 ]		IDEX_StType_1;
	wire	[`LD_TYPE_WIDTH - 1 : 0 ]		IDEX_LdType_1;
	wire	[`WB_SEL_WIDTH - 1 : 0 ]		IDEX_WbSel_1;
	wire	[`BOOL_WIDTH - 1 : 0 ]			IDEX_WbRdEn_1;
	wire	[`CSR_CMD_WIDTH - 1 : 0 ]		IDEX_CsrCmd_1;
	wire	[`BOOL_WIDTH - 1 : 0 ]			IDEX_CsrIllegal_1;

	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_RdAddr_0;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Imm_0;
	wire  	[`IMM_SEL_WIDTH - 1:0]         	IDEX_ImmSel_0; 
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		IDEX_CsrAddr_0;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs1Addr_0;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs2Addr_0;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Rs1Data_0;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Rs2Data_0;
	wire									IDEX_16BitFlag_0;
	wire	[`ADDR_WIDTH - 1 : 0]			IDEX_NowPC_0;

	wire                                    IDEX_stall;

	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_RdAddr_1;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Imm_1;
	wire  	[`IMM_SEL_WIDTH - 1:0]         	IDEX_ImmSel_1;
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		IDEX_CsrAddr_1;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs1Addr_1;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		IDEX_Rs2Addr_1;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Rs1Data_1;
	wire	[`DATA_WIDTH - 1 : 0]			IDEX_Rs2Data_1;
	wire									IDEX_16BitFlag_1;
	wire	[`ADDR_WIDTH - 1 : 0]			IDEX_NowPC_1;
				
	wire	[`DATA_WIDTH - 1 : 0]			RF_Rs1Data_0;
	wire	[`DATA_WIDTH - 1 : 0]			RF_Rs2Data_0;

	wire	[`DATA_WIDTH - 1 : 0]			RF_Rs1Data_1;
	wire	[`DATA_WIDTH - 1 : 0]			RF_Rs2Data_1;
	
    wire    [31:0] 							EX_AluData_0;
    wire           							EX_LdStFlag_0;
	wire									EX_BranchFlag_0;
	wire	[`ADDR_WIDTH - 1 : 0]			EX_BranchPC_0;
	wire									EX_StallReq;

    wire    [31:0] 							EX_AluData_1;
    wire           							EX_LdStFlag_1;
	wire									EX_BranchFlag_1;
	wire	[`ADDR_WIDTH - 1 : 0]			EX_BranchPC_1;
	wire	[`ADDR_WIDTH - 1 : 0]			EX_BranchPC;

    wire    [`DATA_WIDTH - 1 : 0]           EXMem_Rs2Data;

    wire    [31:0] 							EXMem_AluData_0;
    wire    [31:0] 							EXMem_Rs2Data_0;
    wire           							EXMem_RdWrtEn_0;
    wire    [4:0]  							EXMem_RdAddr_0;
    wire           							EXMem_WbSel_0;
    wire    [1:0]  							EXMem_StType_0;
    wire    [2:0]  							EXMem_LdType_0;

    wire    [31:0] 							EXMem_AluData_1;
    wire    [31:0] 							EXMem_Rs2Data_1;
    wire           							EXMem_RdWrtEn_1;
    wire    [4:0]  							EXMem_RdAddr_1;
    wire           							EXMem_WbSel_1;
    wire    [1:0]  							EXMem_StType_1;
    wire    [2:0]  							EXMem_LdType_1;
	wire    [`ADDR_WIDTH - 1:0]             EXMEM_NowPC_0;
	wire    [`ADDR_WIDTH - 1:0]             EXMEM_NowPC_1;
//========YB Change for ss 2020.06.22 21:21========
    //wire                          		 	Mem_LdEn;        
    wire                          		 	Mem_DcacheEn;    
    wire                          		 	Mem_DcacheRd;    
    wire  	[1:0]      			  			Mem_DcacheWidth; 
    wire  	[`ADDR_WIDTH-1  :0]     		Mem_DcacheAddr;
	wire									Mem_DcacheSign;   

	//wire  	[`DATA_WIDTH-1  :0]      		Dcache_DataRd;
	//wire  	[`INSTR_WIDTH-1  :0]      		Icache_Instr;
    //wire                       				MemWb_WbSel;
    //wire  	[`DATA_WIDTH-1 :0]   			MemWb_AluData;
    //wire  	[`DATA_WIDTH-1 :0]   			MemWb_DataRd;
	//wire  	[`RF_ADDR_WIDTH-1:0] 			MemWb_RdAddr;
	
	//wire  	[`DATA_WIDTH-1 :0]   			Wb_DataWrt;
    //wire                       				MemWb_RdWrtEn;
//========YB Change for ss 2020.06.22 21:21========
    wire                       				MemWb_RdWrtEn_0;
    wire                       				MemWb_RdWrtEn_1;
	wire  	[`RF_ADDR_WIDTH-1:0] 			MemWb_RdAddr_0;
	wire  	[`RF_ADDR_WIDTH-1:0] 			MemWb_RdAddr_1;
	
	  //wire  [`LD_TYPE_WIDTH-1:0]     EXMem_LdType_0   ;    //From EXMem stage, indicate load type 
      //wire  [`ST_TYPE_WIDTH-1:0]     EXMem_StType_0   ;    //From EXMem stage, indicate store type
      //wire  [`DATA_WIDTH-1   :0]     EXMem_AluData_0  ;    //From EXMem stage, indicate Dcaceh Addr

      //wire  [`LD_TYPE_WIDTH-1:0]     EXMem_LdType_1   ;    //From EXMem stage, indicate load type 
      //wire  [`ST_TYPE_WIDTH-1:0]     EXMem_StType_1   ;    //From EXMem stage, indicate store type
      //wire  [`DATA_WIDTH-1   :0]     EXMem_AluData_1  ;    //From EXMem stage, indicate Dcaceh Addr

      //wire  [`DATA_WIDTH-1   :0]     EXMem_Rs2Data_0  ;  
      //wire  [`DATA_WIDTH-1   :0]     EXMem_Rs2Data_1  ;  

      wire                           Mem_LdEN_0       ;    //To EX stage, generate forward control signal
      wire                           Mem_LdEN_1       ;    //To EX stage, generate forward control signal
//	  wire 							 Mem_Stall        ;
	  wire 							 Mem_DcacheEN_0   ;
	  wire 							 Mem_DcacheEN_1   ;

      wire  [`DATA_WIDTH-1   :0]     Dcache_DataRd    ;

      wire  [`DATA_WIDTH-1   :0]     Dcache_DataRd_0   ; 
      wire  [`DATA_WIDTH-1   :0]     Dcache_DataRd_1   ; 
      wire  [`ADDR_WIDTH-1   :0]     Icache_NextPC     ;
      wire  [`INSTR_WIDTH-1  :0]     Icache_Instr      ;

	  wire                       MemWb_WbSel_0   ;      
      wire  [`DATA_WIDTH-1 :0]   MemWb_AluData_0 ;   
      wire  [`DATA_WIDTH-1 :0]   MemWb_DataRd_0  ;   
      wire  [`DATA_WIDTH-1 :0]   Wb_DataWrt_0    ; 

      wire                       MemWb_WbSel_1   ;
      wire  [`DATA_WIDTH-1 :0]   MemWb_AluData_1 ;  
      wire  [`DATA_WIDTH-1 :0]   MemWb_DataRd_1  ; 
      wire  [`DATA_WIDTH-1 :0]   Wb_DataWrt_1    ;



	wire   	[4:0]   						Ctrl_Stall;	
	wire	[3:0]							Flush;
	wire 	[3:0]							issue_select;
	  
    wire   [`DATA_WIDTH-1:0]           		Csr_RdData;                             
    wire   [`ADDR_WIDTH-1:0]           		Csr_Evec;
    wire                               		Csr_ExcpFlag;
    wire                               		Csr_Memflush;
    wire                                    Csr_WFIClrFlag;	
wire [`DATA_WIDTH-1:0] Csr_RdData_0  = 0;
wire [`DATA_WIDTH-1:0] Csr_RdData_1 = 0;
assign               Csr_Evec = 0;
assign 				   Csr_ExcpFlag = 0;	
assign                   Csr_Memflush = 0;
assign                   Csr_WFIClrFlag = 0;
wire 				   Fetchaddr_Invalid = 0;
		
	Ctrl i_Ctrl(
		.Icache_StallReq(1'b0),
		.Dcache_StallReq(1'b0),//========YB Change for ss 2020.06.22 21:21========
		.Decode_Stall_0   (Decode_Stall_0),
		.Mem_LdStFlag_0   (Mem_DcacheEN_0),
        .DecodeHazard_StallReq(DecodeHazard_StallReq),//data_hazard
	 	.EX_LdStFlag_0    (EX_LdStFlag_0),
	 	.EX_BranchFlag_0  (EX_BranchFlag_0),
	 	.Decode_16BitFlag_0(Decode_16BitFlag_0),
		.EX_BranchPC_0(EX_BranchPC_0),
	 	.Ctrl_Stall     (Ctrl_Stall),
	 	.EX_StallReq	(EX_StallReq),
	 	.Csr_ExcpFlag   (Csr_ExcpFlag),
	 	.Flush			(Flush) ,
		.issue_select(issue_select),
		.Decode_Stall_1   (Decode_Stall_1),
		.Mem_LdStFlag_1   (Mem_DcacheEN_1),
	 	.EX_LdStFlag_1    (EX_LdStFlag_1),
	 	.EX_BranchFlag_1  (EX_BranchFlag_1),
		.EX_BranchPC_1(EX_BranchPC_1),
		.EX_BranchPC(EX_BranchPC),
	 	.Decode_16BitFlag_1(Decode_16BitFlag_1),
		.EX_BranchFlag(EX_BranchFlag),
 //        .Csr_WFIClrFlag (Csr_WFIClrFlag ) ,
        .Csr_Memflush(Csr_Memflush)  
    );
	
//wire Fetchaddr_Invalid;
//wire nomisalign_Br= EX_BranchFlag ;//&!Fetchaddr_Invalid;
	
	Fetch i_Fetch(
		// .clk(clk),
		// .rst_n(rst_n),
		// .Stall(1'b0),//need to edit control
		.IFID_NowPC(IFID_NowPC_0),
		.Fetch_NextPC(Fetch_NextPC),
		.Ctrl_ExcpFlag(1'b0),//need to edit control
		.Ctrl_ExcpPC(32'h0000_0008),//need to edit control
		.EX_BranchFlag(EX_BranchFlag),//need to edit ex
             //.EX_BranchFlag(nomisalign_Br),
		.EX_BranchPC(EX_BranchPC),//need to edit ex
		.Decode_NextPC(Decode_NextPC)//the low 16bit of IFID_Instr is 16-bit instr

	);

  PipeStage3 #(
		.STAGE_WIDTH(`PIPE_IFID_LEN)
	)
	i_IFID(
		.clk(clk),
		.rst_n(rst_n),
		.rst_value(96'h00000000_00000000_00000000),//rst and flush with 2 nops
		.Stall(1'b0),//need to edit control
		.Flush(1'b0),//need to edit control
		.in( {Fetch_NextPC , Icache_Instr} ),
		.out( {IFID_NowPC_0 , IFID_Instr} )
	);

	Decode i_Decode(
		// .IFID_Instr(64'h00000013_00000013), // 32/32
		// .IFID_Instr(64'h57c157c1_00000013), // 16/16/32
		// .IFID_Instr(64'h57c157c1_57c157c1), // 16/16/16/16
		// .IFID_Instr(64'h00000013_57c157c1), // 32/16/16
		// .IFID_Instr(64'h57c10000_001357c1), // 16/32/16
		.IFID_Instr(IFID_Instr),
		.IFID_NowPC_0(IFID_NowPC_0),
		.IFID_NowPC_1(IFID_NowPC_1),
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
		.Decode_Unicorn(Decode_Unicorn),
		.Decode_NextPC(Decode_NextPC)
	);
	
	 RegFile i_RegFile(
	 	.clk(clk),
	 	.rst_n(rst_n),
	 	.rAddr1_0(Decode_Rs1Addr_0),
	 	.rData1_0(RF_Rs1Data_0),
	 	.rAddr2_0(Decode_Rs2Addr_0),
	 	.rData2_0(RF_Rs2Data_0),
		.rAddr1_1(Decode_Rs1Addr_1),
	 	.rData1_1(RF_Rs1Data_1),
	 	.rAddr2_1(Decode_Rs2Addr_1),
	 	.rData2_1(RF_Rs2Data_1),
	 	.wEN_0(MemWb_RdWrtEn_0),
	 	.wAddr_0(MemWb_RdAddr_0),
	 	.wData_0(Wb_DataWrt_0),
	 	.wEN_1(MemWb_RdWrtEn_1),
	 	.wAddr_1(MemWb_RdAddr_1),
	 	.wData_1(Wb_DataWrt_1)
	 );

 	DecodeHazard i_DecodeHazard(
 		.clk(clk),
 		.rst_n(rst_n),
 		.Decode_Rs1Addr_0(Decode_Rs1Addr_0),
 		.Decode_Rs2Addr_0(Decode_Rs2Addr_0),	
 		.RF_Rs1Data_0(RF_Rs1Data_0),
 		.RF_Rs2Data_0(RF_Rs2Data_0),
 		.Decode_Rs1Addr_1(Decode_Rs1Addr_1),
 		.Decode_Rs2Addr_1(Decode_Rs2Addr_1),	
 		.RF_Rs1Data_1(RF_Rs1Data_1),
 		.RF_Rs2Data_1(RF_Rs2Data_1),
 		.IDEX_RdAddr_0(IDEX_RdAddr_0),
 		.IDEX_WbRdEn_0(IDEX_WbRdEn_0),
 		.EX_AluData_0(EX_AluData_0),
 		.IDEX_RdAddr_1(IDEX_RdAddr_1),
 		.IDEX_WbRdEn_1(IDEX_WbRdEn_1),
 		.EX_AluData_1(EX_AluData_1),
 		.EXMem_RdAddr_0(EXMem_RdAddr_0),
 		.EXMem_RdWrtEn_0(EXMem_RdWrtEn_0),
 		.EXMem_AluData_0(EXMem_AluData_0),
 		.EXMem_RdAddr_1(EXMem_RdAddr_1),
 		.EXMem_RdWrtEn_1(EXMem_RdWrtEn_1),
 		.EXMem_AluData_1(EXMem_AluData_1),
 		.Dcache_DataRd_0(Dcache_DataRd_0),
 		.Mem_LdEn_0(Mem_LdEN_0),
 		.Dcache_DataRd_1(Dcache_DataRd_1),
 		.Mem_LdEn_1(Mem_LdEN_1),
 		.MemWb_RdAddr_0(MemWb_RdAddr_0),
 		.MemWb_RdWrtEn_0(MemWb_RdWrtEn_0),
 		.Wb_DataWrt_0(Wb_DataWrt_0),
 		.MemWb_RdAddr_1(MemWb_RdAddr_1),
 		.MemWb_RdWrtEn_1(MemWb_RdWrtEn_1),
 		.Wb_DataWrt_1(Wb_DataWrt_1),
 		.Decode_LdType_0(Decode_LdType_0),
 		.DecodeHazard_StallReq(DecodeHazard_StallReq),
 		.Decode_LdType_1(Decode_LdType_1),
 		.DecodeHazard_Rs1Data_0(DecodeHazard_Rs1Data_0),
 		.DecodeHazard_Rs2Data_0(DecodeHazard_Rs2Data_0),
 		.DecodeHazard_Rs1Data_1(DecodeHazard_Rs1Data_1),
 		.DecodeHazard_Rs2Data_1(DecodeHazard_Rs2Data_1)
 	);	

    PipeStage_IDEX #(
 		.STAGE_WIDTH(`PIPE_IDEX_LEN),
		.STAGE_NUM(1'b0)
 	)
 	i_IDEX0(
 		.clk(clk),
 		.rst_n(rst_n),
 		.Stall(Ctrl_Stall[2]),
 		.Flush(Flush[1]),
		.issue_select(issue_select[1]),
		.Decode_Unicorn(Decode_Unicorn),
 		.in(
 			{
 				Decode_AllCtr_0,
 				Decode_RdAddr_0,
 				Decode_Rs1Addr_0,
 				Decode_Rs2Addr_0,
 				Decode_Imm_0,
 				Decode_ImmSel_0,
 				Decode_CsrAddr_0,
 				DecodeHazard_Rs1Data_0,
 				DecodeHazard_Rs2Data_0,
 				Decode_16BitFlag_0,
 				IFID_NowPC_0
 			} 
 		),
 		.out(
 			{
 				IDEX_Sel1_0,
 				IDEX_Sel2_0,
 				IDEX_AluOp_0,
 				IDEX_StType_0,
 				IDEX_LdType_0,
 				IDEX_WbSel_0,
 				IDEX_WbRdEn_0,
 				IDEX_CsrCmd_0,
 				IDEX_CsrIllegal_0,
 				IDEX_RdAddr_0,
 				IDEX_Rs1Addr_0,
 				IDEX_Rs2Addr_0,
 				IDEX_Imm_0,
 				IDEX_ImmSel_0,
 				IDEX_CsrAddr_0,
 				IDEX_Rs1Data_0,
 				IDEX_Rs2Data_0,
 				IDEX_16BitFlag_0,
 				IDEX_NowPC_0
 			} 
 		),
		.IDEX_stall(IDEX_stall)
 	);

    PipeStage_IDEX #(
 		.STAGE_WIDTH(`PIPE_IDEX_LEN),
		.STAGE_NUM(1'b1)
 	)
 	i_IDEX1(
 		.clk(clk),
 		.rst_n(rst_n),
 		.Stall(Ctrl_Stall[2]),
 		.Flush(Flush[1]),
		.issue_select(1'b1),
		.Decode_Unicorn(Decode_Unicorn),
 		.in(
 			{
 				Decode_AllCtr_1,
 				Decode_RdAddr_1,
 				Decode_Rs1Addr_1,
 				Decode_Rs2Addr_1,
 				Decode_Imm_1,
 				Decode_ImmSel_1,
 				Decode_CsrAddr_1,
 				DecodeHazard_Rs1Data_1,
 				DecodeHazard_Rs2Data_1,
 				Decode_16BitFlag_1,
 				IFID_NowPC_1 
 			} 
 		),
 		.out(
 			{
 				IDEX_Sel1_1,
 				IDEX_Sel2_1,
 				IDEX_AluOp_1,
 				IDEX_StType_1,
 				IDEX_LdType_1,
 				IDEX_WbSel_1,
 				IDEX_WbRdEn_1,
 				IDEX_CsrCmd_1,
 				IDEX_CsrIllegal_1,
 				IDEX_RdAddr_1,
 				IDEX_Rs1Addr_1,
 				IDEX_Rs2Addr_1,
 				IDEX_Imm_1,
 				IDEX_ImmSel_1,
 				IDEX_CsrAddr_1,
 				IDEX_Rs1Data_1,
 				IDEX_Rs2Data_1,
 				IDEX_16BitFlag_1,
 				IDEX_NowPC_1
 			} 
 		)
 	);
	
 	EX i_EX (
		.IDEX_Rs1Data_0(IDEX_Rs1Data_0),
		.IDEX_Rs2Data_0(IDEX_Rs2Data_0),
		.IDEX_Sel1_0(IDEX_Sel1_0),
		.IDEX_NowPC_0(IDEX_NowPC_0),
		.IDEX_Sel2_0(IDEX_Sel2_0),
		.IDEX_Imm_0(IDEX_Imm_0),
		.Csr_RdData_0(Csr_RdData_0),
		.IDEX_AluOp_0(IDEX_AluOp_0),
		.IDEX_LdType_0(IDEX_LdType_0),
		.IDEX_StType_0(IDEX_StType_0),
		.Mem_DcacheEN_0(Mem_DcacheEN_0),
		.IDEX_16BitFlag_0(IDEX_16BitFlag_0),
		.IDEX_WbRdEn_0(IDEX_WbRdEn_0),
		.IDEX_Rs1Data_1(IDEX_Rs1Data_1),
		.IDEX_Rs2Data_1(IDEX_Rs2Data_1),
		.IDEX_Sel1_1(IDEX_Sel1_1),
		.IDEX_NowPC_1(IDEX_NowPC_1),
		.IDEX_Sel2_1(IDEX_Sel2_1),
		.IDEX_Imm_1(IDEX_Imm_1),
		.Csr_RdData_1(Csr_RdData_0),
		.IDEX_AluOp_1(IDEX_AluOp_1),
		.IDEX_LdType_1(IDEX_LdType_1),
		.IDEX_StType_1(IDEX_StType_1),
		.Mem_DcacheEN_1(Mem_DcacheEN_1),
		.IDEX_16BitFlag_1(IDEX_16BitFlag_1),
		.clk(clk),
		.rst_n(rst_n),
		.IDEX_RdAddr_0(IDEX_RdAddr_0),
        .IDEX_Rs1Addr_0(IDEX_Rs1Addr_0),
        .IDEX_Rs2Addr_0(IDEX_Rs2Addr_0),
		.IDEX_Rs1Addr_1(IDEX_Rs1Addr_1),
		.IDEX_Rs2Addr_1(IDEX_Rs2Addr_1),
		.Dcache_DataRd_0(Dcache_DataRd_0),
		.EXMem_RdWrtEn_0(EXMem_RdWrtEn_0),
		.EXMem_RdAddr_0(EXMem_RdAddr_0),
        .Mem_LdEN_0(Mem_LdEN_0),
        .Dcache_DataRd_1(Dcache_DataRd_1),
        .EXMem_RdWrtEn_1(EXMem_RdWrtEn_1),
        .EXMem_RdAddr_1(EXMem_RdAddr_1),
        .Mem_LdEN_1(Mem_LdEN_1),
		.EX_AluData_0(EX_AluData_0),
		.EX_BranchFlag_0(EX_BranchFlag_0),
		.EX_BranchPC_0(EX_BranchPC_0),
		.EX_LdStFlag_0(EX_LdStFlag_0),
		.EX_AluData_1(EX_AluData_1),
		.EX_BranchFlag_1(EX_BranchFlag_1),
		.EX_BranchPC_1(EX_BranchPC_1),
		.EX_LdStFlag_1(EX_LdStFlag_1),
		.EX_StallReq(EX_StallReq)
 	);
 wire [31:0] EXMEM_NowPC;	
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


 	PipeStage #(
 		.STAGE_WIDTH(`PIPE_EXMem_LEN)
 	)
 	i_EXMem0(
 		.clk(clk),
 		.rst_n(rst_n),
 		.Stall(Ctrl_Stall[3]),
 		.Flush(Csr_Memflush|Flush[2]),	
		.issue_select(issue_select[2]),
 		.in(
 			{
 				EX_AluData_0,
 				IDEX_RdAddr_0,
 				IDEX_Rs2Data_0,
 				IDEX_StType_0,
 				IDEX_LdType_0,
 				IDEX_WbRdEn_0,
 				IDEX_WbSel_0,
                IDEX_NowPC_0
 			} 
 		),
 		.out(
 			{
 				EXMem_AluData_0,
 				EXMem_RdAddr_0,
 				EXMem_Rs2Data_0,
 				EXMem_StType_0,
 				EXMem_LdType_0,
 				EXMem_RdWrtEn_0,
 				EXMem_WbSel_0,
                EXMEM_NowPC_0
 			} 
 		)
 	);

 	PipeStage #(
 		.STAGE_WIDTH(`PIPE_EXMem_LEN)
 	)
 	i_EXMem1(
 		.clk(clk),
 		.rst_n(rst_n),
 		.Stall(Ctrl_Stall[3]),
 		.Flush(Csr_Memflush|Flush[2]),	
		.issue_select(1'b1),
 		.in(
 			{
 				EX_AluData_1,
 				IDEX_RdAddr_1,
 				IDEX_Rs2Data_1,
 				IDEX_StType_1,
 				IDEX_LdType_1,
 				IDEX_WbRdEn_1,
 				IDEX_WbSel_1,
                IDEX_NowPC_1
 			} 
 		),
 		.out(
 			{
 				EXMem_AluData_1,
 				EXMem_RdAddr_1,
 				EXMem_Rs2Data_1,
 				EXMem_StType_1,
 				EXMem_LdType_1,
 				EXMem_RdWrtEn_1,
 				EXMem_WbSel_1,
                EXMEM_NowPC_1
 			} 
 		)
 	);

//========YB Change for ss 2020.06.22 21:21========
 	Mem i_Mem(
//		.clk(clk),
// 		.rst_n(rst_n),
		 //=====ss-0====
		.EXMem_LdType_0(EXMem_LdType_0),
		.EXMem_StType_0(EXMem_StType_0),
		.EXMem_AluData_0(EXMem_AluData_0),
		.EXMem_Rs2Data_0(EXMem_Rs2Data_0),
		 //=====ss-1====
		.EXMem_LdType_1(EXMem_LdType_1),
		.EXMem_StType_1(EXMem_StType_1),
		.EXMem_AluData_1(EXMem_AluData_1),
		.EXMem_Rs2Data_1(EXMem_Rs2Data_1),

        .Mem_LdEN_0(Mem_LdEN_0),
        .Mem_LdEN_1(Mem_LdEN_1),
        .EXMem_Rs2Data(EXMem_Rs2Data),

		//=========YB：Dcache=========
 		.Mem_DcacheEN(Mem_DcacheEN),
 		.Mem_DcacheEN_0(Mem_DcacheEN_0),
		.Mem_DcacheEN_1(Mem_DcacheEN_1),   
 		.Mem_DcacheRd(Mem_DcacheRd),  
		.Mem_DcacheWidth(Mem_DcacheWidth), 
		.Mem_DcacheAddr(Mem_DcacheAddr),
 		.Mem_DcacheSign(Mem_DcacheSign),
        .Csr_Memflush(Csr_Memflush),//new 
    	.Dcache_DataRd_0(Dcache_DataRd_0), 
    	.Dcache_DataRd_1(Dcache_DataRd_1),    
		.Dcache_DataRd(Dcache_DataRd)
     ); 

	Dcache i_Dcache(
		.clk(clk),
		.rst_n(rst_n),
		.Mem_DcacheEN(Mem_DcacheEN),    
		.Mem_DcacheRd(Mem_DcacheRd),    
		.Mem_DcacheWidth(Mem_DcacheWidth), 
		.Mem_DcacheAddr(Mem_DcacheAddr),   
		.EXMem_Rs2Data(EXMem_Rs2Data),
		.Mem_DcacheSign(Mem_DcacheSign), 
		.Dcache_DataRd(Dcache_DataRd),
		.Icache_NextPC(Fetch_NextPC),
		.Icache_Instr(Icache_Instr)
	);	
	
//========YB Change for ss 2020.06.22 21:21========
 	PipeStage #(
 		.STAGE_WIDTH(`PIPE_MemWb_LEN)
 	)
 	i_MemWb0(
 		.clk(clk),
 		.rst_n(rst_n),
 		.Stall(Ctrl_Stall[4]),
 		.Flush(Csr_Memflush|Flush[3]),
		.issue_select(issue_select[3]),
 		.in(
 			{
				//=====ss-0====
				EXMem_RdAddr_0   , 				
				EXMem_RdWrtEn_0  ,
				EXMem_AluData_0  ,
				Dcache_DataRd_0  ,
				EXMem_WbSel_0       
 			} 
 		),
 		.out(
 			{
 				//=====ss-0====
				 MemWb_RdAddr_0   , 
 				MemWb_RdWrtEn_0  ,
 				MemWb_AluData_0  ,
 				MemWb_DataRd_0   ,
 				MemWb_WbSel_0    
 			} 
 		)
 	);

 	PipeStage #(
 		.STAGE_WIDTH(`PIPE_MemWb_LEN)
 	)
 	i_MemWb1(
 		.clk(clk),
 		.rst_n(rst_n),
 		.Stall(Ctrl_Stall[4]),
 		.Flush(Csr_Memflush|Flush[3]),
		.issue_select(1'b1),
 		.in(
 			{
				//=====ss-1====
				EXMem_RdAddr_1   , 
				EXMem_RdWrtEn_1  ,
				EXMem_AluData_1  ,
				Dcache_DataRd_1  ,
				EXMem_WbSel_1       
 			} 
 		),
 		.out(
 			{
				//=====ss-1====
				MemWb_RdAddr_1   , 
 				MemWb_RdWrtEn_1  ,
 				MemWb_AluData_1  ,
 				MemWb_DataRd_1   ,
 				MemWb_WbSel_1    
 			} 
 		)
 	);
//========YB Change for ss 2020.06.22 21:21========
 	Wb i_Wb(
 		.MemWb_WbSel_0(MemWb_WbSel_0),
 		.MemWb_WbSel_1(MemWb_WbSel_1),

 		.MemWb_AluData_0(MemWb_AluData_0),
 		.MemWb_AluData_1(MemWb_AluData_1),

 		.MemWb_DataRd_0(MemWb_DataRd_0),
 		.MemWb_DataRd_1(MemWb_DataRd_1),

 		.Wb_DataWrt_0(Wb_DataWrt_0),
 		.Wb_DataWrt_1(Wb_DataWrt_1)

     );


endmodule
