`include "../src/common/Define.v"
module TbSingleModule;
reg clk;
reg rst_n;
initial begin : clk_
	clk = 1'b0;
	rst_n = 1'b0;
	# 1
	rst_n = 1'b1;
end

always #2 clk = ~clk;

initial begin : stop_
	# 1200
	$finish;
end

	wire	[`ADDR_WIDTH - 1 : 0]			Fetch_NextPC;

	wire	[`ADDR_WIDTH - 1 : 0]			IFID_NowPC;
	wire	[`INSTR_WIDTH - 1 : 0]			IFID_Instr;

	wire	[`ADDR_WIDTH - 1 : 0]			IFID_NowPC_0;
	wire	[`ADDR_WIDTH - 1 : 0]			IFID_NowPC_1;

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

	wire 	[`PC_PLUS_WIDTH - 1 : 0]		Decode_NextPC;

	Fetch i_Fetch(
		//.clk(clk),
		//.rst_n(rst_n),
		//.Stall(1'b0),//need to edit control
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
		.in( {Fetch_NextPC , 64'h57c157c1_00000013} ),
		.out( {IFID_NowPC , IFID_Instr} )
	);



	Decode i_Decode(
		// .IFID_Instr(64'h00000013_00000013), // 32/32
		// .IFID_Instr(64'h57c157c1_00000013), // 16/16/32
		// .IFID_Instr(64'h57c157c1_57c157c1), // 16/16/16/16
		// .IFID_Instr(64'h00000013_57c157c1), // 32/16/16
		// .IFID_Instr(64'h57c10000_001357c1), // 16/32/16
		.IFID_Instr(IFID_Instr),
		.IFID_NowPC_0(32'h0000_0000),
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
		.Decode_NextPC(Decode_NextPC)
	);

	always @(posedge clk) begin : test_
		$display("---------------------------------------------");
		$display("i_Decode.instrForm = %b", i_Decode.instrForm);
		$display("i_Decode.Decode_NextPC = %d", i_Decode.Decode_NextPC);
		$display("i_Decode.IFID_NowPC_0 = %h", i_Decode.IFID_NowPC_0);
		$display("i_Decode.IFID_NowPC_1 = %h", i_Decode.IFID_NowPC_1);
	end
endmodule