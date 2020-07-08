/*
 * @Author: Sue
 * @Date:   2019-10-30 16:23
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-30 16:23
 * @Describe: decode data and control message from instruction 
 * @ModuleParamDescribe: the Describe of module param
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module DecodeHazard(
	input								clk,
	input								rst_n,
	
	//RF -> DecodeHazard
	input	[`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs1Addr_0,
	input	[`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs2Addr_0,	

	input	[`DATA_WIDTH - 1 : 0]		RF_Rs1Data_0,
	input	[`DATA_WIDTH - 1 : 0]		RF_Rs2Data_0,

	//RF -> DecodeHazard
	input	[`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs1Addr_1,
	input	[`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs2Addr_1,	

	input	[`DATA_WIDTH - 1 : 0]		RF_Rs1Data_1,
	input	[`DATA_WIDTH - 1 : 0]		RF_Rs2Data_1,
	
	//IDEX -> DecodeHazard
	input 	[`RF_ADDR_WIDTH - 1 : 0]	IDEX_RdAddr_0,
	input 								IDEX_WbRdEn_0,
	input 	[`DATA_WIDTH - 1 : 0]		EX_AluData_0,

	//IDEX -> DecodeHazard
	input 	[`RF_ADDR_WIDTH - 1 : 0]	IDEX_RdAddr_1,
	input 								IDEX_WbRdEn_1,
	input 	[`DATA_WIDTH - 1 : 0]		EX_AluData_1,
	
	//EXMem -> DecodeHazard
    input 	[`RF_ADDR_WIDTH - 1 : 0]	EXMem_RdAddr_0,
    input 								EXMem_RdWrtEn_0,
    input 	[`DATA_WIDTH - 1 : 0]		EXMem_AluData_0,

	//EXMem -> DecodeHazard
    input 	[`RF_ADDR_WIDTH - 1 : 0]	EXMem_RdAddr_1,
    input 								EXMem_RdWrtEn_1,
    input 	[`DATA_WIDTH - 1 : 0]		EXMem_AluData_1,
	
	//Mem -> DecodeHazard
    input   [`DATA_WIDTH - 1 : 0] 		Dcache_DataRd_0,
    input              					Mem_LdEn_0,

	//Mem -> DecodeHazard
    input   [`DATA_WIDTH - 1 : 0] 		Dcache_DataRd_1,
    input              					Mem_LdEn_1,
	
	//MemWb -> DecodeHazard
	input	[`RF_ADDR_WIDTH - 1 : 0]	MemWb_RdAddr_0,
	input								MemWb_RdWrtEn_0,
	input	[`DATA_WIDTH - 1 : 0]		Wb_DataWrt_0,//Wb -> DecodeHazard

	//MemWb -> DecodeHazard
	input	[`RF_ADDR_WIDTH - 1 : 0]	MemWb_RdAddr_1,
	input								MemWb_RdWrtEn_1,
	input	[`DATA_WIDTH - 1 : 0]		Wb_DataWrt_1,//Wb -> DecodeHazard
	
	//Decode ->DecodeHazard
	input 	[`LD_TYPE_WIDTH - 1 : 0 ]	Decode_LdType_0,
	output								DecodeHazard_StallReq,

	//Decode ->DecodeHazard
	input 	[`LD_TYPE_WIDTH - 1 : 0 ]	Decode_LdType_1,
	
	//DecodeHazard -> IDEX
	output	[`DATA_WIDTH - 1 : 0]		DecodeHazard_Rs1Data_0,
	output	[`DATA_WIDTH - 1 : 0]		DecodeHazard_Rs2Data_0,

	//DecodeHazard -> IDEX
	output	[`DATA_WIDTH - 1 : 0]		DecodeHazard_Rs1Data_1,
	output	[`DATA_WIDTH - 1 : 0]		DecodeHazard_Rs2Data_1
);

	reg 	[`RS1_SEL_WIDTH - 1 : 0]	rs1Sel_0;
	reg 	[`RS2_SEL_WIDTH - 1 : 0]	rs2Sel_0;

	reg 	[`RS1_SEL_WIDTH - 1 : 0]	rs1Sel_1;
	reg 	[`RS2_SEL_WIDTH - 1 : 0]	rs2Sel_1;
	
	reg 	[`LD_TYPE_WIDTH - 1 : 0 ]	preLdType_0;
	reg 	[`LD_TYPE_WIDTH - 1 : 0 ]	preLdType_1;
	Mux #(
		.SEL_WIDTH(4),
		.SEL_NUM(12),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs1Mux_0
	(
		.in({Wb_DataWrt_1, Dcache_DataRd_1, EXMem_AluData_1, EX_AluData_1, RF_Rs2Data_1, RF_Rs1Data_1,
			 Wb_DataWrt_0, Dcache_DataRd_0, EXMem_AluData_0, EX_AluData_0, RF_Rs2Data_0, RF_Rs1Data_0}),
		.sel(rs1Sel_0),
		.out(DecodeHazard_Rs1Data_0)
	);
	
	Mux #(
		.SEL_WIDTH(4),
		.SEL_NUM(12),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs2Mux_0
	(
		.in({Wb_DataWrt_1, Dcache_DataRd_1, EXMem_AluData_1, EX_AluData_1, RF_Rs2Data_1, RF_Rs1Data_1,
			 Wb_DataWrt_0, Dcache_DataRd_0, EXMem_AluData_0, EX_AluData_0, RF_Rs2Data_0, RF_Rs1Data_0}),
		.sel(rs2Sel_0),
		.out(DecodeHazard_Rs2Data_0)
	);

	Mux #(
		.SEL_WIDTH(4),
		.SEL_NUM(12),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs1Mux_1
	(
		.in({Wb_DataWrt_1, Dcache_DataRd_1, EXMem_AluData_1, EX_AluData_1, RF_Rs2Data_1, RF_Rs1Data_1,
			 Wb_DataWrt_0, Dcache_DataRd_0, EXMem_AluData_0, EX_AluData_0, RF_Rs2Data_0, RF_Rs1Data_0}),
		.sel(rs1Sel_1),
		.out(DecodeHazard_Rs1Data_1)
	);
	
	Mux #(
		.SEL_WIDTH(4),
		.SEL_NUM(12),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs2Mux_1
	(
		.in({Wb_DataWrt_1, Dcache_DataRd_1, EXMem_AluData_1, EX_AluData_1, RF_Rs2Data_1, RF_Rs1Data_1,
			 Wb_DataWrt_0, Dcache_DataRd_0, EXMem_AluData_0, EX_AluData_0, RF_Rs2Data_0, RF_Rs1Data_0}),
		.sel(rs2Sel_1),
		.out(DecodeHazard_Rs2Data_1)
	);


//issue0 rs1 forward
always @(*)
    if(Decode_Rs1Addr_0 != 5'b0)
		if(IDEX_WbRdEn_0 && Decode_Rs1Addr_0 == IDEX_RdAddr_1)
			rs1Sel_0 = `RS_SEL_EX_1;
		else if(IDEX_WbRdEn_0 && Decode_Rs1Addr_0 == IDEX_RdAddr_0)
			rs1Sel_0 = `RS_SEL_EX_0;
		else if(EXMem_RdWrtEn_1 && Decode_Rs1Addr_0 == EXMem_RdAddr_1)
            case (Mem_LdEn_1)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs1Sel_0 = `RS_SEL_EXMem_1;
                default : 
                    rs1Sel_0 = `RS_SEL_Dcache_1;
            endcase
		else if(EXMem_RdWrtEn_0 && Decode_Rs1Addr_0 == EXMem_RdAddr_0)
            case (Mem_LdEn_0)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs1Sel_0 = `RS_SEL_EXMem_0;
                default : 
                    rs1Sel_0 = `RS_SEL_Dcache_0;
            endcase
        else if(MemWb_RdWrtEn_1 && Decode_Rs1Addr_0 == MemWb_RdAddr_1)
            rs1Sel_0 = `RS_SEL_Wb_1;
        else if(MemWb_RdWrtEn_0 && Decode_Rs1Addr_0 == MemWb_RdAddr_0)
            rs1Sel_0 = `RS_SEL_Wb_0;
        else
            rs1Sel_0 = `RS_SEL_RF1_0;
    else
        rs1Sel_0 = `RS_SEL_RF1_0;


//issue0 rs2 forward
always @(*)
    if(Decode_Rs2Addr_0 != 5'b0)
		if(IDEX_WbRdEn_0 && Decode_Rs2Addr_0 == IDEX_RdAddr_1)
			rs2Sel_0 = `RS_SEL_EX_1;
		else if(IDEX_WbRdEn_0 && Decode_Rs2Addr_0 == IDEX_RdAddr_0)
			rs2Sel_0 = `RS_SEL_EX_0;
		else if(EXMem_RdWrtEn_1 && Decode_Rs2Addr_0 == EXMem_RdAddr_1)
            case (Mem_LdEn_0)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs2Sel_0 = `RS_SEL_EXMem_1;
                default : 
                    rs2Sel_0 = `RS_SEL_Dcache_1;
            endcase
		else if(EXMem_RdWrtEn_0 && Decode_Rs2Addr_0 == EXMem_RdAddr_0)
            case (Mem_LdEn_0)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs2Sel_0 = `RS_SEL_EXMem_0;
                default : 
                    rs2Sel_0 = `RS_SEL_Dcache_0;
            endcase
		else if(MemWb_RdWrtEn_1 && Decode_Rs2Addr_0 == MemWb_RdAddr_1)
            rs2Sel_0 = `RS_SEL_Wb_1;
        else if(MemWb_RdWrtEn_0 && Decode_Rs2Addr_0 == MemWb_RdAddr_0)
            rs2Sel_0 = `RS_SEL_Wb_0;
        else
            rs2Sel_0 = `RS_SEL_RF2_1;
    else
        rs2Sel_0 = `RS_SEL_RF2_1;

//issue1 rs1 forward
always @(*)
    if(Decode_Rs1Addr_1 != 5'b0)
		if(IDEX_WbRdEn_1 && Decode_Rs1Addr_1 == IDEX_RdAddr_1)
			rs1Sel_1 = `RS_SEL_EX_1;
		else if(IDEX_WbRdEn_0 && Decode_Rs1Addr_1 == IDEX_RdAddr_0)
			rs1Sel_1 = `RS_SEL_EX_0;
		else if(EXMem_RdWrtEn_1 && Decode_Rs1Addr_1 == EXMem_RdAddr_1)
            case (Mem_LdEn_1)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs1Sel_1 = `RS_SEL_EXMem_1;
                default : 
                    rs1Sel_1 = `RS_SEL_Dcache_1;
            endcase
		else if(EXMem_RdWrtEn_0 && Decode_Rs1Addr_1 == EXMem_RdAddr_0)
            case (Mem_LdEn_0)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs1Sel_1 = `RS_SEL_EXMem_0;
                default : 
                    rs1Sel_1 = `RS_SEL_Dcache_0;
            endcase
        else if(MemWb_RdWrtEn_1 && Decode_Rs1Addr_1 == MemWb_RdAddr_1)
            rs1Sel_1 = `RS_SEL_Wb_1;
        else if(MemWb_RdWrtEn_0 && Decode_Rs1Addr_1 == MemWb_RdAddr_0)
            rs1Sel_1 = `RS_SEL_Wb_0;
        else
            rs1Sel_1 = `RS_SEL_RF1_1;
    else
        rs1Sel_1 = `RS_SEL_RF1_1;


//issue1 rs2 forward
always @(*)
    if(Decode_Rs2Addr_1 != 5'b0)
		if(IDEX_WbRdEn_0 && Decode_Rs2Addr_1 == IDEX_RdAddr_1)
			rs2Sel_1 = `RS_SEL_EX_1;
		else if(IDEX_WbRdEn_0 && Decode_Rs2Addr_1 == IDEX_RdAddr_0)
			rs2Sel_1 = `RS_SEL_EX_0;
		else if(EXMem_RdWrtEn_1 && Decode_Rs2Addr_1 == EXMem_RdAddr_1)
            case (Mem_LdEn_0)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs2Sel_1 = `RS_SEL_EXMem_1;
                default : 
                    rs2Sel_1 = `RS_SEL_Dcache_1;
            endcase
		else if(EXMem_RdWrtEn_0 && Decode_Rs2Addr_1 == EXMem_RdAddr_0)
            case (Mem_LdEn_0)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs2Sel_1 = `RS_SEL_EXMem_0;
                default : 
                    rs2Sel_1 = `RS_SEL_Dcache_0;
            endcase
		else if(MemWb_RdWrtEn_1 && Decode_Rs2Addr_1 == MemWb_RdAddr_1)
            rs2Sel_1 = `RS_SEL_Wb_1;
        else if(MemWb_RdWrtEn_0 && Decode_Rs2Addr_1 == MemWb_RdAddr_0)
            rs2Sel_1 = `RS_SEL_Wb_0;
        else
            rs2Sel_1 = `RS_SEL_RF2_1;
    else
        rs2Sel_1 = `RS_SEL_RF2_1;

//need stall
always @(posedge clk)
	if(~rst_n)
		preLdType_0 <= `LD_XXX;
	else
		preLdType_0 <= Decode_LdType_0;

always @(posedge clk)
	if(~rst_n)
		preLdType_1 <= `LD_XXX;
	else
		preLdType_1 <= Decode_LdType_0;

wire   DecodeHazard_StallReq_0 = ((preLdType_0 != `LD_XXX) && ((rs1Sel_0 == `RS_SEL_EX_0) || (rs2Sel_0 == `RS_SEL_EX_0))) ? 1'b1 : 1'b0;
wire   DecodeHazard_StallReq_1 = ((preLdType_1 != `LD_XXX) && ((rs1Sel_1 == `RS_SEL_EX_1) || (rs2Sel_1 == `RS_SEL_EX_1))) ? 1'b1 : 1'b0;

assign DecodeHazard_StallReq = DecodeHazard_StallReq_0 || DecodeHazard_StallReq_1;

endmodule
