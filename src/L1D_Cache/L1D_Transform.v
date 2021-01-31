//************************************************************************************************
//************************************************************************************************
//*****************This module is used to transmit dara between Bus  and cache********************
//************************************************************************************************
//************************************************************************************************
`include "../src/common/Define.v"
module L1D_Transform(
//----top----
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  Core_CacheAddr,           //addr from core to cache
    input  wire         Core_CacheEn,             //
    input  wire [31:0]  Bus_hand_dBitsData,       //data from Bus to cache[read]
    input  wire         Bus_hand_RW,              //opcode 0/write 1/read 
    output wire [31:0]  Bus_hand_aBitsData,       //data from cache to Bus[write]  
    output wire [31:0]  Bus_hand_aBitsAddress,    //address sent to Bus <write or read data from cache>
//----FSM module----
    input  wire [1:0]   FSM_current_state,        //signal from FSM module 
    input  wire [1:0]   FSM_current_state2, 
    output wire         Transform_BusRdDone_cnt,
//----RAM module----
    input  wire [127:0] RAM_DataWrt,              //core---->cache wt,data_reg between cache and Bus
    output wire         Transform_BusWrtDone,Transform_BusRdDone,   //output to FSM to control the state jump of FSM    
    output wire [127:0] Transform_BusDataRdBuff,  //cache<----Bus rd
//----Bus_hand module----
    input  wire         Bus_hand_DataRdBusCond,   //read data from Bus to cache condition
    input  wire         Bus_hand_DataWrtBusCond   //write data from Bus to cache condition
    );

//--------FSM signal from FSM module--------
localparam  Idle       = 2'b00;
localparam  WriteBus   = 2'b01;
localparam  ReadBus    = 2'b10;
localparam  WriteCache = 2'b11;

//--------data reg between cache and Bus--------         
reg [127:0] data_wt_buff_cache_Bus_reg; //cache---->Bus wt
reg [127:0] data_rd_buff_cache_Bus_reg; //cache---->Bus wt
reg [31:0]  a_bits_address_buf01;
reg [31:0]  a_bits_address_buf02;

reg         data_wt_cache_Bus_cond_reg;
reg         data_rd_cache_Bus_cond_reg;
reg         Transform_BusRdDone_cnt0;
//--------read data cache<----Bus--------
/*always@(posedge clk or negedge rst_n) 
  begin
    if(!rst_n)
      data_rd_cache_Bus_cond_reg <= 0;
    else
      data_rd_cache_Bus_cond_reg <= Bus_hand_DataRdBusCond;
  end
  */
/*reg   current_state_rd,next_state_rd;
localparam idle_rd   =1'b0;
localparam shift_rd   =1'b1;
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      current_state_rd <= idle_rd;
    else
      current_state_rd <= next_state_rd;
  end
always@(*)
  begin
    case(current_state_rd)
      1'b0:    
        if((FSM_current_state == ReadBus) && Bus_hand_DataRdBusCond && a_bits_address_buf01[3:2] <= 2'b10)
                next_state_rd = shift_rd;
        else 
                next_state_rd = idle_rd;
      1'b1:     
        if(a_bits_address_buf01[3:2] == 2'b10)
                next_state_rd = idle_rd;
        else
                next_state_rd = shift_rd;
       default: next_state_rd = idle_rd;
    endcase
  end*/
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)   
      a_bits_address_buf01 <= 32'b0;
    else if( a_bits_address_buf01[3:2] == 'd3 )
      a_bits_address_buf01 <= 32'b0;
    //else if((FSM_current_state == ReadBus) && ( current_state_rd == shift_rd ) && Bus_hand_DataRdBusCond && !Transform_BusRdDone)      //delay 1 clk, then plus 4 to address    
    //else if(( current_state_rd == shift_rd ) && Bus_hand_DataRdBusCond && !Transform_BusRdDone)      //delay 1 clk, then plus 4 to address    
    else if(( FSM_current_state == ReadBus ) && Bus_hand_DataRdBusCond && !Transform_BusRdDone)      //delay 1 clk, then plus 4 to address    
      a_bits_address_buf01 <= a_bits_address_buf01 + 'd4;                     //plus address 
    //else if(( FSM_current_state == ReadBus ) && ( current_state_rd == idle_rd ) && Bus_hand_DataRdBusCond && !Transform_BusRdDone)    
    //else if(( current_state_rd == idle_rd ) && Bus_hand_DataRdBusCond && !Transform_BusRdDone)    
    else if(( FSM_current_state == Idle ) && !Transform_BusRdDone)    
      a_bits_address_buf01 <= {Core_CacheAddr[31:4],4'b0};                    //capture original address
  end
//--------read Bus_hand_dBitsData from Bus to Cache && shift left 32bits per clk--------
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n) 
      data_rd_buff_cache_Bus_reg <= 127'b0;
   else if(( FSM_current_state == ReadBus ) && Bus_hand_DataRdBusCond && !Transform_BusRdDone) 
      data_rd_buff_cache_Bus_reg <= {Bus_hand_dBitsData,data_rd_buff_cache_Bus_reg[127:32]};  //capture data && shift left 32bits per clk
  end 

assign Transform_BusDataRdBuff = data_rd_buff_cache_Bus_reg;

reg Transform_BusRdDone_reg;
//assign Transform_BusRdDone     = (a_bits_address_buf01[3:2] == 'd3)? 1:0; 
always@(posedge clk or negedge rst_n)
  begin
    if(a_bits_address_buf01[3:2] == 'd3)
      Transform_BusRdDone_reg <= 1;
    else
      Transform_BusRdDone_reg <= 0;
  end
assign Transform_BusRdDone  = Transform_BusRdDone_reg;


reg [31:0]   Core_CacheAddr_reg;
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      Core_CacheAddr_reg <= 32'b0;
    else
      Core_CacheAddr_reg <= Core_CacheAddr;
  end


always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      Transform_BusRdDone_cnt0 <= 'b0;
    else if(!Core_CacheEn)
      Transform_BusRdDone_cnt0 <= 'b0;
    else if(Transform_BusRdDone)
      Transform_BusRdDone_cnt0 <= Transform_BusRdDone_cnt0 + 'b1;
  end
assign  Transform_BusRdDone_cnt = ( Core_CacheAddr_reg != Core_CacheAddr)?0:Transform_BusRdDone_cnt0;
//this signal is used to control FSM Id->WB, if read Bus is done, FSM should not transform in once write or read

//--------write data cache---->Bus--------
reg        current_state_wt,next_state_wt;
localparam idle_wt   =1'b0;
localparam shift_wt  =1'b1;
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      current_state_wt <= idle_wt;
    else
      current_state_wt <= next_state_wt;
  end
always@(*)
  begin
    case(current_state_wt)
      1'b0:    
        if(( FSM_current_state == WriteBus ) && Bus_hand_DataWrtBusCond && ( a_bits_address_buf02[3:2] <= 2'b10 ))
                next_state_wt = shift_wt;
        else 
                next_state_wt = idle_wt;
      1'b1:     
        if(a_bits_address_buf02[3:2] == 2'b10)
                next_state_wt = idle_wt;
        else
                next_state_wt = shift_wt;
       default: next_state_wt = idle_wt;
    endcase
  end
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)   
      a_bits_address_buf02 <= 32'b0;
    else if( a_bits_address_buf02[3:2] == 'd3 )
      a_bits_address_buf02 <= 32'b0;
    else if((FSM_current_state == WriteBus) && ( current_state_wt == shift_wt ) && Bus_hand_DataWrtBusCond && !Transform_BusWrtDone)    //delay 1 clk, then plus 4 to address
      a_bits_address_buf02 <= a_bits_address_buf02 + 'd4;             //plus address
    else if((FSM_current_state == WriteBus) && ( current_state_wt == idle_wt) && Bus_hand_DataWrtBusCond && !Transform_BusWrtDone)
      a_bits_address_buf02 <= {Core_CacheAddr[31:4],4'b0};           //capture original address
  end
//--------read RAM_DataWrt from cache && shift left 32 bits per clk--------
always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n)
      data_wt_buff_cache_Bus_reg <= 32'b0; 
    //else if(( FSM_current_state == WriteBus ) && ( current_state_wt == idle_wt ) && Bus_hand_DataWrtBusCond)   //delay 1 clk, then input RAM_DataWrt
    else if(( current_state_wt == idle_wt ) && Bus_hand_DataWrtBusCond)   //delay 1 clk, then input RAM_DataWrt
      data_wt_buff_cache_Bus_reg <= RAM_DataWrt;                                //capture data
    //else if(( FSM_current_state == WriteBus ) && ( current_state_wt == shift_wt ) && Bus_hand_DataWrtBusCond && !Transform_BusWrtDone)
    else if(( current_state_wt == shift_wt ) && Bus_hand_DataWrtBusCond && !Transform_BusWrtDone)
      data_wt_buff_cache_Bus_reg <= data_wt_buff_cache_Bus_reg >> 'd32;        //shift right 32bits per clk
  end
//--------output data && done signal--------
assign Bus_hand_aBitsData   = Bus_hand_DataWrtBusCond ? data_wt_buff_cache_Bus_reg[31:0] : 32'b0;
assign Transform_BusWrtDone = (a_bits_address_buf02[3:2] == 'd3)? 1:0;

//---------------generate output address to Bus---------------
assign Bus_hand_aBitsAddress = (Bus_hand_RW == 1)? a_bits_address_buf01:a_bits_address_buf02;  

endmodule