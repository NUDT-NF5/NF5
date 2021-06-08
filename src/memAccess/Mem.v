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
    input  wire  [`LD_TYPE_WIDTH-1:0]     EXMem_LdType,    //From EXMem stage, indicate load type 
    input  wire  [`ST_TYPE_WIDTH-1:0]     EXMem_StType,    //From EXMem stage, indicate store type
    input  wire  [`SIMD_DATA_WIDTH-1:0]   EXMem_AluData,   //From EXMem stage, indicate Dcaceh Addr
    output wire                           Mem_LdEN,        //To EX stage, generate forward control signal
    output wire                           Mem_DcacheEN,    //To Dcache
    output wire                           Mem_DcacheRd,    //To Dcache
    output wire  [1:0]      			  Mem_DcacheWidth, //To Dcache
    output wire  [`ADDR_WIDTH-1  :0]      Mem_DcacheAddr,   //To Dcache
    output wire                           Mem_DcacheSign ,  //To Dcache
    input  wire                           Csr_Memflush,
    output wire                           rd_high,
    output wire                           wr_high
    ); 
wire   St_EN;
assign St_EN    = ( EXMem_StType == `ST_XXX )? 0 : 1;
assign Mem_LdEN = ( EXMem_LdType == `LD_XXX ) ? 0 : 1;
assign Mem_DcacheEN    = Mem_LdEN || St_EN &(!Csr_Memflush); 
assign Mem_DcacheRd    = Mem_LdEN ? 1 : 0; 
assign Mem_DcacheWidth = (( EXMem_LdType == `LD_LB ) || ( EXMem_LdType == `LD_LBU ) || ( EXMem_StType == `ST_SB ))? 2'b00 : 
                         (( EXMem_LdType == `LD_LH ) || ( EXMem_LdType == `LD_LHU ) || ( EXMem_StType == `ST_SH ))? 2'b01 : 
                                                        (( EXMem_LdType == `LD_LW || EXMem_LdType == `LD_LWH ) 
                                                        || ( EXMem_StType == `ST_SW || EXMem_StType == `ST_SWH ))? 2'b10 : 
                                                        (( EXMem_LdType == `LD_LD ) || ( EXMem_StType == `ST_SD ))? 2'b11 :2'b00;
assign Mem_DcacheAddr  = Mem_DcacheEN ? EXMem_AluData[`DATA_WIDTH - 1:0] : `DATA_WIDTH'b0;
assign Mem_DcacheSign = ((EXMem_LdType == `LD_LB)||(EXMem_LdType == `LD_LH))? 1:0;
assign rd_high = (EXMem_StType == `ST_SWH) ? 1 : 0;
assign wr_high = (EXMem_LdType == `LD_LWH) ? 1 : 0;
endmodule 