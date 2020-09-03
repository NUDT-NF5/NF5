/*
 * @Author: Y-BoBo
 * @Date:   2019-10-28 15:51
 * @Last Modified by: Y-BoBo
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: Mem module, generate Dcache control signal
 */
/*`include "../src/common/Define.v"
module Mem
(   
    input                                 clk,
    input                                 rst_n,

    input  wire  [`LD_TYPE_WIDTH-1:0]     EXMem_LdType_0,    //From EXMem stage, indicate load type 
    input  wire  [`ST_TYPE_WIDTH-1:0]     EXMem_StType_0,    //From EXMem stage, indicate store type
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_AluData_0,   //From EXMem stage, indicate Dcaceh Addr

    input  wire  [`LD_TYPE_WIDTH-1:0]     EXMem_LdType_1,    //From EXMem stage, indicate load type 
    input  wire  [`ST_TYPE_WIDTH-1:0]     EXMem_StType_1,    //From EXMem stage, indicate store type
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_AluData_1,   //From EXMem stage, indicate Dcaceh Addr
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_Rs2Data_0,
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_Rs2Data_1,
    output wire                           Mem_LdEN_0,        //To EX stage, generate forward control signal
    output wire                           Mem_LdEN_1,        //To EX stage, generate forward control signal
    output wire                           Mem_DcacheEN_0,    //To Dcache
    output wire                           Mem_DcacheEN_1,
    output wire                           Mem_DcacheRd,    //To Dcache
    output wire  [1:0]      			  Mem_DcacheWidth, //To Dcache
    output wire  [`ADDR_WIDTH-1  :0]      Mem_DcacheAddr,   //To Dcache
    output wire                           Mem_DcacheSign ,  //To Dcache
    output wire                           Csr_Memflush,

    output wire  [`DATA_WIDTH-1   :0]     Dcache_DataRd_0,
    output wire  [`DATA_WIDTH-1   :0]     Dcache_DataRd_1,
    input  wire  [`ADDR_WIDTH-1   :0]     Icache_NextPC,
    output wire  [`INSTR_WIDTH-1  :0]     Icache_Instr
    ); 

wire [`DATA_WIDTH-1   :0] EXMem_Rs2Data;
wire [`DATA_WIDTH-1   :0] Dcache_DataRd;

Dcache cache(
    .clk(clk),
	.rst_n(rst_n),
	.Mem_DcacheEN(Mem_DcacheEN),   
	.Mem_DcacheRd(Mem_DcacheRd),   
	.Mem_DcacheWidth(Mem_DcacheWidth),
 	.Mem_DcacheAddr(Mem_DcacheAddr),
	.EXMem_Rs2Data(EXMem_Rs2Data),
	.Mem_DcacheSign(Mem_DcacheSign),
 	.Dcache_DataRd(Dcache_DataRd),
 	.Icache_NextPC(Icache_NextPC),
    .Icache_Instr(Icache_Instr)
);


//reg [`LD_TYPE_WIDTH-1:0]  EXMem_LdType_r;
//reg [`ST_TYPE_WIDTH-1:0]  EXMem_StType_r;
//reg [`DATA_WIDTH-1   :0]  EXMem_AluData_r;

wire   St_EN_0;
wire   St_EN_1;
assign St_EN_0    = ( EXMem_StType_0 == `ST_XXX )? 0 : 1;
assign Mem_LdEN_0 = ( EXMem_LdType_0 == `LD_XXX ) ? 0 : 1;
assign St_EN_1    = ( EXMem_StType_1 == `ST_XXX )? 0 : 1;
assign Mem_LdEN_1 = ( EXMem_LdType_1 == `LD_XXX ) ? 0 : 1;
assign Mem_DcacheEN_0 = Mem_LdEN_0 || St_EN_0 &(!Csr_Memflush); 
assign Mem_DcacheEN_1 = Mem_LdEN_1 || St_EN_1 &(!Csr_Memflush);
assign Mem_DcacheEN = Mem_DcacheEN_1 || Mem_DcacheEN_0;
//assign Mem_LdEN_r        = ( EXMem_LdType_r == `LD_XXX ) ? 0 : 1;
//assign St_EN_r           = ( EXMem_StType_r == `ST_XXX )? 0 : 1;
//assign Mem_DcacheEN_r    = Mem_LdEN_r || St_EN_r &(!Csr_Memflush);

assign Mem_DcacheRd      = (Mem_LdEN_0 || Mem_LdEN_1) ? 1 : 0; 
wire   Mem_DcacheWidth_0 = (( EXMem_LdType_0 == `LD_LB ) || ( EXMem_LdType_0 == `LD_LBU ) || ( EXMem_StType_0 == `ST_SB ))? 2'b00 : 
                           (( EXMem_LdType_0 == `LD_LH ) || ( EXMem_LdType_0 == `LD_LHU ) || ( EXMem_StType_0 == `ST_SH ))? 2'b01 : 
                                                            (( EXMem_LdType_0 == `LD_LW ) || ( EXMem_StType_0 == `ST_SW ))? 2'b10 : 
                                                                                                                            2'b00;
wire   Mem_DcacheWidth_1 = (( EXMem_LdType_1 == `LD_LB ) || ( EXMem_LdType_1 == `LD_LBU ) || ( EXMem_StType_1 == `ST_SB ))? 2'b00 : 
                           (( EXMem_LdType_1 == `LD_LH ) || ( EXMem_LdType_1 == `LD_LHU ) || ( EXMem_StType_1 == `ST_SH ))? 2'b01 : 
                                                            (( EXMem_LdType_1 == `LD_LW ) || ( EXMem_StType_1 == `ST_SW ))? 2'b10 : 
                                                                                                                            2'b00;
assign Mem_DcacheWidth   = (Mem_DcacheEN_0) ? Mem_DcacheWidth_0 : Mem_DcacheWidth_1;
wire   Mem_DcacheAddr_0  = Mem_DcacheEN_0 ? EXMem_AluData_0 : `DATA_WIDTH'b0;
wire   Mem_DcacheAddr_1  = Mem_DcacheEN_1 ? EXMem_AluData_1 : `DATA_WIDTH'b0;
assign Mem_DcacheAddr    = (Mem_DcacheEN_1) ? Mem_DcacheAddr_1 : Mem_DcacheAddr_0;
wire   Mem_DcacheSign_0  = ((EXMem_LdType_0 == `LD_LB)||(EXMem_LdType_0 == `LD_LH))? 1:0;
wire   Mem_DcacheSign_1  = ((EXMem_LdType_1 == `LD_LB)||(EXMem_LdType_1 == `LD_LH))? 1:0;
assign Mem_DcacheSign    = (Mem_DcacheEN_1) ? Mem_DcacheSign_1 : Mem_DcacheSign_0;
assign EXMem_Rs2Data     = (Mem_DcacheEN_1) ? EXMem_Rs2Data_1 : EXMem_Rs2Data_0;
assign Dcache_DataRd_1   = (Mem_LdEN_1) ? Dcache_DataRd : 0;
assign Dcache_DataRd_0   = (Mem_LdEN_0) ? Dcache_DataRd : 0;

endmodule */
/*
 * @Author: Y-BoBo
 * @Date:   2019-10-28 15:51
 * @Last Modified by: Y-BoBo
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: Mem module, generate Dcache control signal
 */
`include "../src/common/Define.v"
module Mem
(
    input  wire  [`LD_TYPE_WIDTH-1:0]     EXMem_LdType_0,    //From EXMem stage, indicate load type 
    input  wire  [`ST_TYPE_WIDTH-1:0]     EXMem_StType_0,    //From EXMem stage, indicate store type
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_AluData_0,   //From EXMem stage, indicate Dcaceh Addr
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_Rs2Data_0,

    input  wire  [`LD_TYPE_WIDTH-1:0]     EXMem_LdType_1,    //From EXMem stage, indicate load type 
    input  wire  [`ST_TYPE_WIDTH-1:0]     EXMem_StType_1,    //From EXMem stage, indicate store type
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_AluData_1,   //From EXMem stage, indicate Dcaceh Addr
    input  wire  [`DATA_WIDTH-1   :0]     EXMem_Rs2Data_1,

    output wire                           Mem_LdEN_0,        //To EX stage, generate forward control signal
    output wire                           Mem_LdEN_1,        //To EX stage, generate forward control signal
    output wire  [`DATA_WIDTH-1   :0]     EXMem_Rs2Data,
    output wire                           Mem_DcacheEN,    //To Dcache
    output wire                           Mem_DcacheEN_0,    //To EX
    output wire                           Mem_DcacheEN_1,    //To EX
    output wire                           Mem_DcacheRd,    //To Dcache
    output wire  [1:0]      			  Mem_DcacheWidth, //To Dcache
    output wire  [`ADDR_WIDTH-1  :0]      Mem_DcacheAddr,   //To Dcache
    output wire                           Mem_DcacheSign ,  //To Dcache
    output wire  [`DATA_WIDTH-1   :0]     Dcache_DataRd_0,
    output wire  [`DATA_WIDTH-1   :0]     Dcache_DataRd_1,
    input wire                            Csr_Memflush,
    input wire   [`DATA_WIDTH-1   :0]     Dcache_DataRd
    ); 
wire   St_EN_0;
wire   St_EN_1;
wire   [1:0]  Mem_DcacheWidth_0;
wire   [1:0]  Mem_DcacheWidth_1;
assign St_EN_0    = ( EXMem_StType_0 == `ST_XXX )? 0 : 1;
assign St_EN_1    = ( EXMem_StType_1 == `ST_XXX )? 0 : 1;
assign Mem_LdEN_0 = ( EXMem_LdType_0 == `LD_XXX ) ? 0 : 1;
assign Mem_LdEN_1 = ( EXMem_LdType_1 == `LD_XXX ) ? 0 : 1;
assign Mem_DcacheEN_0    = Mem_LdEN_0 || St_EN_0 &(!Csr_Memflush);
assign Mem_DcacheEN_1    = Mem_LdEN_1 || St_EN_1 &(!Csr_Memflush);
assign Mem_DcacheEN      = Mem_DcacheEN_0 || Mem_DcacheEN_1;
assign Mem_DcacheRd_0    = Mem_LdEN_0 ? 1 : 0;
assign Mem_DcacheRd_1    = Mem_LdEN_1 ? 1 : 0;
assign Mem_DcacheRd      = Mem_DcacheRd_0 || Mem_DcacheRd_1;
assign Mem_DcacheWidth_0 = (( EXMem_LdType_0 == `LD_LB ) || ( EXMem_LdType_0 == `LD_LBU ) || ( EXMem_StType_0 == `ST_SB ))? 2'b00 : 
                           (( EXMem_LdType_0 == `LD_LH ) || ( EXMem_LdType_0 == `LD_LHU ) || ( EXMem_StType_0 == `ST_SH ))? 2'b01 : 
                                                            (( EXMem_LdType_0 == `LD_LW ) || ( EXMem_StType_0 == `ST_SW ))? 2'b10 : 2'b00;
assign Mem_DcacheWidth_1 = (( EXMem_LdType_1 == `LD_LB ) || ( EXMem_LdType_1 == `LD_LBU ) || ( EXMem_StType_1 == `ST_SB ))? 2'b00 : 
                           (( EXMem_LdType_1 == `LD_LH ) || ( EXMem_LdType_1 == `LD_LHU ) || ( EXMem_StType_1 == `ST_SH ))? 2'b01 : 
                                                            (( EXMem_LdType_1 == `LD_LW ) || ( EXMem_StType_1 == `ST_SW ))? 2'b10 : 2'b00;
assign Mem_DcacheWidth   = Mem_DcacheEN_0 ? Mem_DcacheWidth_0 :
                           Mem_DcacheEN_1 ? Mem_DcacheWidth_1 : 0;
assign EXMem_Rs2Data     = Mem_DcacheEN_0 ? EXMem_Rs2Data_0 : EXMem_Rs2Data_1;
assign Mem_DcacheAddr    = Mem_DcacheEN_0 ? EXMem_AluData_0 : 
                           Mem_DcacheEN_1 ? EXMem_AluData_1 : 0;
assign Mem_DcacheSign_0  = ((EXMem_LdType_0 == `LD_LB)||(EXMem_LdType_0 == `LD_LH))? 1:0;
assign Mem_DcacheSign_1  = ((EXMem_LdType_1 == `LD_LB)||(EXMem_LdType_1 == `LD_LH))? 1:0;
assign Mem_DcacheSign    = Mem_DcacheEN_0 ? Mem_DcacheSign_0 :
                           Mem_DcacheEN_1 ? Mem_DcacheSign_1 : 0;
assign Dcache_DataRd_0   = Mem_LdEN_0 ? Dcache_DataRd : 0;
assign Dcache_DataRd_1   = Mem_LdEN_1 ? Dcache_DataRd : 0;
endmodule 