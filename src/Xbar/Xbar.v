//************************************************************************************************
//************************************************************************************************
//*****************This module is used to transmit dara between core and cache********************
//************************************************************************************************
//************************************************************************************************
`include "../src/common/Define.v"
module Xbar(
    input  wire         clk,
    input  wire         rst_n,
//--------connect with Icache(1) Dcache(0)
    //tilelink d channel(Dcache)
    input  wire          Bus_0_dBitsReady   , 
    output wire          Bus_0_dBitsValid   ,  
    output wire [2:0]    Bus_0_dBitsOpcode  ,  
    output wire [31:0]   Bus_0_dBitsData    ,  
    output wire [1:0]    Bus_0_dBitsParam   ,  
    output wire [4:0]    Bus_0_dBitsSource  ,  
    output wire [1:0]    Bus_0_dBitsSink    ,  
    output wire          Bus_0_dBitsDennied ,  
    output wire          Bus_0_dBitsCorrupt ,  
    output wire [3:0]    Bus_0_dBitsSize    ,  
    //tilelink a channel(Dcache)
    output wire          Bus_0_aBitsReady   , 
    input  wire          Bus_0_aBitsValid   , 
    input  wire [31:0]   Bus_0_aBitsAddress , 
          input  wire [31:0]   Core_CacheAddr_xbar_D , 
    input  wire [2:0]    Bus_0_aBitsOpcode  , 
    input  wire [3:0]    Bus_0_aBitsSize    , 
    input  wire [3:0]    Bus_0_aBitsMask    , 
    input  wire [31:0]   Bus_0_aBitsData    , 
    input  wire [2:0]    Bus_0_aBitsParam   , 
    input  wire [4:0]    Bus_0_aBitsSource  , 
    input  wire          Bus_0_aBitsCorrupt , 
    //tilelink d channel(Icache)
    input  wire          Bus_1_dBitsReady   , 
    output wire          Bus_1_dBitsValid   ,  
    output wire [2:0]    Bus_1_dBitsOpcode  ,  
    output wire [31:0]   Bus_1_dBitsData    ,  
    output wire [1:0]    Bus_1_dBitsParam   ,  
    output wire [4:0]    Bus_1_dBitsSource  ,  
    output wire [1:0]    Bus_1_dBitsSink    ,  
    output wire          Bus_1_dBitsDennied ,  
    output wire          Bus_1_dBitsCorrupt ,  
    output wire [3:0]    Bus_1_dBitsSize    ,  
    //tilelink a channel(Icache)
    output wire          Bus_1_aBitsReady   , 
    input  wire          Bus_1_aBitsValid   , 
    input  wire [31:0]   Bus_1_aBitsAddress , 
          input  wire [31:0]   Core_CacheAddr_xbar_I , 
    input  wire [2:0]    Bus_1_aBitsOpcode  , 
    input  wire [3:0]    Bus_1_aBitsSize    , 
    input  wire [3:0]    Bus_1_aBitsMask    , 
    input  wire [31:0]   Bus_1_aBitsData    , 
    input  wire [2:0]    Bus_1_aBitsParam   , 
    input  wire [4:0]    Bus_1_aBitsSource  , 
    input  wire          Bus_1_aBitsCorrupt ,
//---------connect with SRAM
    //tilelink d channel(Dcache)
    output wire          Bus_D_dBitsReady   , 
    input  wire          Bus_D_dBitsValid   ,  
    input  wire [2:0]    Bus_D_dBitsOpcode  ,  
    input  wire [31:0]   Bus_D_dBitsData    ,  
    input  wire [1:0]    Bus_D_dBitsParam   ,  
    input  wire [4:0]    Bus_D_dBitsSource  ,  
    input  wire [1:0]    Bus_D_dBitsSink    ,  
    input  wire          Bus_D_dBitsDennied ,  
    input  wire          Bus_D_dBitsCorrupt ,  
    input  wire [3:0]    Bus_D_dBitsSize    ,  
    //tilelink a channel(Dcache)
    input  wire          Bus_D_aBitsReady   ,  
    output wire          Bus_D_aBitsValid   ,  
    output wire [31:0]   Bus_D_aBitsAddress ,  
    output wire [2:0]    Bus_D_aBitsOpcode  ,  
    output wire [3:0]    Bus_D_aBitsSize    ,  
    output wire [3:0]    Bus_D_aBitsMask    ,  
    output wire [31:0]   Bus_D_aBitsData    ,  
    output wire [2:0]    Bus_D_aBitsParam   ,  
    output wire [4:0]    Bus_D_aBitsSource  ,  
    output wire          Bus_D_aBitsCorrupt , 
    //tilelink d channel(Icache)
    output wire          Bus_I_dBitsReady   , 
    input  wire          Bus_I_dBitsValid   ,  
    input  wire [2:0]    Bus_I_dBitsOpcode  ,  
    input  wire [31:0]   Bus_I_dBitsData    ,  
    input  wire [1:0]    Bus_I_dBitsParam   ,  
    input  wire [4:0]    Bus_I_dBitsSource  ,  
    input  wire [1:0]    Bus_I_dBitsSink    ,  
    input  wire          Bus_I_dBitsDennied ,  
    input  wire          Bus_I_dBitsCorrupt ,  
    input  wire [3:0]    Bus_I_dBitsSize    ,  
    //tilelink a channel(Icache)
    input  wire          Bus_I_aBitsReady   ,  
    output wire          Bus_I_aBitsValid   ,  
    output wire [31:0]   Bus_I_aBitsAddress ,  
    output wire [2:0]    Bus_I_aBitsOpcode  ,  
    output wire [3:0]    Bus_I_aBitsSize    ,  
    output wire [3:0]    Bus_I_aBitsMask    ,  
    output wire [31:0]   Bus_I_aBitsData    ,  
    output wire [2:0]    Bus_I_aBitsParam   ,  
    output wire [4:0]    Bus_I_aBitsSource  ,  
    output wire          Bus_I_aBitsCorrupt 
);

reg          Bus_D_reg_dBitsReady   ;
reg          Bus_0_reg_dBitsValid   ;
reg  [2:0]   Bus_0_reg_dBitsOpcode  ;
reg  [31:0]  Bus_0_reg_dBitsData    ;
reg  [1:0]   Bus_0_reg_dBitsParam   ;
reg  [4:0]   Bus_0_reg_dBitsSource  ;
reg  [31:0]  Bus_0_reg_dBitsSink    ;
reg          Bus_0_reg_dBitsDennied ;
reg          Bus_0_reg_dBitsCorrupt ;
reg  [3:0]   Bus_0_reg_dBitsSize    ;

reg          Bus_0_reg_aBitsReady   ;
reg          Bus_D_reg_aBitsValid   ;
reg  [31:0]  Bus_D_reg_aBitsAddress ;
reg  [2:0]   Bus_D_reg_aBitsOpcode  ;
reg  [3:0]   Bus_D_reg_aBitsSize    ;
reg  [3:0]   Bus_D_reg_aBitsMask    ;
reg  [31:0]  Bus_D_reg_aBitsData    ;
reg  [2:0]   Bus_D_reg_aBitsParam   ;
reg  [4:0]   Bus_D_reg_aBitsSource  ;
reg          Bus_D_reg_aBitsCorrupt ;

reg          Bus_I_reg_dBitsReady   ;
reg          Bus_1_reg_dBitsValid   ;
reg  [2:0]   Bus_1_reg_dBitsOpcode  ;
reg  [31:0]  Bus_1_reg_dBitsData    ;
reg  [1:0]   Bus_1_reg_dBitsParam   ;
reg  [4:0]   Bus_1_reg_dBitsSource  ;
reg  [31:0]  Bus_1_reg_dBitsSink    ;
reg          Bus_1_reg_dBitsDennied ;
reg          Bus_1_reg_dBitsCorrupt ;
reg  [3:0]   Bus_1_reg_dBitsSize    ;

reg          Bus_1_reg_aBitsReady   ;
reg          Bus_I_reg_aBitsValid   ;
reg  [31:0]  Bus_I_reg_aBitsAddress ;
reg  [2:0]   Bus_I_reg_aBitsOpcode  ;
reg  [3:0]   Bus_I_reg_aBitsSize    ;
reg  [3:0]   Bus_I_reg_aBitsMask    ;
reg  [31:0]  Bus_I_reg_aBitsData    ;
reg  [2:0]   Bus_I_reg_aBitsParam   ;
reg  [4:0]   Bus_I_reg_aBitsSource  ;
reg          Bus_I_reg_aBitsCorrupt ;


//transform Dcache signal
always@(*)
    begin
      if((Core_CacheAddr_xbar_D >= 32'h80000000) && (Core_CacheAddr_xbar_D <= 32'h80003fff))
        begin
       //D channel signal
        Bus_D_reg_dBitsReady   =  Bus_0_dBitsReady   ;
        Bus_0_reg_dBitsValid   =  Bus_D_dBitsValid   ;
        Bus_0_reg_dBitsOpcode  =  Bus_D_dBitsOpcode  ;
        Bus_0_reg_dBitsData    =  Bus_D_dBitsData    ;
        Bus_0_reg_dBitsParam   =  Bus_D_dBitsParam   ;
        Bus_0_reg_dBitsSource  =  Bus_D_dBitsSource  ;
        Bus_0_reg_dBitsSink    =  Bus_D_dBitsSink    ;
        Bus_0_reg_dBitsDennied =  Bus_D_dBitsDennied ;
        Bus_0_reg_dBitsCorrupt =  Bus_D_dBitsCorrupt ;
        Bus_0_reg_dBitsSize    =  Bus_D_dBitsSize    ;
      //A channel signal
        Bus_0_reg_aBitsReady   =  Bus_D_aBitsReady   ;
        Bus_D_reg_aBitsValid   =  Bus_0_aBitsValid   ;
        Bus_D_reg_aBitsAddress =  Bus_0_aBitsAddress ;
        Bus_D_reg_aBitsOpcode  =  Bus_0_aBitsOpcode  ;
        Bus_D_reg_aBitsSize    =  Bus_0_aBitsSize    ;
        Bus_D_reg_aBitsMask    =  Bus_0_aBitsMask    ;
        Bus_D_reg_aBitsData    =  Bus_0_aBitsData    ;
        Bus_D_reg_aBitsParam   =  Bus_0_aBitsParam   ;
        Bus_D_reg_aBitsSource  =  Bus_0_aBitsSource  ;
        Bus_D_reg_aBitsCorrupt =  Bus_0_aBitsCorrupt ;
        end
      else
        begin
        Bus_D_reg_dBitsReady   =  0 ;
        Bus_0_reg_dBitsValid   =  0 ;
        Bus_0_reg_dBitsOpcode  =  0 ;
        Bus_0_reg_dBitsData    =  0 ;
        Bus_0_reg_dBitsParam   =  0 ;
        Bus_0_reg_dBitsSource  =  0 ;
        Bus_0_reg_dBitsSink    =  0 ;
        Bus_0_reg_dBitsDennied =  0 ;
        Bus_0_reg_dBitsCorrupt =  0 ;
        Bus_0_reg_dBitsSize    =  0 ;

        Bus_0_reg_aBitsReady   =  0 ;
        Bus_D_reg_aBitsValid   =  0 ;
        Bus_D_reg_aBitsAddress =  0 ;
        Bus_D_reg_aBitsOpcode  =  0 ;
        Bus_D_reg_aBitsSize    =  0 ;
        Bus_D_reg_aBitsMask    =  0 ;
        Bus_D_reg_aBitsData    =  0 ;
        Bus_D_reg_aBitsParam   =  0 ;
        Bus_D_reg_aBitsSource  =  0 ;
        Bus_D_reg_aBitsCorrupt =  0 ;
        end
    end
//D channel signal 
assign  Bus_D_dBitsReady   = Bus_D_reg_dBitsReady   ;
assign  Bus_0_dBitsValid   = Bus_0_reg_dBitsValid   ;
assign  Bus_0_dBitsOpcode  = Bus_0_reg_dBitsOpcode  ;
assign  Bus_0_dBitsData    = Bus_0_reg_dBitsData    ;
assign  Bus_0_dBitsParam   = Bus_0_reg_dBitsParam   ;
assign  Bus_0_dBitsSource  = Bus_0_reg_dBitsSource  ;
assign  Bus_0_dBitsSink    = Bus_0_reg_dBitsSink    ;
assign  Bus_0_dBitsDennied = Bus_0_reg_dBitsDennied ;
assign  Bus_0_dBitsCorrupt = Bus_0_reg_dBitsCorrupt ;
assign  Bus_0_dBitsSize    = Bus_0_reg_dBitsSize    ;
//A channel signal
assign  Bus_0_aBitsReady   = Bus_0_reg_aBitsReady   ;
assign  Bus_D_aBitsValid   = Bus_D_reg_aBitsValid   ;
assign  Bus_D_aBitsAddress = Bus_D_reg_aBitsAddress ;
assign  Bus_D_aBitsOpcode  = Bus_D_reg_aBitsOpcode  ;
assign  Bus_D_aBitsSize    = Bus_D_reg_aBitsSize    ;
assign  Bus_D_aBitsMask    = Bus_D_reg_aBitsMask    ;
assign  Bus_D_aBitsData    = Bus_D_reg_aBitsData    ;
assign  Bus_D_aBitsParam   = Bus_D_reg_aBitsParam   ;
assign  Bus_D_aBitsSource  = Bus_D_reg_aBitsSource  ;
assign  Bus_D_aBitsCorrupt = Bus_D_reg_aBitsCorrupt ;

//transform  Icache signal
always@(*)
    begin
      if((Core_CacheAddr_xbar_I >= 32'h80000000) && (Core_CacheAddr_xbar_I <= 32'h80003fff))
        begin
        //D channel signal 
        Bus_I_reg_dBitsReady     =  Bus_1_dBitsReady   ;
        Bus_1_reg_dBitsValid     =  Bus_I_dBitsValid   ;
        Bus_1_reg_dBitsOpcode    =  Bus_I_dBitsOpcode  ;
        Bus_1_reg_dBitsData      =  Bus_I_dBitsData    ;
        Bus_1_reg_dBitsParam     =  Bus_I_dBitsParam   ;
        Bus_1_reg_dBitsSource    =  Bus_I_dBitsSource  ;
        Bus_1_reg_dBitsSink      =  Bus_I_dBitsSink    ;
        Bus_1_reg_dBitsDennied   =  Bus_I_dBitsDennied ;
        Bus_1_reg_dBitsCorrupt   =  Bus_I_dBitsCorrupt ;
        Bus_1_reg_dBitsSize      =  Bus_I_dBitsSize    ;
        //A channel signal
        Bus_1_reg_aBitsReady     =  Bus_I_aBitsReady   ;
        Bus_I_reg_aBitsValid     =  Bus_1_aBitsValid   ;
        Bus_I_reg_aBitsAddress   =  Bus_1_aBitsAddress ;
        Bus_I_reg_aBitsOpcode    =  Bus_1_aBitsOpcode  ;
        Bus_I_reg_aBitsSize      =  Bus_1_aBitsSize    ;
        Bus_I_reg_aBitsMask      =  Bus_1_aBitsMask    ;
        Bus_I_reg_aBitsData      =  Bus_1_aBitsData    ;
        Bus_I_reg_aBitsParam     =  Bus_1_aBitsParam   ;
        Bus_I_reg_aBitsSource    =  Bus_1_aBitsSource  ;
        Bus_I_reg_aBitsCorrupt   =  Bus_1_aBitsCorrupt ;
        end
      else
        begin
        Bus_I_reg_dBitsReady     =  0 ;
        Bus_1_reg_dBitsValid     =  0 ;
        Bus_1_reg_dBitsOpcode    =  0 ;
        Bus_1_reg_dBitsData      =  0 ;
        Bus_1_reg_dBitsParam     =  0 ;
        Bus_1_reg_dBitsSource    =  0 ;
        Bus_1_reg_dBitsSink      =  0 ;
        Bus_1_reg_dBitsDennied   =  0 ;
        Bus_1_reg_dBitsCorrupt   =  0 ;
        Bus_1_reg_dBitsSize      =  0 ;

        Bus_1_reg_aBitsReady     =  0 ;
        Bus_I_reg_aBitsValid     =  0 ;
        Bus_I_reg_aBitsAddress   =  0 ;
        Bus_I_reg_aBitsOpcode    =  0 ;
        Bus_I_reg_aBitsSize      =  0 ;
        Bus_I_reg_aBitsMask      =  0 ;
        Bus_I_reg_aBitsData      =  0 ;
        Bus_I_reg_aBitsParam     =  0 ;
        Bus_I_reg_aBitsSource    =  0 ;
        Bus_I_reg_aBitsCorrupt   =  0 ;
        end

    end
//D channel signal 
assign  Bus_I_dBitsReady   = Bus_I_reg_dBitsReady   ;
assign  Bus_1_dBitsValid   = Bus_1_reg_dBitsValid   ;
assign  Bus_1_dBitsOpcode  = Bus_1_reg_dBitsOpcode  ;
assign  Bus_1_dBitsData    = Bus_1_reg_dBitsData    ;
assign  Bus_1_dBitsParam   = Bus_1_reg_dBitsParam   ;
assign  Bus_1_dBitsSource  = Bus_1_reg_dBitsSource  ;
assign  Bus_1_dBitsSink    = Bus_1_reg_dBitsSink    ;
assign  Bus_1_dBitsDennied = Bus_1_reg_dBitsDennied ;
assign  Bus_1_dBitsCorrupt = Bus_1_reg_dBitsCorrupt ;
assign  Bus_1_dBitsSize    = Bus_1_reg_dBitsSize    ;
//A channel signal
assign  Bus_1_aBitsReady   = Bus_1_reg_aBitsReady   ;
assign  Bus_I_aBitsValid   = Bus_I_reg_aBitsValid   ;
assign  Bus_I_aBitsAddress = Bus_I_reg_aBitsAddress ;
assign  Bus_I_aBitsOpcode  = Bus_I_reg_aBitsOpcode  ;
assign  Bus_I_aBitsSize    = Bus_I_reg_aBitsSize    ;
assign  Bus_I_aBitsMask    = Bus_I_reg_aBitsMask    ;
assign  Bus_I_aBitsData    = Bus_I_reg_aBitsData    ;
assign  Bus_I_aBitsParam   = Bus_I_reg_aBitsParam   ;
assign  Bus_I_aBitsSource  = Bus_I_reg_aBitsSource  ;
assign  Bus_I_aBitsCorrupt = Bus_I_reg_aBitsCorrupt ;

endmodule