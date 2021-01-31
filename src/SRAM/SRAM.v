//************************************************************************************************
//************************************************************************************************
//*****************This module is used to describe the cache RAM**********************************
//************************************************************************************************
//************************************************************************************************
`include "../src/common/Define.v"
module SRAM
#(parameter  SRAM_depth   = 14'd16383+1)
(
  input  wire          clk,
  input  wire          rst_n,
  //----conneted with Dcache
  input  wire          Dcahe_RW,
  input  wire          Dcache_En,
  input  wire          Bus_hand_D_DataWrtBusCond,
  input  wire          Bus_hand_D_DataRdBusCond,
  input  wire [31:0]   Dcache_Addr,
  input  wire [31:0]   Dcache_DataIn,
  output wire [31:0]   Dcache_DataOut,
  //----connected with Icache
  input  wire [31:0]   Icache_Addr,
  input  wire          Bus_hand_I_DataRdBusCond,
  output wire [31:0]   Icache_DataOut
);
reg     [31:0]   data [SRAM_depth-1:0];  
wire    [13:0]   D_addr;              //Dcache access SRAM address, use 14bits of them
wire    [13:0]   I_addr;              //Icache access SRAM address, use 14bits of them
assign  D_addr = Dcache_Addr[15:2];
assign  I_addr = Icache_Addr[15:2];
/*
reg     [13:0]   D_addr_reg;
reg     [31:0]   Dcache_DataIn_reg;
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      D_addr_reg <= 32'b0;
    else
      D_addr_reg <= D_addr;
  end
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      Dcache_DataIn_reg <= 32'b0;
    else
      Dcache_DataIn_reg <= Dcache_DataIn;
  end*/

integer i;
//----communicate with Dcache
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      for(i=0;i<SRAM_depth;i=i+1) data[i] <= 32'b0;
    else if(Dcache_En && !Dcahe_RW && Bus_hand_D_DataWrtBusCond)
      //data[D_addr_reg] <= Dcache_DataIn_reg;
      data[D_addr] <= Dcache_DataIn;
  end
assign Dcache_DataOut = Bus_hand_D_DataRdBusCond? data[D_addr]:32'b0;
//----read data to Icache
assign Icache_DataOut = Bus_hand_I_DataRdBusCond? data[I_addr]:32'b0;
endmodule