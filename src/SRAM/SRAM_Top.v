//************************************************************************************************
//************************************************************************************************
//*****************This module is used to describe the cache RAM**********************************
//************************************************************************************************
//************************************************************************************************
`include "../src/common/Define.v"
module SRAM_Top
(
//core
    input  wire         clk,
    input  wire         rst_n,
//tilelink d channel(Dcache)
    input  wire          Bus_D_dBitsReady   , 
    output wire          Bus_D_dBitsValid   ,  
    output wire [2:0]    Bus_D_dBitsOpcode  ,  
    output wire [31:0]   Bus_D_dBitsData    ,  
    output wire [1:0]    Bus_D_dBitsParam   ,  
    output wire [4:0]    Bus_D_dBitsSource  ,  
    output wire [1:0]    Bus_D_dBitsSink    ,  
    output wire          Bus_D_dBitsDennied ,  
    output wire          Bus_D_dBitsCorrupt ,  
    output wire [3:0]    Bus_D_dBitsSize    ,  
   
//tilelink a channel(Dcache)
    output wire          Bus_D_aBitsReady    ,  
    input  wire          Bus_D_aBitsValid    ,  
    input  wire [31:0]   Bus_D_aBitsAddress  ,  
    input  wire [2:0]    Bus_D_aBitsOpcode   ,  
    input  wire [3:0]    Bus_D_aBitsSize     ,  
    input  wire [3:0]    Bus_D_aBitsMask     ,  
    input  wire [31:0]   Bus_D_aBitsData     ,  
    input  wire [2:0]    Bus_D_aBitsParam    ,  
    input  wire [4:0]    Bus_D_aBitsSource   ,  
    input  wire          Bus_D_aBitsCorrupt  , 
//tilelink d channel(Icache)
    input  wire          Bus_I_dBitsReady   , 
    output wire          Bus_I_dBitsValid   ,  
    output wire [2:0]    Bus_I_dBitsOpcode  ,  
    output wire [31:0]   Bus_I_dBitsData    ,  
    output wire [1:0]    Bus_I_dBitsParam   ,  
    output wire [4:0]    Bus_I_dBitsSource  ,  
    output wire [1:0]    Bus_I_dBitsSink    ,  
    output wire          Bus_I_dBitsDennied ,  
    output wire          Bus_I_dBitsCorrupt ,  
    output wire [3:0]    Bus_I_dBitsSize    ,  
   
//tilelink a channel(Icache)
    output wire          Bus_I_aBitsReady    ,  
    input  wire          Bus_I_aBitsValid    ,  
    input  wire [31:0]   Bus_I_aBitsAddress  ,  
    input  wire [2:0]    Bus_I_aBitsOpcode   ,  
    input  wire [3:0]    Bus_I_aBitsSize     ,  
    input  wire [3:0]    Bus_I_aBitsMask     ,  
    input  wire [31:0]   Bus_I_aBitsData     ,  
    input  wire [2:0]    Bus_I_aBitsParam    ,  
    input  wire [4:0]    Bus_I_aBitsSource   ,  
    input  wire          Bus_I_aBitsCorrupt  
    );

wire         Bus_hand_D_DataWrtBusCond ;  
wire         Bus_hand_D_DataRdBusCond  ;  
wire [31:0]  Bus_hand_D_aBitsData      ;    
wire [31:0]  Bus_hand_D_aBitsAddress   ;
wire         Bus_hand_D_RW             ;
wire [31:0]  Bus_hand_D_dBitsData      ;  
wire         Bus_hand_I_DataRdBusCond  ;         
wire [31:0]  Bus_hand_I_aBitsData      ;     
wire [31:0]  Bus_hand_I_aBitsAddress   ;       
wire [31:0]  Bus_hand_I_dBitsData      ;    

Bus_hand_Dcache i_Bus_hand_Dcache(
.clk                      (clk),
.rst_n                    (rst_n),
.Bus_aBitsReady           (Bus_D_aBitsReady),        
.Bus_aBitsValid           (Bus_D_aBitsValid),
.Bus_aBitsAddress         (Bus_D_aBitsAddress),
.Bus_aBitsOpcode          (Bus_D_aBitsOpcode),       
.Bus_aBitsSize            (Bus_D_aBitsSize),         
.Bus_aBitsMask            (Bus_D_aBitsMask),        
.Bus_aBitsData            (Bus_D_aBitsData),
.Bus_aBitsParam           (Bus_D_aBitsParam),       
.Bus_aBitsSource          (Bus_D_aBitsSource),      
.Bus_aBitsCorrupt         (Bus_D_aBitsCorrupt),    

.Bus_dBitsReady           (Bus_D_dBitsReady),
.Bus_dBitsValid           (Bus_D_dBitsValid),       
.Bus_dBitsOpcode          (Bus_D_dBitsOpcode),       
.Bus_dBitsData            (Bus_D_dBitsData),        
.Bus_dBitsParam           (Bus_D_dBitsParam),       
.Bus_dBitsSource          (Bus_D_dBitsSource),      
.Bus_dBitsSink            (Bus_D_dBitsSink),         
.Bus_dBitsDennied         (Bus_D_dBitsDennied),      
.Bus_dBitsCorrupt         (Bus_D_dBitsCorrupt),      
.Bus_dBitsSize            (Bus_D_dBitsSize),       

.Bus_hand_DataWrtBusCond  (Bus_hand_D_DataWrtBusCond),
.Bus_hand_DataRdBusCond   (Bus_hand_D_DataRdBusCond),

.Bus_hand_aBitsData       (Bus_hand_D_aBitsData),
.Bus_hand_aBitsAddress    (Bus_hand_D_aBitsAddress),
.Bus_hand_RW              (Bus_hand_D_RW),

.Bus_hand_dBitsData       (Bus_hand_D_dBitsData)     

);

Bus_hand_Icache i_Bus_hand_Icache(
.clk                      (clk),
.rst_n                    (rst_n),
.Bus_aBitsReady           (Bus_I_aBitsReady),        
.Bus_aBitsValid           (Bus_I_aBitsValid),
.Bus_aBitsAddress         (Bus_I_aBitsAddress),
.Bus_aBitsOpcode          (Bus_I_aBitsOpcode),       
.Bus_aBitsSize            (Bus_I_aBitsSize),         
.Bus_aBitsMask            (Bus_I_aBitsMask),        
.Bus_aBitsData            (Bus_I_aBitsData),
.Bus_aBitsParam           (Bus_I_aBitsParam),       
.Bus_aBitsSource          (Bus_I_aBitsSource),      
.Bus_aBitsCorrupt         (Bus_I_aBitsCorrupt),    

.Bus_dBitsReady           (Bus_I_dBitsReady),
.Bus_dBitsValid           (Bus_I_dBitsValid),       
.Bus_dBitsOpcode          (Bus_I_dBitsOpcode),       
.Bus_dBitsData            (Bus_I_dBitsData),        
.Bus_dBitsParam           (Bus_I_dBitsParam),       
.Bus_dBitsSource          (Bus_I_dBitsSource),      
.Bus_dBitsSink            (Bus_I_dBitsSink),         
.Bus_dBitsDennied         (Bus_I_dBitsDennied),      
.Bus_dBitsCorrupt         (Bus_I_dBitsCorrupt),      
.Bus_dBitsSize            (Bus_I_dBitsSize),       

.Bus_hand_DataWrtBusCond  (),
.Bus_hand_DataRdBusCond   (Bus_hand_I_DataRdBusCond),

.Bus_hand_aBitsData       (Bus_hand_I_aBitsData),
.Bus_hand_aBitsAddress    (Bus_hand_I_aBitsAddress),
.Bus_hand_RW              (),

.Bus_hand_dBitsData       (Bus_hand_I_dBitsData)     

);

SRAM i_SRAM(
.clk                        (clk           ),
.rst_n                      (rst_n         ),
.Dcahe_RW                   (Bus_hand_D_RW      ),
.Dcache_En                  (Bus_D_dBitsValid     ),
.Bus_hand_D_DataWrtBusCond  (Bus_hand_D_DataWrtBusCond),
.Bus_hand_D_DataRdBusCond   (Bus_hand_D_DataRdBusCond ),
.Dcache_Addr                (Bus_hand_D_aBitsAddress   ),
.Dcache_DataIn              (Bus_hand_D_aBitsData ),
.Dcache_DataOut             (Bus_hand_D_dBitsData),

.Bus_hand_I_DataRdBusCond   (Bus_hand_I_DataRdBusCond),
.Icache_Addr                (Bus_hand_I_aBitsAddress   ),
.Icache_DataOut             (Bus_hand_I_dBitsData)
);

endmodule