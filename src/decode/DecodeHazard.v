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
	input	[`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs1Addr,
	input	[`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs2Addr,	
	input	[`RF_ADDR_WIDTH - 1 : 0] 	Decode_Rs3Addr,

	input	[`DATA_WIDTH - 1 : 0]		RF_Rs1Data,
	input	[`DATA_WIDTH - 1 : 0]		RF_Rs2Data,
	input	[`DATA_WIDTH - 1 : 0]		RF_Rs3Data,
	
	//IDEX -> DecodeHazard
	input 	[`RF_ADDR_WIDTH - 1 : 0]	IDEX_RdAddr,
	input 								IDEX_WbRdEn,
	input 	[`DATA_WIDTH - 1 : 0]		EX_AluData,
	
	//EXMem -> DecodeHazard
    input 	[`RF_ADDR_WIDTH - 1 : 0]	EXMem_RdAddr,
    input 								EXMem_RdWrtEn,
    input 	[`DATA_WIDTH - 1 : 0]		EXMem_AluData,
	
	//Mem -> DecodeHazard
    input   [`DATA_WIDTH - 1 : 0] 		Dcache_DataRd,
    input              					Mem_LdEn,
	
	//MemWb -> DecodeHazard
	input	[`RF_ADDR_WIDTH - 1 : 0]	MemWb_RdAddr,
	input								MemWb_RdWrtEn,
	input	[`DATA_WIDTH - 1 : 0]		Wb_DataWrt,//Wb -> DecodeHazard
	
	//Decode ->DecodeHazard
	input 	[`LD_TYPE_WIDTH - 1 : 0 ]	Decode_LdType,
	output								DecodeHazard_StallReq,
	
	//DecodeHazard -> IDEX
	output	[`DATA_WIDTH - 1 : 0]		DecodeHazard_Rs1Data,
	output	[`DATA_WIDTH - 1 : 0]		DecodeHazard_Rs2Data,
	output	[`DATA_WIDTH - 1 : 0]		DecodeHazard_Rs3Data
);
	reg 	[`RS1_SEL_WIDTH - 1 : 0]	rs1Sel;
	reg 	[`RS2_SEL_WIDTH - 1 : 0]	rs2Sel;
	reg 	[`RS2_SEL_WIDTH - 1 : 0]	rs3Sel;

	reg 	[`LD_TYPE_WIDTH - 1 : 0 ]	preLdType;

	Mux #(
		.SEL_WIDTH(3),
		.SEL_NUM(5),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs1Mux
	(
		.in({Wb_DataWrt, Dcache_DataRd, EXMem_AluData, EX_AluData, RF_Rs1Data}),
		.sel(rs1Sel),
		.out(DecodeHazard_Rs1Data)
	);
	
	Mux #(
		.SEL_WIDTH(3),
		.SEL_NUM(5),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs2Mux
	(
		.in({Wb_DataWrt, Dcache_DataRd, EXMem_AluData, EX_AluData, RF_Rs2Data}),
		.sel(rs2Sel),
		.out(DecodeHazard_Rs2Data)
	);


	Mux #(
		.SEL_WIDTH(3),
		.SEL_NUM(5),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs3Mux
	(
		.in({Wb_DataWrt, Dcache_DataRd, EXMem_AluData, EX_AluData, RF_Rs3Data}),
		.sel(rs3Sel),
		.out(DecodeHazard_Rs3Data)
	);
	
//rs1 forward
always @(*)
    if(Decode_Rs1Addr != 5'b0)
		if(IDEX_WbRdEn && Decode_Rs1Addr == IDEX_RdAddr)
			rs1Sel = `RS_SEL_EX;
		else if(EXMem_RdWrtEn && Decode_Rs1Addr == EXMem_RdAddr)
            case (Mem_LdEn)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs1Sel = `RS_SEL_EXMem;
                default : 
                    rs1Sel = `RS_SEL_Dcache;
            endcase
        else if(MemWb_RdWrtEn && Decode_Rs1Addr == MemWb_RdAddr)
            rs1Sel = `RS_SEL_Wb;
        else
            rs1Sel = `RS_SEL_RF;
    else
        rs1Sel = `RS_SEL_RF;


//rs2 forward
always @(*)
    if(Decode_Rs2Addr != 5'b0)
		if(IDEX_WbRdEn && Decode_Rs2Addr == IDEX_RdAddr)
			rs2Sel = `RS_SEL_EX;
		else if(EXMem_RdWrtEn && Decode_Rs2Addr == EXMem_RdAddr)
            case (Mem_LdEn)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs2Sel = `RS_SEL_EXMem;
                default : 
                    rs2Sel = `RS_SEL_Dcache;
            endcase
        else if(MemWb_RdWrtEn && Decode_Rs2Addr == MemWb_RdAddr)
            rs2Sel = `RS_SEL_Wb;
        else
            rs2Sel = `RS_SEL_RF;
    else
        rs2Sel = `RS_SEL_RF;

//rs3 forward
always @(*)
    if(Decode_Rs3Addr != 5'b0)
		if(IDEX_WbRdEn && Decode_Rs3Addr == IDEX_RdAddr)
			rs3Sel = `RS_SEL_EX;
		else if(EXMem_RdWrtEn && Decode_Rs3Addr == EXMem_RdAddr)
            case (Mem_LdEn)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs3Sel = `RS_SEL_EXMem;
                default : 
                    rs3Sel = `RS_SEL_Dcache;
            endcase
        else if(MemWb_RdWrtEn && Decode_Rs3Addr == MemWb_RdAddr)
            rs3Sel = `RS_SEL_Wb;
        else
            rs3Sel = `RS_SEL_RF;
    else
        rs3Sel = `RS_SEL_RF;

//need stall
always @(posedge clk)
	if(~rst_n)
		preLdType <= `LD_XXX;
	else
		preLdType <= Decode_LdType;

assign DecodeHazard_StallReq = ((preLdType != `LD_XXX) && ((rs1Sel == `RS_SEL_EX) || (rs2Sel == `RS_SEL_EX) || (rs3Sel == `RS_SEL_EX))) ? 1'b1 : 1'b0;

endmodule
