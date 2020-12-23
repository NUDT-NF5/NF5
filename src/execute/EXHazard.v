/*
 * @Author: J-Zenk
 * @Date:   2020-12-22 16:23
 * @Last Modified by: J-Zenk
 * @Last Modified time: 2020-12-22 16:23
 * @Describe: decode data and control message from instruction 
 * @ModuleParamDescribe: the Describe of module param
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module EXHazard(
	//RF -> EXHazard
	input	[`RF_ADDR_WIDTH - 1 : 0]	IDEX_Rs1Addr,
	input	[`RF_ADDR_WIDTH - 1 : 0]	IDEX_Rs2Addr,	
	input	[`RF_ADDR_WIDTH - 1 : 0] 	IDEX_Rs3Addr,

	input	[`DATA_WIDTH - 1 : 0]		RF_Rs1Data,
	input	[`DATA_WIDTH - 1 : 0]		RF_Rs2Data,
	input	[`DATA_WIDTH - 1 : 0]		RF_Rs3Data,
	
	//EXMem -> EXHazard
    input 	[`RF_ADDR_WIDTH - 1 : 0]	EXMem_RdAddr,
    //input 								EXMem_RdWrtEN,
    input 	[`DATA_WIDTH - 1 : 0]		EXMem_AluData,
	
	//Mem -> EXHazard
    input   [`DATA_WIDTH - 1 : 0] 		Dcache_DataRd,
    input              					Mem_LdEN,
	
	//EXHazard -> IDEX
	output	[`DATA_WIDTH - 1 : 0]		EXHazard_Rs1Data,
	output	[`DATA_WIDTH - 1 : 0]		EXHazard_Rs2Data,
	output	[`DATA_WIDTH - 1 : 0]		EXHazard_Rs3Data
);
	reg 	                        	rs1Sel;
	reg 	                        	rs2Sel;
	reg 	                        	rs3Sel;

	reg 	[`LD_TYPE_WIDTH - 1 : 0 ]	preLdType;

	Mux #(
		.SEL_WIDTH(1),
		.SEL_NUM(2),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs1Mux
	(
		.in({Dcache_DataRd, RF_Rs1Data}),
		.sel(rs1Sel),
		.out(EXHazard_Rs1Data)
	);
	
	Mux #(
		.SEL_WIDTH(1),
		.SEL_NUM(2),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs2Mux
	(
		.in({Dcache_DataRd, RF_Rs2Data}),
		.sel(rs2Sel),
		.out(EXHazard_Rs2Data)
	);


	Mux #(
		.SEL_WIDTH(1),
		.SEL_NUM(2),
		.DATA_WIDTH(`DATA_WIDTH),
		.DATA_WIDTH_LOG2(`DATA_WIDTH_LOG2)
	) i_Rs3Mux
	(
		.in({Dcache_DataRd, RF_Rs3Data}),
		.sel(rs3Sel),
		.out(EXHazard_Rs3Data)
	);
	
//rs1 forward
/*always @(*)
    if(Decode_Rs1Addr != 5'b0)
		if(IDEX_WbRdEN && Decode_Rs1Addr == IDEX_RdAddr)
			rs1Sel = `RS_SEL_EX;
		else if(EXMem_RdWrtEN && Decode_Rs1Addr == EXMem_RdAddr)
            case (Mem_LdEN)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs1Sel = `RS_SEL_EXMem;
                default : 
                    rs1Sel = `RS_SEL_Dcache;
            endcase
        else if(MemWb_RdWrtEN && Decode_Rs1Addr == MemWb_RdAddr)
            rs1Sel = `RS_SEL_Wb;
        else
            rs1Sel = `RS_SEL_RF;
    else
        rs1Sel = `RS_SEL_RF;*/

always @*
    if(IDEX_Rs1Addr != 5'b0)
        if(Mem_LdEN && IDEX_Rs1Addr == EXMem_RdAddr)
            rs1Sel = 1'b1;
        else
            rs1Sel = 1'b0;
    else 
        rs1Sel = 1'b0;

//rs2 forward
always @*
    if(IDEX_Rs2Addr != 5'b0)
        if(Mem_LdEN && IDEX_Rs2Addr == EXMem_RdAddr)
            rs2Sel = 1'b1;
        else
            rs2Sel = 1'b0;
    else 
        rs2Sel = 1'b0;

//rs3 forward
always @*
    if(IDEX_Rs3Addr != 5'b0)
        if(Mem_LdEN && IDEX_Rs3Addr == EXMem_RdAddr)
            rs3Sel = 1'b1;
        else
            rs3Sel = 1'b0;
    else 
        rs3Sel = 1'b0;

//rs2 forward
/*always @(*)
    if(Decode_Rs2Addr != 5'b0)
		if(IDEX_WbRdEN && Decode_Rs2Addr == IDEX_RdAddr)
			rs2Sel = `RS_SEL_EX;
		else if(EXMem_RdWrtEN && Decode_Rs2Addr == EXMem_RdAddr)
            case (Mem_LdEN)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs2Sel = `RS_SEL_EXMem;
                default : 
                    rs2Sel = `RS_SEL_Dcache;
            endcase
        else if(MemWb_RdWrtEN && Decode_Rs2Addr == MemWb_RdAddr)
            rs2Sel = `RS_SEL_Wb;
        else
            rs2Sel = `RS_SEL_RF;
    else
        rs2Sel = `RS_SEL_RF;

//rs3 forward
always @(*)
    if(Decode_Rs3Addr != 5'b0)
		if(IDEX_WbRdEN && Decode_Rs3Addr == IDEX_RdAddr)
			rs3Sel = `RS_SEL_EX;
		else if(EXMem_RdWrtEN && Decode_Rs3Addr == EXMem_RdAddr)
            case (Mem_LdEN)                             //if instruction is load, then forward data which is from DCache, else forward data which is from AluData
                0 : 
                    rs3Sel = `RS_SEL_EXMem;
                default : 
                    rs3Sel = `RS_SEL_Dcache;
            endcase
        else if(MemWb_RdWrtEN && Decode_Rs3Addr == MemWb_RdAddr)
            rs3Sel = `RS_SEL_Wb;
        else
            rs3Sel = `RS_SEL_RF;
    else
        rs3Sel = `RS_SEL_RF;*/

endmodule
