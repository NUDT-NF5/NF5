//************************************************************************************************
//************************************************************************************************
//*****************This module is used to transmit dara between Bus and SRAM********************
//************************************************************************************************
//************************************************************************************************
`include "../src/common/Define.v"
module Bus_hand_Icache(
//----top module----   
    input  wire clk,
    input  wire rst_n,
    //--------Bus to SRAM A channel_Dcache--------                          
    output wire        Bus_aBitsReady,        //ready = 1 when FSM == ReadBus
    input  wire        Bus_aBitsValid,  
    input  wire [31:0] Bus_aBitsAddress,
    input  wire [2:0]  Bus_aBitsOpcode,       //opcode 0/AccessAck 1/AccessAckData
    input  wire [3:0]  Bus_aBitsSize,         //size=5 means read 32bits from Bus 
    input  wire [3:0]  Bus_aBitsMask,         //mask = 'b1111
    input  wire [31:0] Bus_aBitsData,
    input  wire [2:0]  Bus_aBitsParam,        //param === 0 useless
    input  wire [4:0]  Bus_aBitsSource,       //means master ID, use 5'b00001 represent Dcache,5'b00010 represent Icache
    input  wire        Bus_aBitsCorrupt,      //A channel get (D channel AccessAckData):if ECC out is wrong, corrupt=1 else corrupt =0; A channel put(D channel AccessAck): corrupt === 0
    //--------SRAM to Bus D channel_Dcache--------
    input  wire        Bus_dBitsReady,
    output wire        Bus_dBitsValid,        //valid = 1 in Write Back state
    output wire [2:0]  Bus_dBitsOpcode,       //opcode = 0/put 4/get
    output wire [31:0] Bus_dBitsData,         //
    output wire [1:0]  Bus_dBitsParam,        //param = 0
    output wire [4:0]  Bus_dBitsSource,       //master source = 00001 means Dcache request
    output wire [1:0]  Bus_dBitsSink,         //unknown
    output wire        Bus_dBitsDennied,      //useless
    output wire        Bus_dBitsCorrupt,      //ECC check reserved
    output wire [3:0]  Bus_dBitsSize,         //size = 5 full write
    //----SRAM write read cond----    
    output wire        Bus_hand_DataWrtBusCond, //write data from Bus to cache condition
    output wire        Bus_hand_DataRdBusCond,  //read data from Bus to cache condition
    //----SRAM write enable address and data
    output wire [31:0] Bus_hand_aBitsData,
    output wire [31:0] Bus_hand_aBitsAddress,
    output wire        Bus_hand_RW,
    //----SRAM read data to Bus
    input  wire [31:0] Bus_hand_dBitsData       //read from SRAM 
    
    );
reg Bus_dBitsValid_reg;
assign Bus_hand_DataWrtBusCond = Bus_dBitsReady && Bus_aBitsValid && (Bus_aBitsSource == Bus_dBitsSource)
                                && (Bus_aBitsCorrupt == 0) && (Bus_aBitsOpcode == 0) && (Bus_aBitsSize == 'd2);
assign Bus_hand_DataRdBusCond  = Bus_dBitsReady && Bus_aBitsValid && (Bus_aBitsSource == Bus_dBitsSource) 
                                && (Bus_aBitsCorrupt == 0) && (Bus_aBitsOpcode == 4) && (Bus_aBitsSize == 'd2);
assign Bus_aBitsReady  = 1;
always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        Bus_dBitsValid_reg <= 0;
      else if( Bus_aBitsValid )
        Bus_dBitsValid_reg <= 1;
      else
        Bus_dBitsValid_reg <=0;
    end
assign Bus_dBitsValid  = Bus_dBitsValid_reg;
assign Bus_dBitsOpcode = (Bus_aBitsOpcode == 0 )? 'd0:
                         (Bus_aBitsOpcode == 4 )? 'd1:0;
assign Bus_dBitsData   = Bus_hand_dBitsData;
assign Bus_dBitsParam  = 0;
assign Bus_dBitsSource = 5'b00010;
assign Bus_dBitsSink   = 1;
assign Bus_dBitsMask   = 'b1111;
assign Bus_dBitsDennied = 0;
assign Bus_dBitsCorrupt = 0;    //We should design ECC check in RAM {(Bus_aBitsOpcode == 0)? 0:ECC;}, but for simplicity we set Corrupt ===0
assign Bus_dBitsSize    = 'd2;
assign Bus_hand_RW        = 1;
assign Bus_hand_aBitsData = Bus_aBitsData;
assign Bus_hand_aBitsAddress = Bus_aBitsAddress;
endmodule