//************************************************************************************************
//************************************************************************************************
//*****************This module is used to transmit dara between core and cache********************
//************************************************************************************************
//************************************************************************************************
`include "../src/common/Define.v"
module L1I_Bus_hand(
//----top module----   
    //--------Bus to cache(read from Bus)[Allocate] D channel--------                          
    output wire        Bus_dBitsReady,        //ready = 1 when FSM == ReadBus
    input  wire        Bus_dBitsValid, 
    input  wire [2:0]  Bus_dBitsOpcode,       //opcode 0/AccessAck 1/AccessAckData
    input  wire [31:0] Bus_dBitsData,
        input  wire [1:0]  Bus_dBitsParam,    //param === 0 useless
    input  wire [4:0]  Bus_dBitsSource,       //means master ID,use 5'b00001 represent Dcache,5'b00010 represent Icache
    input  wire [1:0]  Bus_dBitsSink,         //the number of cache  01-Dcache 00-Icache
    input  wire        Bus_dBitsDennied,      //useless
    input  wire        Bus_dBitsCorrupt,      //A channel get (D channel AccessAckData):if ECC out is wrong, corrupt=1 else corrupt =0; A channel put(D channel AccessAck): corrupt === 0
    input  wire [3:0]  Bus_dBitsSize,         //size=5 means read 32bits from Bus 
    
    //--------cache to Bus(write to Bus)[Write Back] A channel--------
    input  wire        Bus_aBitsReady,
    output wire        Bus_aBitsValid,        //valid = 1 in Write Back state
    output wire [31:0] Bus_aBitsAddress,
    output wire [2:0]  Bus_aBitsOpcode,       //opcode = 0/put 4/get
    output wire [3:0]  Bus_aBitsSize,         //size = 5 full write
    output wire [3:0]  Bus_aBitsMask,         //mask = 'b1111
    output wire [31:0] Bus_aBitsData,         //mask = 'b1111
    output wire [2:0]  Bus_aBitsParam,        //param = 0
    output wire [4:0]  Bus_aBitsSource,       //master source = 00001 means Dcache request
    output wire        Bus_aBitsCorrupt,      //ECC check reserved
   
//----Transform module----    
    output wire        Bus_hand_DataWrtBusCond, //write data from Bus to cache condition
    output wire        Bus_hand_DataRdBusCond,  //read data from Bus to cache condition
    output wire [31:0] Bus_hand_dBitsData,
    output wire        Bus_hand_RW,
    input  wire [31:0] Bus_hand_aBitsData,
    input  wire [31:0] Bus_hand_aBitsAddress,

//----FSM module----
    input  wire [1:0]  FSM_current_state     
    //input  wire [1:0]  FSM_current_state2
    );

localparam  Idle       = 2'b00;
localparam  WriteBus   = 2'b01;
localparam  ReadBus    = 2'b10;
localparam  WriteCache = 2'b11;

assign Bus_hand_DataWrtBusCond = Bus_aBitsReady && Bus_dBitsValid && (Bus_dBitsSink==1) && (Bus_dBitsSource == Bus_aBitsSource)
                                && (Bus_dBitsCorrupt == 0) && (Bus_dBitsOpcode == 0) && (Bus_dBitsDennied == 0) && (Bus_dBitsSize == 'd2);
assign Bus_hand_DataRdBusCond  = Bus_aBitsReady && Bus_dBitsValid && (Bus_dBitsSink==1) && (Bus_dBitsSource == Bus_aBitsSource) 
                                && (Bus_dBitsCorrupt == 0) && (Bus_dBitsOpcode == 1) && (Bus_dBitsDennied == 0) && (Bus_dBitsSize == 'd2);

assign Bus_dBitsReady  = (FSM_current_state == ReadBus) ? 1:0;
assign Bus_aBitsMask   = 'b1111;
assign Bus_aBitsOpcode = (FSM_current_state == WriteBus)? 'd0:
                         (FSM_current_state == ReadBus) ? 'd4:0;
assign Bus_aBitsParam  = 0;
assign Bus_aBitsSize   = 'd2;
assign Bus_aBitsSource = 5'b00010;
assign Bus_aBitsValid  = (( FSM_current_state == WriteBus ) || ( FSM_current_state == ReadBus )) ? 1:0;
assign Bus_aBitsCorrupt= 0;    //We should design ECC check in RAM {(Bus_aBitsOpcode == 0)? 0:ECC;}, but for simplicity we set Corrupt ===0


assign Bus_hand_RW        = (Bus_aBitsOpcode == 'd4)? 1:0;
assign Bus_hand_dBitsData = Bus_dBitsData;

assign Bus_aBitsAddress= Bus_hand_aBitsAddress;
assign Bus_aBitsData   = Bus_hand_aBitsData;
endmodule