/*
 * @Author: Y-BoBo
 * @Date:   2019-10-28 15:51
 * @Last Modified by: Y-BoBo
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: Memory module
 */

`include "../src/common/Define.v"
module Dcache(
  //Dcache
  input  wire                         		clk,
  input  wire                         		rst_n,
  //input  wire                       		  Mem_LdEN,        //To EX stage, generate forward control signal
  input  wire                         		Mem_DcacheEN,    //To Dcache
  input  wire                         		Mem_DcacheRd,    //To Dcache
  input  wire  [1:0]      			  	    	Mem_DcacheWidth, //To Dcache
  input  wire  [`ADDR_WIDTH-1  	:0]      	Mem_DcacheAddr,   //To Dcache
  input  wire  [`DATA_WIDTH-1	:0]       	EXMem_Rs2Data,
  input  wire                           	Mem_DcacheSign,
  output wire  [`DATA_WIDTH-1  	:0]      	Dcache_DataRd,
  //Icache	
  input  wire  [`ADDR_WIDTH-1  	:0]      	Icache_NextPC,
  output wire  [`DATA_WIDTH-1  	:0]      	Icache_Instr
);

wire [11:0]     addr;  //12bit address  4KB 
wire [4 :0]     sel_hw;
wire [4 :0]     sel_byte;
wire [6 :0]     sel_byte_start;
wire [31:0]     sel_data_rd;
wire [31:0]     data_tmp;
reg  [31:0]     Cache_core_data_reg;
reg  [31:0]     data [0:9215];
  
integer i;					
//offset    
assign           addr = Mem_DcacheAddr[13:2];             //address generation
assign        sel_hw  = Mem_DcacheAddr[1]   << 'd4;       //choose start addr of half word  0/2*16
assign      sel_byte  = Mem_DcacheAddr[1:0] << 'd3;       //choose start addr of byte       0/1/2/3*8

//read to Icache
wire   [11:0]  Icache_addr;
assign Icache_addr  = Icache_NextPC[13:2];
assign data_tmp     = {data[Icache_addr+1][15:0],data[Icache_addr][31:16]};
assign Icache_Instr = (Icache_NextPC[1]==1)? data_tmp: data[Icache_addr];

//read
assign sel_data_rd = data[addr];
always@(*)                       //choose word/half_word/byte from word
  begin
    if( Mem_DcacheRd &&  Mem_DcacheEN )
        case(Mem_DcacheWidth)
          2'b00:     
                  if(Mem_DcacheSign)
                      Cache_core_data_reg = {{24{sel_data_rd[sel_byte+'d7]}},sel_data_rd[sel_byte+:'d8]};  
                  else
                      Cache_core_data_reg = {24'b0,sel_data_rd[sel_byte+:'d8]};   
          2'b01:   
                  if(Mem_DcacheSign)  
                      Cache_core_data_reg = {{16{sel_data_rd[sel_hw+'d15]}} ,sel_data_rd[sel_hw+:'d16]};
                  else
                      Cache_core_data_reg = {16'b0,sel_data_rd[sel_hw+:'d16]};
          2'b10:      Cache_core_data_reg = sel_data_rd;
          default:    Cache_core_data_reg = 32'b0;
        endcase
    else
          Cache_core_data_reg = 32'b0;
  end   
assign Dcache_DataRd = Cache_core_data_reg; 

//write
always@(posedge clk)
  begin
  if(~rst_n)
        for(i = 0 ; i < 9216 ;i = i + 1) data[i] <= 32'b0;//just for test here
    else if((!Mem_DcacheRd) &&  Mem_DcacheEN  )
      case(Mem_DcacheWidth)
        2'b00:     data[addr][sel_byte+:'d8]  <= EXMem_Rs2Data['d8-1:0];
        2'b01:     data[addr][sel_byte+:'d16] <= EXMem_Rs2Data['d16-1:0];
        2'b10:     data[addr][sel_byte+:'d32] <= EXMem_Rs2Data['d32-1:0];
        default:   data[addr] <= data[addr];
	    endcase
  end
endmodule