`include "../common/Define.v"
module BranchPredictor(
    input  [`INSTR_WIDTH - 1:0] Icache_Instr,
    input  [`ADDR_WIDTH - 1:0]  Fetch_NextPC,
    output [`ADDR_WIDTH - 1:0]  BranchPredictor_PC,
    output                      BP_BranchFlag
);

wire       [`OPCODE_WIDTH - 1:0] OpCode;
wire       [`ADDR_WIDTH - 1:0]   imm;
wire                             must_jump;
wire                             is_branch;

assign OpCode = Icache_Instr[`OPCODE_WIDTH - 1:0];
assign imm = (OpCode == `OP_BRANCH) ? {{20{Icache_Instr[31]}}, Icache_Instr[7], 
                                       Icache_Instr[30:25], Icache_Instr[11:8], 1'b0} :
             (OpCode == `OP_JAL) ? {{12{Icache_Instr[31]}}, Icache_Instr[19:12],
                                    Icache_Instr[20], Icache_Instr[30:21], 1'b0} : 0;
assign must_jump = (OpCode == `OP_JAL);
assign is_branch = OpCode == `OP_BRANCH;
assign BP_BranchFlag = must_jump || (is_branch && imm[31]) && |imm;
assign BranchPredictor_PC = Fetch_NextPC + imm;

endmodule