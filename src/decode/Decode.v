/*
 * @Author: Sue
 * @Date:   2019-10-28 9:53
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-28 9:53
 * @Describe: decode data and control message from instruction 
 * @ModuleParamDescribe: the Describe of module param
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module Decode(
	//IFID -> Decode
	input		[`INSTR_WIDTH - 1 : 0]		IFID_Instr,
	input		[`ADDR_WIDTH - 1 : 0]		IFID_NowPC_0, 
	output  reg	[`ADDR_WIDTH - 1 : 0]		IFID_NowPC_1,
	//part 1
	//Decode -> IDEX
	output	wire [`All_CTRL_WIDTH - 1 : 0]	Decode_AllCtr_0,
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_RdAddr_0,
	output	wire [`DATA_WIDTH - 1 : 0]		Decode_Imm_0,
	output	wire [`IMM_SEL_WIDTH - 1 : 0]	Decode_ImmSel_0,
	output	wire [`CSR_ADDR_WIDTH - 1 : 0]	Decode_CsrAddr_0,
		
	//Decode -> RegFile and IDEX
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs1Addr_0,
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs2Addr_0,
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs3Addr_0,
	output	wire [`FUNCT3_WIDTH - 1 : 0]	Decode_Rm_0,
    
	//Decode -> Ctrl	
	output 	wire [2 - 1 : 0]				Decode_Stall_0,
	output 	wire [4 - 1 : 0]				Decode_Flush_0,
	//Decode ->Fetch
	output 	reg								Decode_16BitFlag_0,
	
	//Decode ->DecodeHazard
	output 	wire [`LD_TYPE_WIDTH - 1 : 0 ]	Decode_LdType_0,

	//part 2
	//Decode -> IDEX
	output	wire [`All_CTRL_WIDTH - 1 : 0]	Decode_AllCtr_1,
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_RdAddr_1,
	output	wire [`DATA_WIDTH - 1 : 0]		Decode_Imm_1,
	output	wire [`IMM_SEL_WIDTH - 1 : 0]	Decode_ImmSel_1,
	output	wire [`CSR_ADDR_WIDTH - 1 : 0]	Decode_CsrAddr_1,
		
	//Decode -> RegFile and IDEX
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs1Addr_1,
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs2Addr_1,
	output	wire [`RF_ADDR_WIDTH - 1 : 0]	Decode_Rs3Addr_1,
	output	wire [`FUNCT3_WIDTH - 1 : 0]	Decode_Rm_1,
    
	//Decode -> Ctrl	
	output 	wire [2 - 1 : 0]				Decode_Stall_1,
	output 	wire [4 - 1 : 0]				Decode_Flush_1,
	//Decode ->Fetch
	output 	reg								Decode_16BitFlag_1,
	
	//Decode ->DecodeHazard
	output 	wire  [`LD_TYPE_WIDTH - 1 : 0]	Decode_LdType_1,

	//indicator
	output  wire 							Decode_Unicorn,
	
	//select next pc
	output	reg  [`PC_PLUS_WIDTH - 1 : 0]	Decode_NextPC
);

 	wire	[`DECODER_OUT_WIDTH - 1 : 0]	message32_1;
 	wire	[`DECODER_OUT_WIDTH - 1 : 0]	message32_2;
 	wire	[`DECODER_OUT_WIDTH - 1 : 0]	message32_3;
 	wire	[`DECODER_OUT_WIDTH - 1 : 0]	message16_1;
 	wire	[`DECODER_OUT_WIDTH - 1 : 0]	message16_2;
 	wire	[`DECODER_OUT_WIDTH - 1 : 0]	message16_3;

 	wire									is32_1;
 	wire									is32_2;
 	wire									is32_3;
 	wire									is16_1;
 	wire									is16_2;
 	wire									is16_3;

 	wire	[`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode32_1;
 	wire	[`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode32_2;
 	wire	[`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode32_3;

 	wire	[6 - 1 : 0]						instrForm;

 	reg		[`DECODER_OUT_WIDTH - 1 : 0]	instr_0;
 	reg		[`DECODER_OUT_WIDTH - 1 : 0]	instr_1;
	
	reg                                     unicorn0;
	reg                                     unicorn1;

	//instr 0
	wire	[`A_SEL_WIDTH - 1 : 0 ]			A_sel_0;
	wire	[`B_SEL_WIDTH - 1 : 0 ]			B_sel_0;
	wire	[`ALU_OP_WIDTH - 1 : 0 ]		aluOp_0;
	wire	[`ST_TYPE_WIDTH - 1 : 0 ]		stType_0;
	wire	[`LD_TYPE_WIDTH - 1 : 0 ]		ldType_0;
	wire	[`WB_SEL_WIDTH - 1 : 0 ]		wbSel_0;
	wire	[`BOOL_WIDTH - 1 : 0 ]			wbRdEn_0;
	wire	[`CSR_CMD_WIDTH - 1 : 0 ]		csrCmd_0;
	wire	[`BOOL_WIDTH - 1 : 0 ]			illegal_0;

	//instr 1
	wire	[`A_SEL_WIDTH - 1 : 0 ]			A_sel_1;
	wire	[`B_SEL_WIDTH - 1 : 0 ]			B_sel_1;
	wire	[`ALU_OP_WIDTH - 1 : 0 ]		aluOp_1;
	wire	[`ST_TYPE_WIDTH - 1 : 0 ]		stType_1;
	wire	[`LD_TYPE_WIDTH - 1 : 0 ]		ldType_1;
	wire	[`WB_SEL_WIDTH - 1 : 0 ]		wbSel_1;
	wire	[`BOOL_WIDTH - 1 : 0 ]			wbRdEn_1;
	wire	[`CSR_CMD_WIDTH - 1 : 0 ]		csrCmd_1;
	wire	[`BOOL_WIDTH - 1 : 0 ]			illegal_1;

	//temp
	wire 	[`XLEN_WIDTH_SEL - 1 : 0]  		xlenSel_0;
	wire 	[`XLEN_WIDTH_SEL - 1 : 0]  		xlenSel_1;

    Decoder32 i_decoder32_1(
			.instr32(IFID_Instr[31:0]),
			.message32(message32_1),
			.unicorn(unicorn32_1),
			.is32(is32_1),
			.iEncode  (iEncode32_1)
    	);

    Decoder32 i_decoder32_2(
			.instr32(IFID_Instr[47:16]),
			.message32(message32_2),
			.unicorn(unicorn32_2),
			.is32(is32_2),
			.iEncode  (iEncode32_2)
    	);

    Decoder32 i_decoder32_3(
			.instr32(IFID_Instr[63:32]),
			.message32(message32_3),
			.unicorn(unicorn32_3),
			.is32(is32_3),
			.iEncode  (iEncode32_3)
    	);

    Decoder16 i_decoder16_1(
			.instr16(IFID_Instr[15:0]),
			.message16(message16_1),
			.unicorn(unicorn16_1),
			.is16(is16_1)
    	);

    Decoder16 i_decoder16_2(
			.instr16(IFID_Instr[31:16]),
			.message16(message16_2),
			.unicorn(unicorn16_2),
			.is16(is16_2)
    	);

    Decoder16 i_decoder16_3(
			.instr16(IFID_Instr[47:32]),
			.message16(message16_3),
			.unicorn(unicorn16_3),
			.is16(is16_3)
    	);

    assign instrForm = {is32_1, is32_2, is32_3, is16_1, is16_2, is16_3};
	assign Decode_Unicorn = unicorn0 && unicorn1;

    always @(*) begin : switchInstrForm_
    	casex (instrForm)
    		6'b1x1xxx : begin instr_0 = message32_1; instr_1 = message32_3; Decode_NextPC = `PC_PLUS_8; Decode_16BitFlag_0 = 1'b0; Decode_16BitFlag_1 = 1'b0; IFID_NowPC_1 = IFID_NowPC_0 + 32'h0000_0004; unicorn0 = unicorn32_1; unicorn1 = unicorn32_3; end // 32/32
    		6'b0101xx : begin instr_0 = message16_1; instr_1 = message32_2; Decode_NextPC = `PC_PLUS_6; Decode_16BitFlag_0 = 1'b1; Decode_16BitFlag_1 = 1'b0; IFID_NowPC_1 = IFID_NowPC_0 + 32'h0000_0002; unicorn0 = unicorn16_1; unicorn1 = unicorn32_2; end // 16/32/16
    		6'b1000x1 : begin instr_0 = message32_1; instr_1 = message16_3; Decode_NextPC = `PC_PLUS_6; Decode_16BitFlag_0 = 1'b0; Decode_16BitFlag_1 = 1'b1; IFID_NowPC_1 = IFID_NowPC_0 + 32'h0000_0004; unicorn0 = unicorn32_1; unicorn1 = unicorn16_3; end // 16/16/32
    		6'b000111 : begin instr_0 = message16_1; instr_1 = message16_2; Decode_NextPC = `PC_PLUS_4; Decode_16BitFlag_0 = 1'b1; Decode_16BitFlag_1 = 1'b1; IFID_NowPC_1 = IFID_NowPC_0 + 32'h0000_0002; unicorn0 = unicorn16_1; unicorn1 = unicorn16_2; end // 16/16/16/16
    		6'b001110 : begin instr_0 = message16_1; instr_1 = message16_2; Decode_NextPC = `PC_PLUS_4; Decode_16BitFlag_0 = 1'b1; Decode_16BitFlag_1 = 1'b1; IFID_NowPC_1 = IFID_NowPC_0 + 32'h0000_0002; unicorn0 = unicorn16_1; unicorn1 = unicorn16_2; end // 32/16/16
    		6'b100000 : //jal
    					begin : JAL_PLUS_ILLEGAL
    						if(iEncode32_1 == `INSTR_ENCODE_WIDTH'd2) //JAL
    						begin
    							instr_0 = message32_1;
    							instr_1 = 0;
    							Decode_NextPC = `PC_PLUS_0;
    							Decode_16BitFlag_0 = 0;
    							Decode_16BitFlag_1 = 0;
    							IFID_NowPC_1 = 0;
    							unicorn0 = unicorn32_1;
    							unicorn1 = 0;
    						end else begin : ALL_FAILS
    							instr_0 = 0;
    							instr_1 = 0;
    							Decode_NextPC = `PC_PLUS_0;
    							Decode_16BitFlag_0 = 0;
    							Decode_16BitFlag_1 = 0;
    							IFID_NowPC_1 = 0;
    							unicorn0 = 0;
    							unicorn1 = 0;
    						end
    					end
    		default   : begin instr_0 = {`DECODER_OUT_WIDTH{1'b0}}; instr_1 = {`DECODER_OUT_WIDTH{1'b0}}; Decode_NextPC = `PC_PLUS_0; Decode_16BitFlag_0 = 1'b0; Decode_16BitFlag_1 = 1'b0; IFID_NowPC_1 = IFID_NowPC_0 + 32'h0000_0002;end
    	endcase
    end

	assign {
		Decode_RdAddr_0,
		Decode_Rs1Addr_0,
		Decode_Rs2Addr_0,
		Decode_Rs3Addr_0,
		Decode_CsrAddr_0,
		Decode_Rm_0,
		Decode_AllCtr_0,
		Decode_ImmSel_0,
		Decode_Stall_0,
		Decode_Flush_0,
		xlenSel_0,
		Decode_Imm_0
		} = instr_0;

	assign {
		Decode_RdAddr_1,
		Decode_Rs1Addr_1,
		Decode_Rs2Addr_1,
		Decode_Rs3Addr_1,
		Decode_CsrAddr_1,
		Decode_Rm_1,
		Decode_AllCtr_1,
		Decode_ImmSel_1,
		Decode_Stall_1,
		Decode_Flush_1,
		xlenSel_1,
		Decode_Imm_1
		} = instr_1;


	assign	{
				A_sel_0,
				B_sel_0,
				aluOp_0,
				stType_0,
				ldType_0,
				wbSel_0,
				wbRdEn_0,
				csrCmd_0,
				illegal_0
				} = Decode_AllCtr_0;

	assign	{
				A_sel_1,
				B_sel_1,
				aluOp_1,
				stType_1,
				ldType_1,
				wbSel_1,
				wbRdEn_1,
				csrCmd_1,
				illegal_1
				} = Decode_AllCtr_1;

	assign Decode_LdType_0 = ldType_0;
	assign Decode_LdType_1 = ldType_1;

endmodule

module Decoder32 (
	input  		[32 - 1 : 0]					instr32,
	output 		[`DECODER_OUT_WIDTH - 1 : 0]	message32,
	output 										unicorn,
	output 										is32,
	output wire	[`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode
	
);

	// module 1
	//wire	[`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode;// for all device control info need to be piped
	wire	[`RF_ADDR_WIDTH - 1 : 0]		rdAddr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		rs1Addr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		rs2Addr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		rs3Addr;
	wire	[`CSR_ADDR_WIDTH - 1 : 0]		csrAddr;
	wire    [`FUNCT3_WIDTH - 1 : 0] 		rm;

	// module 2
	wire 	[`All_CTRL_WIDTH - 1 : 0]		allCtr;
	wire	[`IMM_SEL_WIDTH - 1 : 0]		immSel;
	wire	[`DECODE_STALL_WIDTH - 1 : 0]	stallFlag;
	wire	[`DECODE_FLUSH_WIDTH - 1 : 0]	flushFlag;	
	wire 	[`XLEN_WIDTH_SEL - 1 : 0]  		xlenSel;

	// module 3
	wire	[`DATA_WIDTH - 1 : 0] 			imm;


	InstrTypeDecode32 i_InstrTypeDecode32(
		.instr(instr32),
		.iEncode(iEncode),
		.rdAddr(rdAddr),
		.rs1Addr(rs1Addr),
		.rs2Addr(rs2Addr),
		.rs3Addr(rs3Addr),
		.csrAddr(csrAddr),
        .funct3(rm)
	);

	ControlDecode32 i_ControlDecode32(
		.iEncode(iEncode),
		.allCtr(allCtr),
		.immSel(immSel),
		.stallFlag(stallFlag),
		.flushFlag(flushFlag),
		.xlenSel(xlenSel),
		.unicorn(unicorn)
	);

	ImmGenMux32 i_ImmGenMux32
	(
		.io_inst(instr32),
		.io_sel(immSel),
		.io_out(imm)
	);

	//12
	assign	message32 = {
							rdAddr,
							rs1Addr,
							rs2Addr,
							rs3Addr,
							csrAddr,
							rm,
							allCtr,
							immSel,
							stallFlag,
							flushFlag,	
							xlenSel,
							imm
						};

	assign is32 = (xlenSel == `IS_32BIT) ? 1'b1 : 1'b0;

endmodule

module Decoder16 (
	input  [16 - 1 : 0]					instr16,
	output [`DECODER_OUT_WIDTH - 1 : 0]	message16,
	output                              unicorn,
	output 								is16
	
);

	// module 1
	wire	[`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode;// for all device control info need to be piped

	// module 2
	wire 	[`RF_ADDR_TYPE_SEL - 1 : 0]		rfSel;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		rdAddr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		rs1Addr;
	wire	[`RF_ADDR_WIDTH - 1 : 0]		rs2Addr;
	// wire	[`RF_ADDR_WIDTH - 1 : 0]		rs3Addr;
	// wire	[`CSR_ADDR_WIDTH - 1 : 0]		csrAddr;
	// wire    [`FUNCT3_WIDTH - 1 : 0] 		rm;

	// module 3
	wire 	[`All_CTRL_WIDTH - 1 : 0]		allCtr;
	wire	[`IMM_SEL_WIDTH - 1 : 0]		immSel;
	wire	[`DECODE_STALL_WIDTH - 1 : 0]	stallFlag;
	wire	[`DECODE_FLUSH_WIDTH - 1 : 0]	flushFlag;	
	wire 	[`XLEN_WIDTH_SEL - 1 : 0]  		xlenSel;

	// module 4
	wire	[`DATA_WIDTH - 1 : 0] 			imm;


	InstrTypeDecode16 i_InstrTypeDecode16(
		.instr(instr16),
		.iEncode(iEncode)
	);
	
	RFaddrMux16 i_RFaddrMux16(
		.instr(instr16),
		.iEncode(iEncode),
		.rfSel(rfSel),
		.rdAddr(rdAddr),
		.rs1Addr(rs1Addr),
		.rs2Addr(rs2Addr)	
	);
	
	ControlDecode16 i_ControlDecode16(
		.iEncode(iEncode),
		.allCtr(allCtr),
		.immSel(immSel),
		.rfSel(rfSel),
		.stallFlag(stallFlag),
		.flushFlag(flushFlag),
		.xlenSel(xlenSel),
		.unicorn(unicorn)
	);

	ImmGenMux16 i_ImmGenMux16
	(
		.instr(instr16),
		.iEncode(iEncode),
		.immSel(immSel),
		.imm(imm)
	);

	//collect 12 set signals
	assign	message16 = {
							rdAddr,
							rs1Addr,
							rs2Addr,
							{`RF_ADDR_WIDTH{1'b0}},
							{`CSR_ADDR_WIDTH{1'b0}},
							{`FUNCT3_WIDTH{1'b0}},
							allCtr,
							immSel,
							stallFlag,
							flushFlag,	
							xlenSel,
							imm
						};

	assign is16 = (xlenSel == `IS_16BIT) ? 1'b1 : 1'b0;
endmodule


module ImmGenMux16(
  input			[`INSTR_WIDTH_16 - 1 : 0]			instr,
  input			[`INSTR_ENCODE_WIDTH - 1 : 0]		iEncode,
  input 		[`IMM_SEL_WIDTH - 1 : 0]			immSel,
  output reg	[`DATA_WIDTH - 1 : 0] 				imm
);
	always @(*)
		case(immSel)
			`CI		:	
						case(iEncode)
							`C_ADDI16SP	:	imm = {{23{instr[12]}},instr[4:3],instr[5],instr[2],instr[6],{4{1'b0}}};
							`C_LUI		:	imm = {{15{instr[12]}},instr[6:2],{12{1'b0}}};
							default		:	imm = {{27{instr[12]}},instr[6:2]};
						endcase
			`CJ		:	imm = {{22{instr[12]}},instr[8],instr[10:9],instr[6],instr[7],instr[2],instr[11],instr[5:3],{1{1'b0}}};
			`CB		:	imm = {{24{instr[12]}},instr[6:5],instr[2],instr[11:10],instr[4:3],{1{1'b0}}};
			`CIW	:	imm = {{22{1'b0}},instr[10:7],instr[12:11],instr[5],instr[6],{2{1'b0}}};
			`CL 	:	imm = {{25{1'b0}},instr[5],instr[12:10],instr[6],{2{1'b0}}};
			`CSS 	:	
						case(iEncode)
							`C_LWSP		:	imm = {{24{1'b0}},instr[3:2],instr[12],instr[6:4],{2{1'b0}}};
							`C_SWSP		:	imm = {{24{1'b0}},instr[8:7],instr[12:9],{2{1'b0}}};
							default		:	imm = 32'b0;
						endcase
			default :	imm = 32'b0;
		endcase
endmodule

module RFaddrMux16(
  input			[`INSTR_WIDTH_16 - 1 : 0]			instr,
  input			[`INSTR_ENCODE_WIDTH - 1 : 0]		iEncode,
  input 		[`RF_ADDR_TYPE_SEL - 1 : 0]			rfSel,
  output reg	[`RF_ADDR_WIDTH - 1 : 0]			rdAddr,
  output reg	[`RF_ADDR_WIDTH - 1 : 0]			rs1Addr,
  output reg	[`RF_ADDR_WIDTH - 1 : 0]			rs2Addr	
);
	wire	[5 - 1 : 0]		Rs1Short;
	wire	[5 - 1 : 0]		Rs2Short;
	wire	[5 - 1 : 0]		RdShort;
	wire	[5 - 1 : 0]		Rs1Long;
	wire	[5 - 1 : 0]		Rs2Long;
	wire	[5 - 1 : 0]		RdLong;
	
	assign	Rs1Short = {2'b0,instr[9:7]} + 5'd8;
	assign	Rs2Short = {2'b0,instr[4:2]} + 5'd8;
	assign	RdShort  = {2'b0,instr[9:7]} + 5'd8;
	
	assign	Rs1Long  = instr[11:7];
	assign	Rs2Long  = instr[6:2];
	assign	RdLong   = instr[11:7];
	
	//rf sel
	always @(*)
		case(rfSel)
			`RF_SHORT	:	begin rs1Addr = Rs1Short; rs2Addr = Rs2Short; rdAddr = RdShort	; end
			`RF_LONG	:	begin rs1Addr = Rs1Long	; rs2Addr = Rs2Long	; rdAddr = RdLong	; end
			`RF_FIXED	:
							case(iEncode)
								`C_ADDI4SPN	: 	begin rs1Addr = 5'h2	; rs2Addr = 5'h0	; rdAddr = Rs2Short	; end
								`C_LW		: 	begin rs1Addr = Rs1Short; rs2Addr = 5'h0	; rdAddr = Rs2Short	; end
								`C_JAL		: 	begin rs1Addr = 5'h0	; rs2Addr = 5'h0	; rdAddr = 5'h1		; end
								`C_LI		: 	begin rs1Addr = 5'h0	; rs2Addr = 5'h0	; rdAddr = RdLong	; end
								`C_ADDI16SP	: 	begin rs1Addr = 5'h2	; rs2Addr = 5'h0	; rdAddr = 5'h2		; end
								`C_J		: 	begin rs1Addr = 5'h0	; rs2Addr = 5'h0	; rdAddr = 5'h0		; end
								`C_BEQZ		: 	begin rs1Addr = Rs1Short; rs2Addr = 5'h0	; rdAddr = 5'h0		; end
								`C_BNEZ		: 	begin rs1Addr = Rs1Short; rs2Addr = 5'h0	; rdAddr = 5'h0		; end
								`C_LWSP		: 	begin rs1Addr = 5'h2	; rs2Addr = 5'h0	; rdAddr = RdLong	; end
								`C_JR		: 	begin rs1Addr = Rs1Long	; rs2Addr = 5'h0	; rdAddr = 5'h0		; end
								`C_MV		: 	begin rs1Addr = 5'h0	; rs2Addr = Rs2Long	; rdAddr = RdLong	; end
								`C_JALR		: 	begin rs1Addr = Rs1Long	; rs2Addr = 5'h0	; rdAddr = 5'h1		; end
								`C_SWSP		: 	begin rs1Addr = 5'h2	; rs2Addr = Rs2Long	; rdAddr = 5'h0		; end
								default 	: 	begin rs1Addr = 5'h0	; rs2Addr = 5'h0	; rdAddr = 5'h0		; end
							endcase
			default 	: 	begin rs1Addr = 5'h0	; rs2Addr = 5'h0	; rdAddr = 5'h0		; end
		endcase
	
endmodule


module ControlDecode16(
	input		[`INSTR_ENCODE_WIDTH - 1 : 0]		iEncode,
	output 		[`All_CTRL_WIDTH - 1 : 0]			allCtr,
	output 		[`IMM_SEL_WIDTH - 1 : 0]			immSel,
	output 		[`RF_ADDR_TYPE_SEL - 1 : 0]			rfSel,
	output		[`DECODE_STALL_WIDTH - 1 : 0]		stallFlag,
	output		[`DECODE_FLUSH_WIDTH - 1 : 0]		flushFlag,
	output 		[`XLEN_WIDTH_SEL - 1 : 0]  			xlenSel,
	output                                          unicorn
);
	wire	[`A_SEL_WIDTH - 1 : 0 ]			A_sel;
	wire	[`B_SEL_WIDTH - 1 : 0 ]			B_sel;
	wire	[`ALU_OP_WIDTH - 1 : 0 ]		aluOp;
	wire	[`BR_TYPE_WIDTH - 1 : 0 ]		brType;
	wire	[`ST_TYPE_WIDTH - 1 : 0 ]		stType;
	wire	[`LD_TYPE_WIDTH - 1 : 0 ]		ldType;
	wire	[`WB_SEL_WIDTH - 1 : 0 ]		wbSel;
	wire	[`BOOL_WIDTH - 1 : 0 ]			wbRdEn;
	wire	[`CSR_CMD_WIDTH - 1 : 0 ]		csrCmd;
	wire	[`BOOL_WIDTH - 1 : 0 ]			illegal;

	reg		[`localAllCTRLWIDTH16  : 0 ]	localAllCtr;
	
	assign	{	A_sel,
				B_sel,
				immSel,
				aluOp,
				brType,
				stType,
				ldType,
				wbSel,
				wbRdEn,
				csrCmd,
				illegal,
				stallFlag,
				flushFlag,
				xlenSel,
				rfSel,
				unicorn
				} = localAllCtr;

	assign	allCtr = {
						A_sel,
						B_sel,
						aluOp,
						stType,
						ldType,
						wbSel,
						wbRdEn,
						csrCmd,
						illegal
						};
	
	always @(*)
		case(iEncode)
						//         		 			     1        1        3         5     	    3     	  2         3        1    wbRdEn   3  illegal
						//         		 			   A_sel    B_sel   imm_sel    aluOp   	  brType  	stType    ldType   wbSel    |  csrCmd   |	  stallFlag		  flushFlag       xlenSel	rfSel	    unicorn
						//         		 			     |        |        |         |     	    |     	   |         |       |      |     |     |		|			    |				|	      |		       |
				`C_ADDI4SPN			:	localAllCtr = {`A_RS1,  `B_IMM, `CIW, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				//`C_FLD      		:	localAllCtr = {`A_RS1,  `B_IMM, `CL	, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_LW , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_LW       		:	localAllCtr = {`A_RS1,  `B_IMM, `CL	, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_LW , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b1};
				//`C_FLW      		:	localAllCtr = {`A_RS1,  `B_IMM, `CL	, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_LW , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				//`C_FSD      		:	localAllCtr = {`A_RS1,  `B_IMM, `CL	, 	`ALU_ADD   	, `BR_XXX,	`ST_SW , `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_SW       		:	localAllCtr = {`A_RS1,  `B_IMM, `CL	, 	`ALU_ADD   	, `BR_XXX,	`ST_SW , `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b1};
				//`C_FSW      		:	localAllCtr = {`A_RS1,  `B_IMM, `CL	, 	`ALU_ADD   	, `BR_XXX,	`ST_SW , `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_NOP      		:	localAllCtr = {`A_XXX,  `B_XXX, `CXX, 	`ALU_XXX   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_XXX, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_XXX	,    1'b0};
				`C_ADDI     		:	localAllCtr = {`A_RS1,  `B_IMM, `CI	, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_LONG,    1'b0};
				`C_JAL      		:	localAllCtr = {`A_PC ,  `B_IMM, `CJ	, 	`ALU_JAL   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_LI       		:	localAllCtr = {`A_RS1,  `B_IMM, `CI , 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_ADDI16SP 		:	localAllCtr = {`A_RS1,  `B_IMM, `CI , 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_LUI      		:	localAllCtr = {`A_PC ,  `B_IMM, `CI , 	`ALU_COPY_B , `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_LONG,    1'b0};
				`C_SRLI     		:	localAllCtr = {`A_RS1,  `B_IMM, `CI , 	`ALU_SRL   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_SRAI     		:	localAllCtr = {`A_RS1,  `B_IMM, `CI , 	`ALU_SRA   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_ANDI     		:	localAllCtr = {`A_RS1,  `B_IMM, `CI , 	`ALU_AND    , `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_SUB      		:	localAllCtr = {`A_RS1,  `B_RS2, `CXX, 	`ALU_SUB   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_XOR      		:	localAllCtr = {`A_RS1,  `B_RS2, `CXX, 	`ALU_XOR   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_OR       		:	localAllCtr = {`A_RS1,  `B_RS2, `CXX, 	`ALU_OR   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_AND      		:	localAllCtr = {`A_RS1,  `B_RS2, `CXX, 	`ALU_AND   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_J        		:	localAllCtr = {`A_PC ,  `B_IMM, `CJ	, 	`ALU_JAL   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_BEQZ     		:	localAllCtr = {`A_PC ,  `B_IMM, `CB , 	`ALU_BEQ   	, `BR_EQ ,	`ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_BNEZ     		:	localAllCtr = {`A_PC ,  `B_IMM, `CB , 	`ALU_BNE   	, `BR_NE ,	`ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_SLLI     		:	localAllCtr = {`A_RS1,  `B_IMM, `CI , 	`ALU_SLL   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_LONG,    1'b0};
				//`C_FLDSP    		:	localAllCtr = {`A_RS1,  `B_IMM, `CL	, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_LW , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_SHORT,   1'b0};
				`C_LWSP     		:	localAllCtr = {`A_RS1,  `B_IMM, `CSS, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_LW , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b1};
				//`C_FLWSP    		:	localAllCtr = {`A_RS1,  `B_IMM, `CXX, 	`ALU_XXX   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_FENCE,	`FLUSH_XXX,		`IS_16BIT,	`RF_XXX	,    1'b0};
				`C_JR       		:	localAllCtr = {`A_RS1,  `B_IMM, `CXX, 	`ALU_JALR   , `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_MV       		:	localAllCtr = {`A_RS1,  `B_RS2, `CXX, 	`ALU_ADD    , `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_EBREAK   		:	localAllCtr = {`A_XXX,  `B_XXX, `CXX, 	`ALU_XXX	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_XXX	,    1'b0};
				`C_JALR     		:	localAllCtr = {`A_RS1,  `B_RS2, `CXX, 	`ALU_JALR   , `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b0};
				`C_ADD      		:	localAllCtr = {`A_RS1,  `B_RS2, `CXX, 	`ALU_ADD   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_LONG,    1'b0};
				//`C_FSDSP    		:	localAllCtr = {`A_RS1,  `B_IMM, `CXX, 	`ALU_CSR  	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_C, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_XXX	,    1'b0};
				`C_SWSP     		:	localAllCtr = {`A_RS1,  `B_IMM, `CSS, 	`ALU_ADD   	, `BR_XXX,	`ST_SW , `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_16BIT,	`RF_FIXED,   1'b1};
				//`C_FSWSP    		:	localAllCtr = {`A_RS1,  `B_IMM, `CXX, 	`ALU_XXX   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_P, `N,	`STALL_XXX,		`FLUSH_ERET,	`IS_16BIT,	`RF_XXX	,    1'b0};
				`C_RESERVED     	:	localAllCtr = {`A_XXX,  `B_XXX, `CXX, 	`ALU_XXX   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_XXX, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_XXBIT,	`RF_XXX	,    1'b0};
				default				:	localAllCtr = {`A_XXX,  `B_XXX, `CXX, 	`ALU_XXX   	, `BR_XXX,	`ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `Y,	`STALL_XXX,		`FLUSH_ILLEGAL,	`IS_XXBIT,	`RF_XXX	,    1'b0};
		endcase
endmodule

module InstrTypeDecode16(
	input		[`INSTR_WIDTH_16 - 1 : 0]		instr,
	output	reg [`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode
);
	//funct opcode
	wire	[`FUNCT3_WIDTH - 1 : 0] 			funct3;
	wire	[`FUNCT4_WIDTH - 1 : 0] 			funct4;
	wire 	[`OPCODE_WIDTH_16 - 1 : 0] 			opCode;

	//quadrant 1
	wire	[2 - 1 : 0]							q1Funct2_1;
	wire	[2 - 1 : 0]							q1Funct2_2;
	
	//funct opcode
	assign	funct3 		= instr[15:13];
	assign	funct4 		= instr[15:12];
	assign	opCode 		= instr[1:0];
	
	//quadrant 1
	assign	q1Funct2_1  = instr[11:10];
	assign	q1Funct2_2  = instr[6:5];
		
	//iEncode
	always @(*)
		case(opCode)
			`OP_00	:	
					case(funct3)
						`FUNCT3_0	:
										if(instr[12:2] == 11'b0) 
											iEncode = `C_UNKNOWN;
										else if (instr[12:5] == 8'b0) 
											iEncode = `C_RESERVED;
										else
											iEncode = `C_ADDI4SPN;
						`FUNCT3_1   :	iEncode = `C_FLD;
						`FUNCT3_2   :	iEncode = `C_LW;
						`FUNCT3_3   :	iEncode = `C_FLW;
						`FUNCT3_4   :	iEncode = `C_RESERVED;
						`FUNCT3_5   :	iEncode = `C_FSD;
						`FUNCT3_6   :	iEncode = `C_SW;
						`FUNCT3_7   :	iEncode = `C_FSW;
						default		:	iEncode = `UNKNOWN;
					endcase
			`OP_01	:
					case(funct3)
						`FUNCT3_0	:	
										if(instr[11:7] == 5'h0) 
											iEncode = `C_NOP;
										else
											iEncode = `C_ADDI;
						`FUNCT3_1	:	iEncode = `C_JAL;
						`FUNCT3_2   :	if(instr[11:7] == 5'h0)
											iEncode = `C_RESERVED;
										else
											iEncode = `C_LI;

						`FUNCT3_3   :
										if(instr[11:7] == 5'h2) 
											iEncode = `C_ADDI16SP;
										else if(instr[11:7] != 5'h0 && instr[11:7] != 5'h2)
											iEncode = `C_LUI;
										else
											iEncode = `C_RESERVED;
											
						`FUNCT3_4   :
										case(q1Funct2_1)
											`FUNCT2_0	:	iEncode = `C_SRLI;
											`FUNCT2_1   :	iEncode = `C_SRAI;
											`FUNCT2_2   :	iEncode = `C_ANDI;
											`FUNCT2_3   :	
															if (instr[12] == 0)
																case(q1Funct2_2)//not subw and addw
																	`FUNCT2_0	:	iEncode = `C_SUB;
																	`FUNCT2_1   :	iEncode = `C_XOR;
																	`FUNCT2_2   :	iEncode = `C_OR;
																	`FUNCT2_3   :	iEncode = `C_AND;
																	default		:	iEncode = `UNKNOWN;
																endcase
															else
																iEncode = `C_RESERVED;
											default		:	iEncode = `UNKNOWN;
										endcase
						`FUNCT3_5   :	iEncode = `C_J;
						`FUNCT3_6   :	iEncode = `C_BEQZ;
						`FUNCT3_7   :	iEncode = `C_BNEZ;
						default		:	iEncode = `UNKNOWN;
					endcase

			`OP_10	:	
						case(funct3)
							`FUNCT3_0	:	if(instr[11:7] == 5'h0)
												iEncode = `C_RESERVED;
											else
												iEncode = `C_SLLI;//c.slli and c.slli64
											
							`FUNCT3_1	:	iEncode = `C_FLDSP;
							`FUNCT3_2   :	if(instr[11:7] == 5'h0)
												iEncode = `C_RESERVED;
											else
												iEncode = `C_LWSP;
							`FUNCT3_3   :	iEncode = `C_FLWSP;//c.flwsp and c.ldsp
							`FUNCT3_4   :	if(instr[12] == 0)
												if(instr[11:7] != 5'h0 && instr[6:2] == 5'h0)
													iEncode = `C_JR;
												else if(instr[11:7] != 5'h0 && instr[6:2] != 5'h0)
													iEncode = `C_MV;
												else
													iEncode = `C_RESERVED;
											else
												if(instr[11:7] == 5'h0 && instr[6:2] == 5'h0)
													iEncode = `C_EBREAK;
												else if(instr[11:7] != 5'h0 && instr[6:2] == 5'h0)
													iEncode = `C_JALR;
												else if(instr[11:7] != 5'h0 && instr[6:2] != 5'h0)
													iEncode = `C_ADD;
												else
													iEncode = `C_RESERVED;
							`FUNCT3_5   :	iEncode = `C_FSDSP;//c.fsdsp and c.sqsp
							`FUNCT3_6   :	iEncode = `C_SWSP;
							`FUNCT3_7   :	iEncode = `C_FSWSP;//c.fswsp and c.sdsp
							default		:	iEncode = `UNKNOWN;
						endcase
			default	:	iEncode = `UNKNOWN;
		endcase
endmodule

module InstrTypeDecode32(
	input		[`INSTR_WIDTH/2 - 1 : 0]		instr,
	output	reg [`INSTR_ENCODE_WIDTH - 1 : 0]	iEncode,
	output	 	[`RF_ADDR_WIDTH - 1 : 0]		rdAddr,
	output	 	[`RF_ADDR_WIDTH - 1 : 0]		rs1Addr,
	output	 	[`RF_ADDR_WIDTH - 1 : 0]		rs2Addr,
	output	 	[`RF_ADDR_WIDTH - 1 : 0]		rs3Addr,
	output	 	[`CSR_ADDR_WIDTH - 1 : 0]		csrAddr,
    output	    [`FUNCT3_WIDTH - 1 : 0] 		funct3
);
	wire	[`FUNCT7_WIDTH - 1 : 0] 		funct7;
	wire 	[`OPCODE_WIDTH - 1 : 0] 		opCode;

	assign	{funct7,rs2Addr,rs1Addr,funct3,rdAddr,opCode} = instr;
	assign	csrAddr = {funct7,rs2Addr};
	assign  rs3Addr = funct7[6 : 2];

	always @(*)
		case(opCode)
			`OP_LUI		:	iEncode = `LUI;
			`OP_AUIPC	:	iEncode = `AUIPC;
			`OP_JAL		:   iEncode = `JAL;
			`OP_JALR	:	iEncode = `JALR;
			`OP_BRANCH	:   
							case(funct3)
								`FUNCT3_0	:	iEncode = `BEQ;
								`FUNCT3_1   :	iEncode = `BNE;
								`FUNCT3_4   :	iEncode = `BLT;
								`FUNCT3_5   :	iEncode = `BGE;
								`FUNCT3_6   :	iEncode = `BLTU;
							    `FUNCT3_7   :	iEncode = `BGEU;
								default		:	iEncode = `UNKNOWN;
							endcase
			`OP_LOAD	:	
							case(funct3)
								`FUNCT3_0	:	iEncode = `LB;
								`FUNCT3_1   :	iEncode = `LH;
								`FUNCT3_2   :	iEncode = `LW;
								`FUNCT3_4   :	iEncode = `LBU;
								`FUNCT3_5   :	iEncode = `LHU;
								default		:	iEncode = `UNKNOWN;
							endcase
			`OP_STORE	: 
							case(funct3)
								`FUNCT3_0	:	iEncode = `SB;
								`FUNCT3_1   :	iEncode = `SH;
								`FUNCT3_2   :	iEncode = `SW;
								default		:	iEncode = `UNKNOWN;
							endcase
			`OP_IMM_ALU	:
							case(funct3)
								`FUNCT3_0	:	iEncode = `ADDI;//NOP
								`FUNCT3_2   :	iEncode = `SLTI;
								`FUNCT3_3   :	iEncode = `SLTIU;
								`FUNCT3_4	:	iEncode = `XORI;
								`FUNCT3_6   :	iEncode = `ORI;
								`FUNCT3_7   :	iEncode = `ANDI;
								`FUNCT3_1	:	iEncode = `SLLI;
								`FUNCT3_5   :	
												case(funct7)
													`FUNCT7_0	:	iEncode = `SRLI;
													`FUNCT7_5   :	iEncode = `SRAI;
													default     :	iEncode = `UNKNOWN;
												endcase
								default		:	iEncode = `UNKNOWN;
							endcase
			`OP_R_ALU	:
							case(funct7)
								`FUNCT7_0	:	
												case(funct3)
													`FUNCT3_0	:	iEncode = `ADD;
													`FUNCT3_1   :	iEncode = `SLL;
													`FUNCT3_2   :	iEncode = `SLT;
													`FUNCT3_3   :	iEncode = `SLTU;
													`FUNCT3_4   :	iEncode = `XOR;
													`FUNCT3_5   :	iEncode = `SRL;
													`FUNCT3_6   :	iEncode = `OR;
													`FUNCT3_7   :	iEncode = `AND;
													default     :	iEncode = `UNKNOWN;
												endcase	
								`FUNCT7_1	:	
												case(funct3)
													`FUNCT3_0	:	iEncode = `MUL;
													`FUNCT3_1   :	iEncode = `MULH;
													`FUNCT3_2   :	iEncode = `MULHSU;
													`FUNCT3_3   :	iEncode = `MULHU;
													`FUNCT3_4   :	iEncode = `DIV; 
													`FUNCT3_5   :	iEncode = `DIVU;
													`FUNCT3_6   :	iEncode = `REM;  
													`FUNCT3_7   :	iEncode = `REMU; 
													default     :	iEncode = `UNKNOWN;
												endcase	
								`FUNCT7_5	:	
												case(funct3)
													`FUNCT3_0	:	iEncode = `SUB;
													`FUNCT3_5   :	iEncode = `SRA;
													default     :	iEncode = `UNKNOWN;
												endcase	
								default     :	iEncode = `UNKNOWN;
							endcase
			`OP_FENCE	:   
							case(funct3)
								`FUNCT3_0	:	iEncode = `FENCE;
					        	`FUNCT3_1   :	iEncode = `FENCEI;
			                	default     :	iEncode = `UNKNOWN;
			                endcase									
			`OP_CSR		:   
							case(funct3)
								`FUNCT3_0	:
												case(csrAddr)
											    	`IMM_ECALL	:	iEncode = `ECALL;
											    	`IMM_EBREAK :	iEncode = `EBREAK;
													`IMM_MRET  :	iEncode = `ERET;
											    	`IMM_WFI   :	iEncode = `WFI;
													default     :	iEncode = `UNKNOWN;
											    endcase									
					        	`FUNCT3_1   :	iEncode = `CSRRW;
								`FUNCT3_2   :	iEncode = `CSRRS;
								`FUNCT3_3   :	iEncode = `CSRRC;
								`FUNCT3_5   :	iEncode = `CSRRWI;
								`FUNCT3_6   :	iEncode = `CSRRSI;
								`FUNCT3_7   :	iEncode = `CSRRCI;
			                	default     :	iEncode = `UNKNOWN;
			                endcase
			`OP_FDLD	:   
							case(funct3)
					        	`FUNCT3_2   :	iEncode = `FLW;
								`FUNCT3_3   :	iEncode = `FLD;								
			                	default     :	iEncode = `UNKNOWN;
			                endcase
            `OP_FDST    :   
							case(funct3)
					        	`FUNCT3_2   :	iEncode = `FSW;
								`FUNCT3_3   :	iEncode = `FSD;								
			                	default     :	iEncode = `UNKNOWN;
			                endcase
            `OP_FDMADD  :   
							case(funct7[1:0])
					        	2'b00      :	iEncode = `FMADD_S;
								2'b01      :	iEncode = `FMADD_D;								
			                	default    :	iEncode = `UNKNOWN;
			                endcase
            `OP_FDMSUB  :   
							case(funct7[1:0])
					        	2'b00      :	iEncode = `FMSUB_S;
								2'b01      :	iEncode = `FMSUB_D;								
			                	default    :	iEncode = `UNKNOWN;
			                endcase
            `OP_FDNMSUB :   
							case(funct7[1:0])
					        	2'b00      :	iEncode = `FNMSUB_S;
								2'b01      :	iEncode = `FNMSUB_D;								
			                	default    :	iEncode = `UNKNOWN;
			                endcase
            `OP_FDNMADD :   
							case(funct7[1:0])
					        	2'b00      :	iEncode = `FNMADD_S;
								2'b01      :	iEncode = `FNMADD_D;								
			                	default    :	iEncode = `UNKNOWN;
			                endcase
            `OP_FD      :   
							case(funct7)
                                //float
					        	7'b000_0000 :	iEncode = `FADD_S;
                                7'b000_0100 :	iEncode = `FSUB_S;
                                7'b000_1000 :	iEncode = `FMUL_S;
                                7'b000_1100 :	iEncode = `FDIV_S;
                                7'b010_1100 :	iEncode = `FSQRT_S;
                                7'b001_0000 :	
												case(funct3)
											    	`FUNCT3_0   :	iEncode = `FSGNJ_S;
                                                    `FUNCT3_1   :	iEncode = `FSGNJN_S;
                                                    `FUNCT3_2   :	iEncode = `FSGNJX_S;
													default     :	iEncode = `UNKNOWN;
											    endcase	
                                7'b001_0100 :	
												case(funct3)
											    	`FUNCT3_0   :	iEncode = `FMIN_S;
                                                    `FUNCT3_1   :	iEncode = `FMAX_S;
													default     :	iEncode = `UNKNOWN;
											    endcase	
					        	7'b110_0000 :	
												case(rs2Addr)
											    	5'd0        :	iEncode = `FCVT_WS;
                                                    5'd1        :	iEncode = `FCVT_WUS;
													default     :	iEncode = `UNKNOWN;
											    endcase	
                                7'b111_0000 :	
												case(funct3)
											    	`FUNCT3_0   :	iEncode = `FMV_XW;
                                                    `FUNCT3_1   :	iEncode = `FCLASS_S;
													default     :	iEncode = `UNKNOWN;
											    endcase
                                7'b101_0000 :	
												case(funct3)
											    	`FUNCT3_0   :	iEncode = `FLE_S;
                                                    `FUNCT3_1   :	iEncode = `FLT_S;
                                                    `FUNCT3_2   :	iEncode = `FEQ_S;
													default     :	iEncode = `UNKNOWN;
											    endcase
                                7'b110_1000 :	
												case(rs2Addr)
											    	5'd0        :	iEncode = `FCVT_SW;
                                                    5'd1        :	iEncode = `FCVT_SWU;
													default     :	iEncode = `UNKNOWN;
											    endcase	
                                7'b111_1000 :	iEncode = `FMV_WX;
                                //double
					        	7'b000_0001 :	iEncode = `FADD_D;
                                7'b000_0101 :	iEncode = `FSUB_D;
                                7'b000_1001 :	iEncode = `FMUL_D;
                                7'b000_1101 :	iEncode = `FDIV_D;
                                7'b010_1101 :	iEncode = `FSQRT_D;
                                7'b001_0001 :	
												case(funct3)
											    	`FUNCT3_0   :	iEncode = `FSGNJ_D;
                                                    `FUNCT3_1   :	iEncode = `FSGNJN_D;
                                                    `FUNCT3_2   :	iEncode = `FSGNJX_D;
													default     :	iEncode = `UNKNOWN;
											    endcase	
                                7'b001_0101 :	
												case(funct3)
											    	`FUNCT3_0   :	iEncode = `FMIN_D;
                                                    `FUNCT3_1   :	iEncode = `FMAX_D;
													default     :	iEncode = `UNKNOWN;
											    endcase	
					        	7'b010_0000 :   iEncode = `FCVT_SD;
					        	7'b010_0001 :   iEncode = `FCVT_DS;
					        	7'b101_0001 :	
												case(funct3)
											    	`FUNCT3_0   :	iEncode = `FLE_D;
                                                    `FUNCT3_1   :	iEncode = `FLT_D;
                                                    `FUNCT3_2   :	iEncode = `FEQ_D;
													default     :	iEncode = `UNKNOWN;
											    endcase
					        	7'b111_0001 :   iEncode = `FCLASS_D;
					        	7'b110_0001 :	
												case(rs2Addr)
											    	5'd0        :	iEncode = `FCVT_WD;
                                                    5'd1        :	iEncode = `FCVT_WUD;
													default     :	iEncode = `UNKNOWN;
											    endcase	
					        	7'b110_1001 :	
												case(rs2Addr)
											    	5'd0        :	iEncode = `FCVT_DW;
                                                    5'd1        :	iEncode = `FCVT_DWU;
													default     :	iEncode = `UNKNOWN;
											    endcase						
			                	default     :	iEncode = `UNKNOWN;
			                endcase
			`OP_ZERO	:   iEncode = `UNKNOWN;
			default		:	iEncode = `UNKNOWN;
		endcase
endmodule


module ControlDecode32(
	input		[`INSTR_ENCODE_WIDTH - 1 : 0]		iEncode,
	output 		[`All_CTRL_WIDTH - 1 : 0]			allCtr,
	output 		[`IMM_SEL_WIDTH - 1 : 0]			immSel,
	output		[`DECODE_STALL_WIDTH - 1 : 0]		stallFlag,
	output		[`DECODE_FLUSH_WIDTH - 1 : 0]		flushFlag,
	output		[`XLEN_WIDTH_SEL - 1 : 0]  			xlenSel,
	output 											unicorn
);
	wire	[`PC_SEL_WIDTH - 1 : 0 ]		pcSel;
	wire	[`A_SEL_WIDTH - 1 : 0 ]			A_sel;
	wire	[`B_SEL_WIDTH - 1 : 0 ]			B_sel;
	wire	[`ALU_OP_WIDTH - 1 : 0 ]		aluOp;
	wire	[`BR_TYPE_WIDTH - 1 : 0 ]		brType;
	wire	[`BOOL_WIDTH - 1 : 0 ]			kill;
	wire	[`ST_TYPE_WIDTH - 1 : 0 ]		stType;
	wire	[`LD_TYPE_WIDTH - 1 : 0 ]		ldType;
	wire	[`WB_SEL_WIDTH - 1 : 0 ]		wbSel;
	wire	[`BOOL_WIDTH - 1 : 0 ]			wbRdEn;
	wire	[`CSR_CMD_WIDTH - 1 : 0 ]		csrCmd;
	wire	[`BOOL_WIDTH - 1 : 0 ]			illegal;

	reg		[`localAllCTRLWIDTH32  : 0 ]	localAllCtr;
	
	assign	{	pcSel,
				A_sel,
				B_sel,
				immSel,
				aluOp,
				brType,
				kill,
				stType,
				ldType,
				wbSel,
				wbRdEn,
				csrCmd,
				illegal,
				stallFlag,
				flushFlag,
				xlenSel,
				unicorn
				} = localAllCtr;

	assign	allCtr = {	
						A_sel,
						B_sel,
						aluOp,
						stType,
						ldType,
						wbSel,
						wbRdEn,
						csrCmd,
						illegal
						};
	
	always @(*)
		case(iEncode)
						//         		     2  	    1        1        3         5      	    3     kill   2         3        1    wbRdEn   3  illegal
						//         		   pcSel 	  A_sel    B_sel   imm_sel    aluOp    	  brType    |  stType    ldType   wbSel    |  csrCmd   |	  stallFlag		  flushFlag       xlenSel	unicorn
						//         		     |   	    |        |        |         |      	    |       |     |         |       |      |     |     |		|			    |				|			|	
				`LUI      :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_U, `ALU_COPY_B	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`AUIPC    :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_U, `ALU_ADD   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`JAL      :	localAllCtr = {`PC_ALU	, `A_PC,   `B_IMM, `IMM_J, `ALU_JAL   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`JALR     :	localAllCtr = {`PC_ALU	, `A_RS1,  `B_IMM, `IMM_I, `ALU_JALR   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`BEQ      :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_B, `ALU_BEQ   	, `BR_EQ , `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`BNE      :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_B, `ALU_BNE   	, `BR_NE , `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`BLT      :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_B, `ALU_BLT   	, `BR_LT , `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`BGE      :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_B, `ALU_BGE   	, `BR_GE , `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`BLTU     :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_B, `ALU_BLTU   	, `BR_LTU, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`BGEU     :	localAllCtr = {`PC_4  	, `A_PC,   `B_IMM, `IMM_B, `ALU_BGEU   	, `BR_GEU, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`LB       :	localAllCtr = {`PC_0  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_ADD   	, `BR_XXX, `Y, `ST_XXX, `LD_LB , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`LH       :	localAllCtr = {`PC_0  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_ADD   	, `BR_XXX, `Y, `ST_XXX, `LD_LH , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`LW       :	localAllCtr = {`PC_0  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_ADD   	, `BR_XXX, `Y, `ST_XXX, `LD_LW , `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`LBU      :	localAllCtr = {`PC_0  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_ADD   	, `BR_XXX, `Y, `ST_XXX, `LD_LBU, `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`LHU      :	localAllCtr = {`PC_0  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_ADD   	, `BR_XXX, `Y, `ST_XXX, `LD_LHU, `WB_MEM, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`SB       :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_S, `ALU_ADD   	, `BR_XXX, `N, `ST_SB , `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`SH       :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_S, `ALU_ADD   	, `BR_XXX, `N, `ST_SH , `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`SW       :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_S, `ALU_ADD   	, `BR_XXX, `N, `ST_SW , `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`ADDI     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_ADD   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SLTI     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_SLT   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SLTIU    :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_SLTU  	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`XORI     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_XOR   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`ORI      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_OR    	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`ANDI     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_AND   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SLLI     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_SLL   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SRLI     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_SRL   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SRAI     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_SRA   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`ADD      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_ADD   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SUB      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_SUB   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SLL      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_SLL   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SLT      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_SLT   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SLTU     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_SLTU  	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`XOR      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XOR   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SRL      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_SRL   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`SRA      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_SRA   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`OR       :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_OR    	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`AND      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_AND   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`MUL      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_MUL   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`MULH     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_MULH   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`MULHSU   :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_MULHSU  , `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`MULHU    :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_MULHU   , `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`DIV      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_DIV   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`DIVU     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_DIVU   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`REM      :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_REM   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`REMU     :	localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_REMU   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_N, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b0};
				`FENCE    :	localAllCtr = {`PC_4  	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_FENCE,	`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`FENCEI   :	localAllCtr = {`PC_0  	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_FENCE,	`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`CSRRW    :	localAllCtr = {`PC_0  	, `A_RS1,  `B_XXX, `IMM_X, `ALU_CSR   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_W, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`CSRRS    :	localAllCtr = {`PC_0  	, `A_RS1,  `B_XXX, `IMM_X, `ALU_CSR   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_S, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`CSRRC    :	localAllCtr = {`PC_0  	, `A_RS1,  `B_XXX, `IMM_X, `ALU_CSR		, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_C, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`CSRRWI   :	localAllCtr = {`PC_0  	, `A_XXX,  `B_XXX, `IMM_Z, `ALU_CSR   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_W, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`CSRRSI   :	localAllCtr = {`PC_0  	, `A_XXX,  `B_XXX, `IMM_Z, `ALU_CSR   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_S, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`CSRRCI   :	localAllCtr = {`PC_0  	, `A_XXX,  `B_XXX, `IMM_Z, `ALU_CSR  	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `Y, `CSR_C, `N,	`STALL_XXX,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`ECALL    :	localAllCtr = {`PC_4  	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_P, `N,	`STALL_XXX,		`FLUSH_ECALL,	`IS_32BIT,    1'b1};
				`EBREAK   :	localAllCtr = {`PC_4  	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_P, `N,	`STALL_XXX,		`FLUSH_EBREAK,	`IS_32BIT,    1'b1};
				`ERET     :	localAllCtr = {`PC_CTRL	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `Y, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_P, `N,	`STALL_XXX,		`FLUSH_ERET,	`IS_32BIT,    1'b1};
				`WFI      :	localAllCtr = {`PC_4  	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_WFI,		`FLUSH_XXX,		`IS_32BIT,    1'b1};
				`NOP      :	localAllCtr = {`PC_4  	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                
                `FLW      : localAllCtr = {`PC_0  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSW      : localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_S, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMADD_S  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMSUB_S  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FNMSUB_S : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FNMADD_S : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FADD_S   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSUB_S   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMUL_S   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FDIV_S   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSQRT_S  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSGNJ_S  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSGNJN_S : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSGNJX_S : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMIN_S   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMAX_S   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_WS  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_WUS : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMV_XW   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FEQ_S    : localAllCtr = {`PC_4  	, `A_PC ,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FLT_S    : localAllCtr = {`PC_4  	, `A_PC ,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FLE_S    : localAllCtr = {`PC_4  	, `A_PC ,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCLASS_S : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_SW  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_SWU : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMV_WX   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FLD      : localAllCtr = {`PC_0  	, `A_RS1,  `B_IMM, `IMM_I, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSD      : localAllCtr = {`PC_4  	, `A_RS1,  `B_IMM, `IMM_S, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMADD_D  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMSUB_D  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FNMSUB_D : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FNMADD_D : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FADD_D   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSUB_D   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMUL_D   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FDIV_D   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSQRT_D  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSGNJ_D  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSGNJN_D : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FSGNJX_D : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMIN_D   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FMAX_D   : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_SD  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_DS  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FEQ_D    : localAllCtr = {`PC_4  	, `A_PC ,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FLT_D    : localAllCtr = {`PC_4  	, `A_PC ,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FLE_D    : localAllCtr = {`PC_4  	, `A_PC ,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCLASS_D : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_WD  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_WUD : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_DW  : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
                `FCVT_DWU : localAllCtr = {`PC_4  	, `A_RS1,  `B_RS2, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `N,	`STALL_XXX,		`STALL_XXX,		`IS_32BIT,    1'b0};
				default:	localAllCtr = {`PC_4  	, `A_XXX,  `B_XXX, `IMM_X, `ALU_XXX   	, `BR_XXX, `N, `ST_XXX, `LD_XXX, `WB_ALU, `N, `CSR_N, `Y,	`STALL_XXX,		`FLUSH_ILLEGAL,	`IS_XXBIT,    1'b0};
		endcase
endmodule

module ImmGenMux32(
  input      [31:0] io_inst,
  input      [2:0]  io_sel,
  output reg [31:0] io_out
);
	always @(*)
		case(io_sel)
			`IMM_I	:	io_out = {{21{io_inst[31]}},io_inst[30:20]};
			`IMM_S	:	io_out = {{21{io_inst[31]}},io_inst[30:25],io_inst[11:7]};
			`IMM_U	:	io_out = {io_inst[31:12],{12{1'b0}}};
			`IMM_J 	:	io_out = {{12{io_inst[31]}},io_inst[19:12],io_inst[20],io_inst[30:25],io_inst[24:21],{1'b0}};
            `IMM_B  :   io_out = {{21{io_inst[31]}},io_inst[7],io_inst[30:25],io_inst[11:8],{1'b0}};
            `IMM_Z  :   io_out = {{27{1'b0}},io_inst[19:15]};
			default :	io_out = 32'b0;
		endcase
endmodule

// module ImmGenMux32(
//   input  [31:0] io_inst,
//   input  [2:0]  io_sel,
//   output [31:0] io_out
// );
//   wire  _T_100; // @[ImmGen.scala 33:25]
//   wire  _T_102; // @[ImmGen.scala 33:48]
//   wire  _T_103; // @[ImmGen.scala 33:53]
//   wire  sign; // @[ImmGen.scala 33:17]
//   wire  _T_104; // @[ImmGen.scala 34:27]
//   wire [10:0] _T_105; // @[ImmGen.scala 34:45]
//   wire [10:0] _T_106; // @[ImmGen.scala 34:53]
//   wire [10:0] b30_20; // @[ImmGen.scala 34:19]
//   wire  _T_107; // @[ImmGen.scala 35:27]
//   wire  _T_108; // @[ImmGen.scala 35:47]
//   wire  _T_109; // @[ImmGen.scala 35:37]
//   wire [7:0] _T_110; // @[ImmGen.scala 35:71]
//   wire [7:0] _T_111; // @[ImmGen.scala 35:79]
//   wire [7:0] b19_12; // @[ImmGen.scala 35:19]
//   wire  _T_114; // @[ImmGen.scala 36:34]
//   wire  _T_116; // @[ImmGen.scala 37:24]
//   wire  _T_117; // @[ImmGen.scala 37:42]
//   wire  _T_118; // @[ImmGen.scala 37:47]
//   wire  _T_119; // @[ImmGen.scala 38:24]
//   wire  _T_120; // @[ImmGen.scala 38:42]
//   wire  _T_121; // @[ImmGen.scala 38:46]
//   wire  _T_122; // @[ImmGen.scala 38:16]
//   wire  _T_123; // @[ImmGen.scala 37:16]
//   wire  b11; // @[ImmGen.scala 36:16]
//   wire [5:0] _T_128; // @[ImmGen.scala 39:69]
//   wire [5:0] b10_5; // @[ImmGen.scala 39:18]
//   wire  _T_131; // @[ImmGen.scala 41:25]
//   wire  _T_133; // @[ImmGen.scala 41:35]
//   wire [3:0] _T_134; // @[ImmGen.scala 41:63]
//   wire [3:0] _T_136; // @[ImmGen.scala 42:43]
//   wire [3:0] _T_137; // @[ImmGen.scala 42:59]
//   wire [3:0] _T_138; // @[ImmGen.scala 42:17]
//   wire [3:0] _T_139; // @[ImmGen.scala 41:17]
//   wire [3:0] b4_1; // @[ImmGen.scala 40:17]
//   wire  _T_142; // @[ImmGen.scala 44:23]
//   wire  _T_145; // @[ImmGen.scala 45:41]
//   wire  _T_147; // @[ImmGen.scala 45:15]
//   wire  _T_148; // @[ImmGen.scala 44:15]
//   wire  b0; // @[ImmGen.scala 43:15]
//   wire [9:0] _T_149; // @[Cat.scala 30:58]
//   wire [10:0] _T_150; // @[Cat.scala 30:58]
//   wire  _T_151; // @[Cat.scala 30:58]
//   wire [7:0] _T_152; // @[Cat.scala 30:58]
//   wire [8:0] _T_153; // @[Cat.scala 30:58]
//   wire [10:0] _T_154; // @[Cat.scala 30:58]
//   wire  _T_155; // @[Cat.scala 30:58]
//   wire [11:0] _T_156; // @[Cat.scala 30:58]
//   wire [20:0] _T_157; // @[Cat.scala 30:58]
//   wire [31:0] _T_158; // @[Cat.scala 30:58]
//   wire [31:0] _T_159; // @[ImmGen.scala 47:61]
//   wire [31:0] _T_160; // @[ImmGen.scala 47:68]
//   assign _T_100 = io_sel == 3'h6; // @[ImmGen.scala 33:25]
//   assign _T_102 = io_inst[31]; // @[ImmGen.scala 33:48]
//   assign _T_103 = $signed(_T_102); // @[ImmGen.scala 33:53]
//   assign sign = _T_100 ? $signed(1'sh0) : $signed(_T_103); // @[ImmGen.scala 33:17]
//   assign _T_104 = io_sel == 3'h3; // @[ImmGen.scala 34:27]
//   assign _T_105 = io_inst[30:20]; // @[ImmGen.scala 34:45]
//   assign _T_106 = $signed(_T_105); // @[ImmGen.scala 34:53]
//   assign b30_20 = _T_104 ? $signed(_T_106) : $signed({11{sign}}); // @[ImmGen.scala 34:19]
//   assign _T_107 = io_sel != 3'h3; // @[ImmGen.scala 35:27]
//   assign _T_108 = io_sel != 3'h4; // @[ImmGen.scala 35:47]
//   assign _T_109 = _T_107 & _T_108; // @[ImmGen.scala 35:37]
//   assign _T_110 = io_inst[19:12]; // @[ImmGen.scala 35:71]
//   assign _T_111 = $signed(_T_110); // @[ImmGen.scala 35:79]
//   assign b19_12 = _T_109 ? $signed({8{sign}}) : $signed(_T_111); // @[ImmGen.scala 35:19]
//   assign _T_114 = _T_104 | _T_100; // @[ImmGen.scala 36:34]
//   assign _T_116 = io_sel == 3'h4; // @[ImmGen.scala 37:24]
//   assign _T_117 = io_inst[20]; // @[ImmGen.scala 37:42]
//   assign _T_118 = $signed(_T_117); // @[ImmGen.scala 37:47]
//   assign _T_119 = io_sel == 3'h5; // @[ImmGen.scala 38:24]
//   assign _T_120 = io_inst[7]; // @[ImmGen.scala 38:42]
//   assign _T_121 = $signed(_T_120); // @[ImmGen.scala 38:46]
//   assign _T_122 = _T_119 ? $signed(_T_121) : $signed(sign); // @[ImmGen.scala 38:16]
//   assign _T_123 = _T_116 ? $signed(_T_118) : $signed(_T_122); // @[ImmGen.scala 37:16]
//   assign b11 = _T_114 ? $signed(1'sh0) : $signed(_T_123); // @[ImmGen.scala 36:16]
//   assign _T_128 = io_inst[30:25]; // @[ImmGen.scala 39:69]
//   assign b10_5 = _T_114 ? 6'h0 : _T_128; // @[ImmGen.scala 39:18]
//   assign _T_131 = io_sel == 3'h2; // @[ImmGen.scala 41:25]
//   assign _T_133 = _T_131 | _T_119; // @[ImmGen.scala 41:35]
//   assign _T_134 = io_inst[11:8]; // @[ImmGen.scala 41:63]
//   assign _T_136 = io_inst[19:16]; // @[ImmGen.scala 42:43]
//   assign _T_137 = io_inst[24:21]; // @[ImmGen.scala 42:59]
//   assign _T_138 = _T_100 ? _T_136 : _T_137; // @[ImmGen.scala 42:17]
//   assign _T_139 = _T_133 ? _T_134 : _T_138; // @[ImmGen.scala 41:17]
//   assign b4_1 = _T_104 ? 4'h0 : _T_139; // @[ImmGen.scala 40:17]
//   assign _T_142 = io_sel == 3'h1; // @[ImmGen.scala 44:23]
//   assign _T_145 = io_inst[15]; // @[ImmGen.scala 45:41]
//   assign _T_147 = _T_100 ? _T_145 : 1'h0; // @[ImmGen.scala 45:15]
//   assign _T_148 = _T_142 ? _T_117 : _T_147; // @[ImmGen.scala 44:15]
//   assign b0 = _T_131 ? _T_120 : _T_148; // @[ImmGen.scala 43:15]
//   assign _T_149 = {b10_5,b4_1}; // @[Cat.scala 30:58]
//   assign _T_150 = {_T_149,b0}; // @[Cat.scala 30:58]
//   assign _T_151 = $unsigned(b11); // @[Cat.scala 30:58]
//   assign _T_152 = $unsigned(b19_12); // @[Cat.scala 30:58]
//   assign _T_153 = {_T_152,_T_151}; // @[Cat.scala 30:58]
//   assign _T_154 = $unsigned(b30_20); // @[Cat.scala 30:58]
//   assign _T_155 = $unsigned(sign); // @[Cat.scala 30:58]
//   assign _T_156 = {_T_155,_T_154}; // @[Cat.scala 30:58]
//   assign _T_157 = {_T_156,_T_153}; // @[Cat.scala 30:58]
//   assign _T_158 = {_T_157,_T_150}; // @[Cat.scala 30:58]
//   assign _T_159 = $signed(_T_158); // @[ImmGen.scala 47:61]
//   assign _T_160 = $unsigned(_T_159); // @[ImmGen.scala 47:68]
//   assign io_out = _T_160;
// endmodule