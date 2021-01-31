//************************************************************************************************
//************************************************************************************************
//*****************This module is used to describe the cache RAM**********************************
//************************************************************************************************
//************************************************************************************************
//`include "L1I_Bus_hand.v"
//`include "L1I_Transform.v"
//`include "L1I_FSM.v"
//`include "L1I_RAM.v"
`include "../src/common/Define.v"
module L1I_Cache
#(parameter  Cache_depth   = 9'd511+1)
(
//core
    input  wire         clk,
    input  wire         rst_n,
    input  wire         Core_CacheRd,          //1/read 0/write
    input  wire         Core_CacheEn,
    input  wire         Core_CacheSign,
    input  wire [31:0]  Core_CacheAddr,        //addr from core to cache
    input  wire [31:0]  Core_CacheData,        //input data from core to cache [write]
    input  wire [1:0]   Core_CacheWidth,       //input access data width from core to cache 00/byte---01/half_word---10/word
    output wire [31:0]  Cache_DataRd,          //output data to core
    output wire         Cache_StallReq,        //output signal to control unit
        output wire [31:0]  Core_CacheAddr_xbar,
//tilelink a channel
    input  wire         Bus_aBitsReady,
    output wire         Bus_aBitsValid,        //valid = 1 in Write Back state
    output wire [31:0]  Bus_aBitsAddress,      //address sent to Bus <write or read data from cache>
    output wire [2:0]   Bus_aBitsOpcode,       //opcode = 0/put 4/get
    output wire [3:0]   Bus_aBitsSize,         //size = 5 full write
    output wire [3:0]   Bus_aBitsMask,         //mask = 'b1111
    output wire [31:0]  Bus_aBitsData,         //data from cache to Bus[write]  
    output wire [2:0]   Bus_aBitsParam,        //param === 0
    output wire [4:0]   Bus_aBitsSource,       //master source = 00001 means Dcache request
    output wire         Bus_aBitsCorrupt,      //A channel get (D channel AccessAckData):if ECC out is wrong, corrupt=1 else corrupt =0; A channel put(D channel AccessAck): corrupt === 0
//tilelink d channel
    output wire         Bus_dBitsReady,        //ready = 1 in Allocate
    input  wire         Bus_dBitsValid,
    input  wire [2:0]   Bus_dBitsOpcode,       //opcode 0/AccessAck  1/AccessAckData
    input  wire [31:0]  Bus_dBitsData,         //data from Bus to cache[read]
    input  wire [1:0]   Bus_dBitsParam,        //param === 0 
    input  wire [4:0]   Bus_dBitsSource,       //means master ID
    input  wire [1:0]   Bus_dBitsSink,         //the number of cache  01-Dcache 00-Icache
    input  wire         Bus_dBitsDennied,      //useless
    input  wire         Bus_dBitsCorrupt,      //A channel get (D channel AccessAckData):if ECC out is wrong, corrupt=1 else corrupt =0; A channel put(D channel AccessAck): corrupt === 0
    input  wire [3:0]   Bus_dBitsSize,         //useless //size=5 means read 32bits from Bus 
    //from Dcache to snoop
    input  wire [31:0]  Dcache_DataRd,         //input from D-Cache for data read to core
    input  wire         Dcache_Dirty,          //input from D-Cache for judging, select data read to core 
    output wire [31:0]  Icache_PC
    );

wire         Bus_hand_DataWrtBusCond;
wire         Bus_hand_DataRdBusCond;
wire [1:0]   FSM_current_state;     
wire [1:0]   FSM_current_state2;
wire [1:0]   FSM_next_state;
wire [127:0] RAM_DataWrt;                      //core---->cache wt,data_reg between cache and Bus
wire         Transform_BusWrtDone,Transform_BusRdDone;   //output to FSM to control the state jump of FSM    
wire [127:0] Transform_BusDataRdBuff;          //cache<----Bus rd
wire         RAM_ID_WB_cond;
wire         RAM_ID_RB_cond;
wire         RAM_ID_WC_cond;
wire         RAM_WB_RB_cond;
//wire         RAM_RB_ID_cond;
wire         RAM_RB_WC_cond;
wire         modefied;
wire         Transform_BusRdDone_cnt;
//signals between Bus_hand and Transform
wire         Bus_hand_RW;
wire [31:0]  Bus_hand_dBitsData;
wire [31:0]  Bus_hand_aBitsData;
wire [31:0]  Bus_hand_aBitsAddress;
    assign Core_CacheAddr_xbar = Core_CacheAddr;
L1I_Bus_hand i_L1I_Bus_hand(
//top
  .Bus_dBitsReady(Bus_dBitsReady),
  .Bus_dBitsValid(Bus_dBitsValid),
  .Bus_dBitsOpcode(Bus_dBitsOpcode),
  .Bus_dBitsData(Bus_dBitsData),
  .Bus_dBitsParam(Bus_dBitsParam),
  .Bus_dBitsSource(Bus_dBitsSource),
  .Bus_dBitsSink(Bus_dBitsSink),
  .Bus_dBitsDennied(Bus_dBitsDennied),
  .Bus_dBitsCorrupt(Bus_dBitsCorrupt),
  .Bus_dBitsSize(Bus_dBitsSize),
  
  .Bus_aBitsReady(Bus_aBitsReady),
  .Bus_aBitsValid(Bus_aBitsValid),
  .Bus_aBitsAddress(Bus_aBitsAddress),
  .Bus_aBitsOpcode(Bus_aBitsOpcode),
  .Bus_aBitsSize(Bus_aBitsSize),
  .Bus_aBitsMask(Bus_aBitsMask),
  .Bus_aBitsData(Bus_aBitsData),
  .Bus_aBitsParam(Bus_aBitsParam),
  .Bus_aBitsSource(Bus_aBitsSource),
  .Bus_aBitsCorrupt(Bus_aBitsCorrupt),
 //Bus data transform
  .Bus_hand_DataWrtBusCond(Bus_hand_DataWrtBusCond),
  .Bus_hand_DataRdBusCond(Bus_hand_DataRdBusCond),
  .Bus_hand_dBitsData(Bus_hand_dBitsData),
  .Bus_hand_RW(Bus_hand_RW),

  .Bus_hand_aBitsData(Bus_hand_aBitsData),
  .Bus_hand_aBitsAddress(Bus_hand_aBitsAddress),
  //FSM
  .FSM_current_state(FSM_current_state)
  //.current_state2(current_state2)

);

L1I_Transform i_L1I_Transform(
//top
  .clk(clk),
  .rst_n(rst_n),
  .Core_CacheAddr(Core_CacheAddr),
  .Core_CacheEn(Core_CacheEn),
  .Bus_hand_dBitsData(Bus_hand_dBitsData),
  .Bus_hand_RW(Bus_hand_RW),

  .Bus_hand_aBitsData(Bus_hand_aBitsData),
  .Bus_hand_aBitsAddress(Bus_hand_aBitsAddress),
//FSM
  .FSM_current_state(FSM_current_state),
  .FSM_current_state2(FSM_current_state2),

  .Transform_BusRdDone_cnt(Transform_BusRdDone_cnt),
//RAM
  .RAM_DataWrt(RAM_DataWrt),
  
  .Transform_BusWrtDone(Transform_BusWrtDone),
  .Transform_BusRdDone(Transform_BusRdDone),
  .Transform_BusDataRdBuff(Transform_BusDataRdBuff),
//Bus output
  .Bus_hand_DataRdBusCond(Bus_hand_DataRdBusCond),
  .Bus_hand_DataWrtBusCond(Bus_hand_DataWrtBusCond)
  
);

L1I_FSM i_L1I_FSM(
//top
  .clk(clk),
  .rst_n(rst_n),
  .Core_CacheRd(Core_CacheRd),
  .Core_CacheEn(Core_CacheEn),
  
//FSM
  .RAM_ID_WB_cond(RAM_ID_WB_cond),
  .RAM_ID_RB_cond(RAM_ID_RB_cond),
  .RAM_ID_WC_cond(RAM_ID_WC_cond),
  .RAM_WB_RB_cond(RAM_WB_RB_cond),
  //.RAM_RB_ID_cond(RAM_RB_ID_cond),
  .RAM_RB_WC_cond(RAM_RB_WC_cond),
  .modefied(modefied),
  
  .FSM_current_state(FSM_current_state),
  .FSM_current_state2(FSM_current_state2),
  .FSM_next_state(FSM_next_state),
  //Transform
  .Transform_BusRdDone_cnt(Transform_BusRdDone_cnt)
);
L1I_RAM i_L1I_RAM(
//top
  .clk(clk),
  .rst_n(rst_n),
  .Core_CacheAddr(Core_CacheAddr),
  .Core_CacheRd(Core_CacheRd),
  .Core_CacheEn(Core_CacheEn),
  .Core_CacheSign(Core_CacheSign),
  .Core_CacheData(Core_CacheData),
  .Core_CacheWidth(Core_CacheWidth),
  .Dcache_DataRd(Dcache_DataRd),
  .Dcache_Dirty(Dcache_Dirty),
  
  .Cache_DataRd(Cache_DataRd),
  .Icache_StallReq(Cache_StallReq),
  .Icache_PC(Icache_PC),
//FSM
  .FSM_current_state(FSM_current_state),
  .FSM_current_state2(FSM_current_state2),
  .FSM_next_state(FSM_next_state),
  
  .RAM_ID_WB_cond(RAM_ID_WB_cond),
  .RAM_ID_RB_cond(RAM_ID_RB_cond),
  .RAM_ID_WC_cond(RAM_ID_WC_cond),
  .RAM_WB_RB_cond(RAM_WB_RB_cond),
  //.RAM_RB_ID_cond(RAM_RB_ID_cond),
  .RAM_RB_WC_cond(RAM_RB_WC_cond),
  .modefied(modefied),
//Bus transform
  .Transform_BusWrtDone(Transform_BusWrtDone),
  .Transform_BusRdDone(Transform_BusRdDone),
  .Transform_BusDataRdBuff(Transform_BusDataRdBuff),
  
  .RAM_DataWrt(RAM_DataWrt)
);

endmodule