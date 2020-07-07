/*
 * @Date:   2019-10-28 8:39
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-28 8:39
 */
 
`timescale 			1ns/1ps
/*----------Soc.v---------*/
`define X_LEN				32
`define	ADDR_WIDTH			`X_LEN
`define	DATA_WIDTH			`X_LEN
`define	INSTR_WIDTH			64
`define	INSTR_WIDTH_16		16

/*----------Mux.v---------*/
`define	DATA_WIDTH_LOG2		5

/*----------Fetch.v---------*/
`define	START_PC			`X_LEN'h0000_0000

`define PC_PLUS_WIDTH		3
`define PC_PLUS_0			`PC_PLUS_WIDTH'd0
`define PC_PLUS_2			`PC_PLUS_WIDTH'd1
`define PC_PLUS_4			`PC_PLUS_WIDTH'd2
`define PC_PLUS_6			`PC_PLUS_WIDTH'd3
`define PC_PLUS_8			`PC_PLUS_WIDTH'd4

/*----------SimMemory.v---------*/
`define	SIM_MEM_WIDTH		32
`define	SIM_MEM_DEPTH		32
`define	SIM_MEM_NUM			1024

/*----------IFID.v---------*/
`define	IFID_WIDTH			`ADDR_WIDTH + `INSTR_WIDTH		//Fetch_NextPC + Icache_Instr

/*----------RegFile.v---------*/
`define	RF_ADDR_WIDTH		5
`define	RF_NUMBER			32

/*----------DecodeHazard.v---------*/
`define	RS1_SEL_WIDTH		4
`define	RS2_SEL_WIDTH		4
`define	RS_SEL_WIDTH		4
`define	RS_SEL_RF_1 		`RS_SEL_WIDTH'd0
`define	RS_SEL_EX_1			`RS_SEL_WIDTH'd1
`define	RS_SEL_EXMem_1		`RS_SEL_WIDTH'd2
`define	RS_SEL_Dcache_1		`RS_SEL_WIDTH'd3
`define	RS_SEL_Wb_1			`RS_SEL_WIDTH'd4
`define	RS_SEL_RF_0 		`RS_SEL_WIDTH'd5
`define	RS_SEL_EX_0			`RS_SEL_WIDTH'd6
`define	RS_SEL_EXMem_0		`RS_SEL_WIDTH'd7
`define	RS_SEL_Dcache_0		`RS_SEL_WIDTH'd8
`define	RS_SEL_Wb_0			`RS_SEL_WIDTH'd9

/*----------Decode.v---------*/

//opcode type
`define OPCODE_WIDTH		7
`define	OP_LUI				`OPCODE_WIDTH'b011_0111
`define	OP_AUIPC			`OPCODE_WIDTH'b001_0111
`define	OP_JAL				`OPCODE_WIDTH'b110_1111
`define	OP_JALR				`OPCODE_WIDTH'b110_0111
`define	OP_BRANCH			`OPCODE_WIDTH'b110_0011
`define	OP_LOAD				`OPCODE_WIDTH'b000_0011
`define	OP_STORE			`OPCODE_WIDTH'b010_0011
`define	OP_IMM_ALU			`OPCODE_WIDTH'b001_0011
`define	OP_R_ALU			`OPCODE_WIDTH'b011_0011
`define	OP_FENCE			`OPCODE_WIDTH'b000_1111
`define	OP_CSR				`OPCODE_WIDTH'b111_0011
//`define	OP_NOP				`OPCODE_WIDTH'b001_0011
`define	OP_ZERO				`OPCODE_WIDTH'b000_0000
`define OP_FDLD             `OPCODE_WIDTH'b000_0111
`define OP_FDST             `OPCODE_WIDTH'b010_0111
`define OP_FDMADD           `OPCODE_WIDTH'b100_0011
`define OP_FDMSUB           `OPCODE_WIDTH'b100_0111
`define OP_FDNMSUB          `OPCODE_WIDTH'b100_1011
`define OP_FDNMADD          `OPCODE_WIDTH'b100_1111
`define OP_FD               `OPCODE_WIDTH'b101_0011

//funct3 encode
`define FUNCT3_WIDTH		3
`define FUNCT3_0			`FUNCT3_WIDTH'b000
`define FUNCT3_1			`FUNCT3_WIDTH'b001
`define FUNCT3_2            `FUNCT3_WIDTH'b010
`define FUNCT3_3            `FUNCT3_WIDTH'b011
`define FUNCT3_4            `FUNCT3_WIDTH'b100
`define FUNCT3_5            `FUNCT3_WIDTH'b101
`define FUNCT3_6            `FUNCT3_WIDTH'b110
`define FUNCT3_7            `FUNCT3_WIDTH'b111

//funct7 encode
`define	FUNCT7_WIDTH		7
`define FUNCT7_0			`FUNCT7_WIDTH'b000_0000
`define FUNCT7_1			`FUNCT7_WIDTH'b000_0001
`define FUNCT7_5			`FUNCT7_WIDTH'b010_0000

//exception encode 
`define IMM_ECALL			`CSR_ADDR_WIDTH'b0000_0000_0000
`define IMM_EBREAK			`CSR_ADDR_WIDTH'b0000_0000_0001
`define IMM_MRET			`CSR_ADDR_WIDTH'b0011_0000_0010//new
`define IMM_WFI 			`CSR_ADDR_WIDTH'b0001_0000_0101//new
//for control signal decode
`define BOOL_WIDTH 		1
`define Y 				`BOOL_WIDTH'b1
`define N 				`BOOL_WIDTH'b0

// pc_sel
`define PC_SEL_WIDTH 	3
`define PC_0   	 		`PC_SEL_WIDTH'd0
`define PC_2   	 		`PC_SEL_WIDTH'd1
`define PC_4   	 		`PC_SEL_WIDTH'd2
`define PC_ALU 	 		`PC_SEL_WIDTH'd3
`define PC_CTRL 	 	`PC_SEL_WIDTH'd4

// A_sel
`define A_SEL_WIDTH 	1
`define A_XXX  			`A_SEL_WIDTH'b0
`define A_PC   			`A_SEL_WIDTH'b0
`define A_RS1  			`A_SEL_WIDTH'b1
			
// B_sel	
`define B_SEL_WIDTH 	1  
`define B_XXX  			`B_SEL_WIDTH'b0
`define B_IMM  			`B_SEL_WIDTH'b0
`define B_RS2  			`B_SEL_WIDTH'b1
			
// imm_sel
`define IMM_SEL_WIDTH 	3   
`define IMM_X  			`IMM_SEL_WIDTH'd0
`define IMM_I  			`IMM_SEL_WIDTH'd1
`define IMM_S  			`IMM_SEL_WIDTH'd2
`define IMM_U  			`IMM_SEL_WIDTH'd3
`define IMM_J  			`IMM_SEL_WIDTH'd4
`define IMM_B  			`IMM_SEL_WIDTH'd5
`define IMM_Z  			`IMM_SEL_WIDTH'd6
			
// br_type
`define BR_TYPE_WIDTH 	3  
`define BR_XXX 			`BR_TYPE_WIDTH'd0
`define BR_LTU 			`BR_TYPE_WIDTH'd1
`define BR_LT  			`BR_TYPE_WIDTH'd2
`define BR_EQ  			`BR_TYPE_WIDTH'd3
`define BR_GEU 			`BR_TYPE_WIDTH'd4
`define BR_GE  			`BR_TYPE_WIDTH'd5
`define BR_NE  			`BR_TYPE_WIDTH'd6
			
// st_type
`define ST_TYPE_WIDTH 	2   
`define ST_XXX 			`ST_TYPE_WIDTH'd0
`define ST_SW  			`ST_TYPE_WIDTH'd1
`define ST_SH  			`ST_TYPE_WIDTH'd2
`define ST_SB  			`ST_TYPE_WIDTH'd3
			
// ld_type
`define LD_TYPE_WIDTH 	3   
`define LD_XXX 			`LD_TYPE_WIDTH'd0
`define LD_LW  			`LD_TYPE_WIDTH'd1
`define LD_LH  			`LD_TYPE_WIDTH'd2
`define LD_LB  			`LD_TYPE_WIDTH'd3
`define LD_LHU 			`LD_TYPE_WIDTH'd4
`define LD_LBU 			`LD_TYPE_WIDTH'd5
			
// wb_sel	
`define WB_SEL_WIDTH 	1  
`define WB_ALU 			`WB_SEL_WIDTH'd0
`define WB_MEM 			`WB_SEL_WIDTH'd1
`define WB_XXX 			`WB_SEL_WIDTH'd0

//alu_op
`define ALU_OP_WIDTH	5
`define ALU_ADD    		`ALU_OP_WIDTH'd0
`define ALU_SUB    		`ALU_OP_WIDTH'd1
`define ALU_AND    		`ALU_OP_WIDTH'd2
`define ALU_OR     		`ALU_OP_WIDTH'd3
`define ALU_XOR    		`ALU_OP_WIDTH'd4
`define ALU_SLT    		`ALU_OP_WIDTH'd5
`define ALU_SLL    		`ALU_OP_WIDTH'd6
`define ALU_SLTU   		`ALU_OP_WIDTH'd7
`define ALU_SRL    		`ALU_OP_WIDTH'd8
`define ALU_SRA    		`ALU_OP_WIDTH'd9
`define ALU_COPY_A 		`ALU_OP_WIDTH'd10
`define ALU_COPY_B 		`ALU_OP_WIDTH'd11
`define ALU_BEQ         `ALU_OP_WIDTH'd12
`define ALU_BNE         `ALU_OP_WIDTH'd13
`define ALU_BLT         `ALU_OP_WIDTH'd14
`define ALU_BLTU        `ALU_OP_WIDTH'd15
`define ALU_BGE         `ALU_OP_WIDTH'd16
`define ALU_BGEU        `ALU_OP_WIDTH'd17
`define ALU_JAL         `ALU_OP_WIDTH'd18
`define ALU_JALR        `ALU_OP_WIDTH'd19
`define ALU_CSR         `ALU_OP_WIDTH'd20
`define ALU_MUL   		`ALU_OP_WIDTH'd21
`define ALU_MULH   	    `ALU_OP_WIDTH'd22
`define ALU_MULHSU      `ALU_OP_WIDTH'd23
`define ALU_MULHU       `ALU_OP_WIDTH'd24
`define ALU_DIV   	    `ALU_OP_WIDTH'd25
`define ALU_DIVU   	    `ALU_OP_WIDTH'd26
`define ALU_REM   	    `ALU_OP_WIDTH'd27
`define ALU_REMU   	    `ALU_OP_WIDTH'd28
`define ALU_XXX    		`ALU_OP_WIDTH'd29

//csr_cmd
`define CSR_CMD_WIDTH	3	
`define CSR_N 			`CSR_CMD_WIDTH'd0
`define CSR_W 			`CSR_CMD_WIDTH'd1
`define CSR_S 			`CSR_CMD_WIDTH'd2
`define CSR_C 			`CSR_CMD_WIDTH'd3
`define CSR_P 			`CSR_CMD_WIDTH'd4  

//Decode_Stall
`define DECODE_STALL_WIDTH	2	
`define STALL_XXX 			`DECODE_STALL_WIDTH'b00
`define STALL_FENCE			`DECODE_STALL_WIDTH'b01
`define STALL_WFI			`DECODE_STALL_WIDTH'b10

//Decode_Flush
`define DECODE_FLUSH_WIDTH	4	
`define FLUSH_XXX 			`DECODE_FLUSH_WIDTH'b0000
`define FLUSH_ECALL		    `DECODE_FLUSH_WIDTH'b0001
`define FLUSH_EBREAK 		`DECODE_FLUSH_WIDTH'b0010
`define FLUSH_ILLEGAL		`DECODE_FLUSH_WIDTH'b0100
`define FLUSH_ERET			`DECODE_FLUSH_WIDTH'b1000

//control signal flowing in pipe
`define All_CTRL_WIDTH	`A_SEL_WIDTH + `B_SEL_WIDTH + `ALU_OP_WIDTH + `ST_TYPE_WIDTH + `LD_TYPE_WIDTH + `WB_SEL_WIDTH + `BOOL_WIDTH + `CSR_CMD_WIDTH + `BOOL_WIDTH 
`define localAllCTRLWIDTH32  `PC_SEL_WIDTH + `A_SEL_WIDTH + `B_SEL_WIDTH + `IMM_SEL_WIDTH+ `ALU_OP_WIDTH + `BR_TYPE_WIDTH+ `BOOL_WIDTH + `ST_TYPE_WIDTH+ `LD_TYPE_WIDTH+ `WB_SEL_WIDTH + `BOOL_WIDTH+ `CSR_CMD_WIDTH+ `BOOL_WIDTH+ `DECODE_STALL_WIDTH + `DECODE_FLUSH_WIDTH + `XLEN_WIDTH_SEL
`define localAllCTRLWIDTH16  `A_SEL_WIDTH + `B_SEL_WIDTH + `IMM_SEL_WIDTH+ `ALU_OP_WIDTH + `BR_TYPE_WIDTH + `ST_TYPE_WIDTH+ `LD_TYPE_WIDTH+ `WB_SEL_WIDTH + `BOOL_WIDTH+ `CSR_CMD_WIDTH+ `BOOL_WIDTH+ `DECODE_STALL_WIDTH + `DECODE_FLUSH_WIDTH + `XLEN_WIDTH_SEL + `RF_ADDR_TYPE_SEL
`define DECODER_OUT_WIDTH `RF_ADDR_WIDTH + `RF_ADDR_WIDTH + `RF_ADDR_WIDTH + `RF_ADDR_WIDTH + `CSR_ADDR_WIDTH + `FUNCT3_WIDTH + `All_CTRL_WIDTH + `IMM_SEL_WIDTH + `DECODE_STALL_WIDTH + `DECODE_FLUSH_WIDTH + `XLEN_WIDTH_SEL + `DATA_WIDTH

//instr_op
`define INSTR_ENCODE_WIDTH	7
`define LUI    			`INSTR_ENCODE_WIDTH'd0 
`define AUIPC  			`INSTR_ENCODE_WIDTH'd1 
`define JAL    			`INSTR_ENCODE_WIDTH'd2 
`define JALR   			`INSTR_ENCODE_WIDTH'd3 
`define BEQ    			`INSTR_ENCODE_WIDTH'd4 
`define BNE    			`INSTR_ENCODE_WIDTH'd5 
`define BLT    			`INSTR_ENCODE_WIDTH'd6 
`define BGE    			`INSTR_ENCODE_WIDTH'd7 
`define BLTU   			`INSTR_ENCODE_WIDTH'd8 
`define BGEU   			`INSTR_ENCODE_WIDTH'd9 
`define LB     			`INSTR_ENCODE_WIDTH'd10
`define LH     			`INSTR_ENCODE_WIDTH'd11
`define LW     			`INSTR_ENCODE_WIDTH'd12
`define LBU    			`INSTR_ENCODE_WIDTH'd13
`define LHU    			`INSTR_ENCODE_WIDTH'd14
`define SB     			`INSTR_ENCODE_WIDTH'd15
`define SH     			`INSTR_ENCODE_WIDTH'd16
`define SW     			`INSTR_ENCODE_WIDTH'd17
`define ADDI   			`INSTR_ENCODE_WIDTH'd18
`define SLTI   			`INSTR_ENCODE_WIDTH'd19
`define SLTIU  			`INSTR_ENCODE_WIDTH'd20
`define XORI   			`INSTR_ENCODE_WIDTH'd21
`define ORI    			`INSTR_ENCODE_WIDTH'd22
`define ANDI   			`INSTR_ENCODE_WIDTH'd23
`define SLLI   			`INSTR_ENCODE_WIDTH'd24
`define SRLI   			`INSTR_ENCODE_WIDTH'd25
`define SRAI   			`INSTR_ENCODE_WIDTH'd26
`define ADD    			`INSTR_ENCODE_WIDTH'd27
`define SUB    			`INSTR_ENCODE_WIDTH'd28
`define SLL    			`INSTR_ENCODE_WIDTH'd29
`define SLT    			`INSTR_ENCODE_WIDTH'd30
`define SLTU   			`INSTR_ENCODE_WIDTH'd31
`define XOR    			`INSTR_ENCODE_WIDTH'd32
`define SRL    			`INSTR_ENCODE_WIDTH'd33
`define SRA    			`INSTR_ENCODE_WIDTH'd34
`define OR     			`INSTR_ENCODE_WIDTH'd35
`define AND    			`INSTR_ENCODE_WIDTH'd36
`define MUL    			`INSTR_ENCODE_WIDTH'd37 
`define MULH    		`INSTR_ENCODE_WIDTH'd38 
`define MULHSU    		`INSTR_ENCODE_WIDTH'd39 
`define MULHU    		`INSTR_ENCODE_WIDTH'd40 
`define DIV    			`INSTR_ENCODE_WIDTH'd41 
`define DIVU    		`INSTR_ENCODE_WIDTH'd42 
`define REM    			`INSTR_ENCODE_WIDTH'd43 
`define REMU    		`INSTR_ENCODE_WIDTH'd44 
`define FENCE  			`INSTR_ENCODE_WIDTH'd45
`define FENCEI 			`INSTR_ENCODE_WIDTH'd46
`define CSRRW  			`INSTR_ENCODE_WIDTH'd47
`define CSRRS  			`INSTR_ENCODE_WIDTH'd48
`define CSRRC  			`INSTR_ENCODE_WIDTH'd49
`define CSRRWI 			`INSTR_ENCODE_WIDTH'd50
`define CSRRSI 			`INSTR_ENCODE_WIDTH'd51
`define CSRRCI 			`INSTR_ENCODE_WIDTH'd52
`define ECALL  			`INSTR_ENCODE_WIDTH'd53
`define EBREAK 			`INSTR_ENCODE_WIDTH'd54
`define ERET   			`INSTR_ENCODE_WIDTH'd55
`define WFI    			`INSTR_ENCODE_WIDTH'd56
`define NOP    			`INSTR_ENCODE_WIDTH'd57 
`define UNKNOWN			`INSTR_ENCODE_WIDTH'd58

//float and double
`define FLW             `INSTR_ENCODE_WIDTH'd59
`define FSW             `INSTR_ENCODE_WIDTH'd60
`define FMADD_S         `INSTR_ENCODE_WIDTH'd61
`define FMSUB_S         `INSTR_ENCODE_WIDTH'd62
`define FNMSUB_S        `INSTR_ENCODE_WIDTH'd63
`define FNMADD_S        `INSTR_ENCODE_WIDTH'd64
`define FADD_S          `INSTR_ENCODE_WIDTH'd65
`define FSUB_S          `INSTR_ENCODE_WIDTH'd66
`define FMUL_S          `INSTR_ENCODE_WIDTH'd67
`define FDIV_S          `INSTR_ENCODE_WIDTH'd68
`define FSQRT_S         `INSTR_ENCODE_WIDTH'd69
`define FSGNJ_S         `INSTR_ENCODE_WIDTH'd70
`define FSGNJN_S        `INSTR_ENCODE_WIDTH'd71
`define FSGNJX_S        `INSTR_ENCODE_WIDTH'd72
`define FMIN_S          `INSTR_ENCODE_WIDTH'd73
`define FMAX_S          `INSTR_ENCODE_WIDTH'd74
`define FCVT_WS         `INSTR_ENCODE_WIDTH'd75
`define FCVT_WUS        `INSTR_ENCODE_WIDTH'd76
`define FMV_XW          `INSTR_ENCODE_WIDTH'd77
`define FEQ_S           `INSTR_ENCODE_WIDTH'd78
`define FLT_S           `INSTR_ENCODE_WIDTH'd79
`define FLE_S           `INSTR_ENCODE_WIDTH'd80
`define FCLASS_S        `INSTR_ENCODE_WIDTH'd81
`define FCVT_SW         `INSTR_ENCODE_WIDTH'd82
`define FCVT_SWU        `INSTR_ENCODE_WIDTH'd83
`define FMV_WX          `INSTR_ENCODE_WIDTH'd84
`define FLD             `INSTR_ENCODE_WIDTH'd85
`define FSD             `INSTR_ENCODE_WIDTH'd86
`define FMADD_D         `INSTR_ENCODE_WIDTH'd87
`define FMSUB_D         `INSTR_ENCODE_WIDTH'd88
`define FNMSUB_D        `INSTR_ENCODE_WIDTH'd89
`define FNMADD_D        `INSTR_ENCODE_WIDTH'd90
`define FADD_D          `INSTR_ENCODE_WIDTH'd91
`define FSUB_D          `INSTR_ENCODE_WIDTH'd92
`define FMUL_D          `INSTR_ENCODE_WIDTH'd93
`define FDIV_D          `INSTR_ENCODE_WIDTH'd94
`define FSQRT_D         `INSTR_ENCODE_WIDTH'd95
`define FSGNJ_D         `INSTR_ENCODE_WIDTH'd96
`define FSGNJN_D        `INSTR_ENCODE_WIDTH'd97
`define FSGNJX_D        `INSTR_ENCODE_WIDTH'd98
`define FMIN_D          `INSTR_ENCODE_WIDTH'd99
`define FMAX_D          `INSTR_ENCODE_WIDTH'd100
`define FCVT_SD         `INSTR_ENCODE_WIDTH'd101
`define FCVT_DS         `INSTR_ENCODE_WIDTH'd102
`define FEQ_D           `INSTR_ENCODE_WIDTH'd103
`define FLT_D           `INSTR_ENCODE_WIDTH'd104
`define FLE_D           `INSTR_ENCODE_WIDTH'd105
`define FCLASS_D        `INSTR_ENCODE_WIDTH'd106
`define FCVT_WD         `INSTR_ENCODE_WIDTH'd107
`define FCVT_WUD        `INSTR_ENCODE_WIDTH'd108
`define FCVT_DW         `INSTR_ENCODE_WIDTH'd109
`define FCVT_DWU        `INSTR_ENCODE_WIDTH'd110

//instr_op  16-bit only
`define INSTR_ENCODE_WIDTH	7
`define C_ADDI4SPN			`INSTR_ENCODE_WIDTH'd0 
`define C_FLD               `INSTR_ENCODE_WIDTH'd1 
`define C_LQ                `INSTR_ENCODE_WIDTH'd2  //RV128
`define C_LW                `INSTR_ENCODE_WIDTH'd3 
`define C_FLW               `INSTR_ENCODE_WIDTH'd4 
`define C_LD                `INSTR_ENCODE_WIDTH'd5  //RV64/128
`define C_FSD               `INSTR_ENCODE_WIDTH'd6 
`define C_SQ                `INSTR_ENCODE_WIDTH'd7  //RV128
`define C_SW                `INSTR_ENCODE_WIDTH'd8 
`define C_FSW               `INSTR_ENCODE_WIDTH'd9 
`define C_SD                `INSTR_ENCODE_WIDTH'd10 //RV128
`define C_NOP               `INSTR_ENCODE_WIDTH'd11
`define C_ADDI              `INSTR_ENCODE_WIDTH'd12
`define C_JAL               `INSTR_ENCODE_WIDTH'd13
`define C_ADDIW             `INSTR_ENCODE_WIDTH'd14 //RV64/128
`define C_LI                `INSTR_ENCODE_WIDTH'd15
`define C_ADDI16SP          `INSTR_ENCODE_WIDTH'd16
`define C_LUI               `INSTR_ENCODE_WIDTH'd17
`define C_SRLI              `INSTR_ENCODE_WIDTH'd18
`define C_SRLI64            `INSTR_ENCODE_WIDTH'd19 //RV64/128
`define C_SRAI              `INSTR_ENCODE_WIDTH'd20
`define C_SRAI64            `INSTR_ENCODE_WIDTH'd21 //RV64/128
`define C_ANDI              `INSTR_ENCODE_WIDTH'd22
`define C_SUB               `INSTR_ENCODE_WIDTH'd23
`define C_XOR               `INSTR_ENCODE_WIDTH'd24
`define C_OR                `INSTR_ENCODE_WIDTH'd25
`define C_AND               `INSTR_ENCODE_WIDTH'd26
`define C_SUBW              `INSTR_ENCODE_WIDTH'd27 //RV64/128
`define C_ADDW              `INSTR_ENCODE_WIDTH'd28 //RV64/128
`define C_J                 `INSTR_ENCODE_WIDTH'd29
`define C_BEQZ              `INSTR_ENCODE_WIDTH'd30
`define C_BNEZ              `INSTR_ENCODE_WIDTH'd31
`define C_SLLI              `INSTR_ENCODE_WIDTH'd32
`define C_SLLI64            `INSTR_ENCODE_WIDTH'd33 //RV64/128
`define C_FLDSP             `INSTR_ENCODE_WIDTH'd34
`define C_LQSP              `INSTR_ENCODE_WIDTH'd35 //RV128
`define C_LWSP              `INSTR_ENCODE_WIDTH'd36
`define C_FLWSP             `INSTR_ENCODE_WIDTH'd37
`define C_LDSP              `INSTR_ENCODE_WIDTH'd38 //RV64/128
`define C_JR                `INSTR_ENCODE_WIDTH'd39
`define C_MV                `INSTR_ENCODE_WIDTH'd40
`define C_EBREAK            `INSTR_ENCODE_WIDTH'd41
`define C_JALR              `INSTR_ENCODE_WIDTH'd42
`define C_ADD               `INSTR_ENCODE_WIDTH'd43
`define C_FSDSP             `INSTR_ENCODE_WIDTH'd44
`define C_SQSP              `INSTR_ENCODE_WIDTH'd45 //RV128
`define C_SWSP              `INSTR_ENCODE_WIDTH'd46
`define C_FSWSP             `INSTR_ENCODE_WIDTH'd47
`define C_SDSP              `INSTR_ENCODE_WIDTH'd48
`define C_RESERVED          `INSTR_ENCODE_WIDTH'd49
`define C_UNKNOWN           `INSTR_ENCODE_WIDTH'd50

//opcode16 type 16-bit only
`define OPCODE_WIDTH_16		2
`define	OP_00				`OPCODE_WIDTH'b00
`define	OP_01				`OPCODE_WIDTH'b01
`define	OP_10				`OPCODE_WIDTH'b10
`define	OP_11				`OPCODE_WIDTH'b11

//funct2 encode 16-bit only
`define FUNCT2_WIDTH		3
`define FUNCT2_0			`FUNCT3_WIDTH'd0
`define FUNCT2_1			`FUNCT3_WIDTH'd1
`define FUNCT2_2			`FUNCT3_WIDTH'd2
`define FUNCT2_3			`FUNCT3_WIDTH'd3

//funct4 encode 16-bit only
`define FUNCT4_WIDTH		3
`define FUNCT4_0			`FUNCT3_WIDTH'b1000
`define FUNCT4_1			`FUNCT3_WIDTH'b1001

//quadrant sel 16-bit only
`define QUADRANT_SEL_WIDTH		2
`define QUADRANT_0				`QUADRANT_SEL_WIDTH'd0
`define QUADRANT_1				`QUADRANT_SEL_WIDTH'd1
`define QUADRANT_2				`QUADRANT_SEL_WIDTH'd2

//imm type sel 16-bit only
//`define IMM_SEL_WIDTH 	3  
`define CI						`IMM_SEL_WIDTH'd0
`define CJ						`IMM_SEL_WIDTH'd1
`define CB						`IMM_SEL_WIDTH'd2
`define CIW						`IMM_SEL_WIDTH'd3
`define CL						`IMM_SEL_WIDTH'd4
`define CSS						`IMM_SEL_WIDTH'd5
`define CA						`IMM_SEL_WIDTH'd6
`define CR						`IMM_SEL_WIDTH'd7
`define CXX						`IMM_SEL_WIDTH'd0

//RF addr type sel 16-bit only
`define RF_ADDR_TYPE_SEL		2
`define RF_SHORT				`RF_ADDR_TYPE_SEL'd0
`define RF_LONG					`RF_ADDR_TYPE_SEL'd1
`define RF_FIXED				`RF_ADDR_TYPE_SEL'd2
`define RF_XXX					`RF_ADDR_TYPE_SEL'd0

`define XLEN_WIDTH_SEL			1
`define IS_32BIT				`XLEN_WIDTH_SEL'd1
`define IS_16BIT				`XLEN_WIDTH_SEL'd1
`define IS_XXBIT				`XLEN_WIDTH_SEL'd0
/*----------CSR.v---------*/
//`define	CSR_ADDR_WIDTH		12
//`define	CSR_DATA_WIDTH	    32
/*----------csr_idx---------*/
`define	CSR_ADDR_WIDTH		12
`define	CSR_DATA_WIDTH	  32
`define	CSR_USTATUS       12'h000
`define CSR_STVEC         12'h105 //Supervisor trap handler base address.
`define CSR_SATP          12'h180 //Supervisor address translation and protection.

`define	CSR_MSTATUS       12'h300
`define CSR_MISA          12'h301 
`define CSR_MIE           12'h304
`define CSR_MIP           12'h344
`define CSR_MEPC          12'h341
`define CSR_MCAUSE        12'h342
`define CSR_MTVAL         12'h343  //0x343 MRW mbadaddr Machine bad address.
`define CSR_MTVEC         12'h305
`define CSR_MEDELEG       12'h302 //Machine exception delegation register.
`define CSR_MIDELEG       12'h303 //Machine interrupt delegation register.
`define CSR_PMPCFG0       12'h3A0 //Physical memory protection confguration.
`define CSR_PMPADDR       12'h3B0 //Physical memory protection address register.
`define CSR_MSCRATCH      12'h340


`define CSR_MHARTID       12'hF14
`define ISA_CODE          32'h4000_0224 //0x301 MRW misa ISA and extensions
`define CSR_DCSR          12'h7b0
`define CSR_DPC           12'h7b1
`define CSR_DSCRATCH      12'h7b2

/*----------Core.v---------*/
`define PIPE_IFID_LEN 	`ADDR_WIDTH + `INSTR_WIDTH //2 instructions
`define PIPE_IDEX_LEN 	(`All_CTRL_WIDTH + `RF_ADDR_WIDTH + `RF_ADDR_WIDTH + `RF_ADDR_WIDTH + `DATA_WIDTH + `IMM_SEL_WIDTH + `CSR_ADDR_WIDTH +`DATA_WIDTH + `DATA_WIDTH + 1 + `ADDR_WIDTH) * 2
`define PIPE_IDEX_ISSUE1_START `All_CTRL_WIDTH + `RF_ADDR_WIDTH + `RF_ADDR_WIDTH + `RF_ADDR_WIDTH + `DATA_WIDTH + `IMM_SEL_WIDTH + `CSR_ADDR_WIDTH +`DATA_WIDTH + `DATA_WIDTH + 1 + `ADDR_WIDTH - 1
`define PIPE_EXMem_LEN 	(`DATA_WIDTH + `RF_ADDR_WIDTH + `DATA_WIDTH + `ST_TYPE_WIDTH + `LD_TYPE_WIDTH + `BOOL_WIDTH + `WB_SEL_WIDTH + `ADDR_WIDTH) * 2
`define PIPE_EXMem_ISSUE1_START `DATA_WIDTH + `RF_ADDR_WIDTH + `DATA_WIDTH + `ST_TYPE_WIDTH + `LD_TYPE_WIDTH + `BOOL_WIDTH + `WB_SEL_WIDTH + `ADDR_WIDTH - 1
`define PIPE_MemWb_LEN 	(`RF_ADDR_WIDTH + `BOOL_WIDTH + `DATA_WIDTH + `DATA_WIDTH + `BOOL_WIDTH) * 2
`define PIPE_MemWb_ISSUE1_START `RF_ADDR_WIDTH + `BOOL_WIDTH + `DATA_WIDTH + `DATA_WIDTH + `BOOL_WIDTH - 1
