//************************************************************************************************
//************************************************************************************************
//*****************This module is used to describe the cache RAM**********************************
//************************************************************************************************
//************************************************************************************************
`include "../src/common/Define.v"
module L1I_RAM
#(parameter  Cache_depth   = 9'd511+1)
(
//----top module----    
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  Core_CacheAddr,        //input addr from core to cache
    input  wire         Core_CacheRd,
    input  wire [31:0]  Core_CacheData,        //input data from core to cache [write]
    input  wire [1:0]   Core_CacheWidth,       //input access data width from core to cache 00/byte---01/half_word---10/word
    input  wire         Core_CacheEn,
    input  wire         Core_CacheSign,
    output wire [31:0]  Cache_DataRd,          //output data to core
    output wire         Icache_StallReq,        //output signal to control unit
   //snooping Icache, data from Icache
    input  wire [31:0]  Dcache_DataRd,         //input from D-Cache for data read to core
    input  wire         Dcache_Dirty,          //input from D-Cache for judging, select data read to core 
    output wire [31:0]  Icache_PC,
//----FSM module----
    input  wire [1:0]   FSM_current_state,     //FSM state
    input  wire [1:0]   FSM_current_state2,
    input  wire         FSM_next_state,
    output wire         RAM_ID_WB_cond,        //FSM state jump condition
    output wire         RAM_ID_RB_cond,
    output wire         RAM_ID_WC_cond,
    output wire         RAM_WB_RB_cond,
    //output wire         RAM_RB_ID_cond,
    output wire         RAM_RB_WC_cond,
    output wire         modefied,
//----Transform module----
    input  wire         Transform_BusWrtDone,  //Bus finish rd/wt signal 
    input  wire         Transform_BusRdDone,
    input  wire [127:0] Transform_BusDataRdBuff, //data ready to write to cache from Bus
    output wire [127:0] RAM_DataWrt            //reqd cache signal  
    );

//--------FSM signal--------
localparam  Idle       = 2'b00;
localparam  WriteBus   = 2'b01;
localparam  ReadBus    = 2'b10;
localparam  WriteCache = 2'b11;
//****************cache RAM: 2 sets****************
reg         valid1[Cache_depth-1:0];   //valid bit of block
reg         valid2[Cache_depth-1:0];   
reg         dirty1[Cache_depth-1:0];   //dirty bit of block
reg         dirty2[Cache_depth-1:0];   
reg         lru   [Cache_depth-1:0];   //lru bit of cache line---1/way1/used  0/way2/unused
reg [18:0]  tag1  [Cache_depth-1:0];   //tag bits of block
reg [18:0]  tag2  [Cache_depth-1:0];   
reg [127:0] data1 [Cache_depth-1:0];   //data bits of block
reg [127:0] data2 [Cache_depth-1:0];

reg [127:0] RAM_DataWrt_reg;
reg [127:0] sel_data_rd_line;
wire[31:0]  sel_data_rd;
reg [127:0] data_rd_reg;
reg [31:0]  Cache_core_data_reg;
reg         modefied_reg;
//****************core_addr offset****************
//--------divide core_addr into 4 parts: byte\block\set\tag--------
wire [1:0]    addr_byte;    
wire [3:2]    addr_block;
wire [12:4]   addr_set;
wire [31:13]  addr_tag;
wire [6:0]    sel_word_start;
wire [4:0]    sel_hw;
wire [4:0]    sel_byte;
wire [6:0]    sel_byte_start;
wire          hit1;
wire          hit2;
wire          miss;
//--------divide core addr into 4 parts: tag\set\block\byte
assign {addr_byte,addr_block,addr_set,addr_tag}  = {Core_CacheAddr[1:0],Core_CacheAddr[3:2],Core_CacheAddr[12:4],Core_CacheAddr[31:13]};  
assign sel_word_start = addr_block   << 'd5;           //choose start addr of word       0/1/2/3*32
assign        sel_hw  = addr_byte[1] << 'd4;           //choose start addr of half word  0/2*16
assign      sel_byte  = addr_byte    << 'd3;           //choose start addr of byte       0/1/2/3*8
assign sel_byte_start = Core_CacheAddr[3:0] << 'd3;    //choose start bit of [write] data [Compare state core wt to cache]
integer     i;    //reset_RAM

//--------FSM state junp condition--------
assign RAM_ID_WB_cond = (((( dirty1[addr_set] && hit1 && valid1[addr_set] ) || ( dirty2[addr_set] && hit2 && valid2[addr_set] ))&& !Core_CacheRd)||  
                    (( dirty1[addr_set] && !lru[addr_set]  && valid1[addr_set] ||   dirty2[addr_set] && lru[addr_set] && valid2[addr_set]) && miss ));
assign RAM_ID_RB_cond = ((!valid1[addr_set] && hit1 )         || (!valid2[addr_set] && hit2 ) || 
                    ((!valid1[addr_set] && !lru[addr_set] ||  !valid2[addr_set] && lru[addr_set] ) && miss )||
                    (( valid1[addr_set] && !lru[addr_set] && !dirty1[addr_set]) || (valid2[addr_set] && lru[addr_set] && !dirty2[addr_set])) && miss );
assign RAM_ID_WC_cond = ((!dirty1[addr_set] && hit1 && valid1[addr_set]) || (!dirty2[addr_set] && hit2 && valid2[addr_set]));
assign RAM_WB_RB_cond = Transform_BusWrtDone;
//assign RAM_RB_ID_cond = Transform_BusRdDone;
assign RAM_RB_WC_cond = Transform_BusRdDone;
//****************generate compare signal****************
assign hit1  = (addr_tag == tag1[addr_set]);
assign hit2  = (addr_tag == tag2[addr_set]);
assign miss  = (!hit1 && !hit2);
//external signal for FSM jump ID-WB
assign modefied = modefied_reg;
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      modefied_reg <= 'b0;
    else if(!Core_CacheEn)
      modefied_reg <= 'b0;
    else if(( FSM_current_state == WriteCache ) && ( FSM_current_state2 == Idle ) && !Core_CacheRd && Core_CacheEn )
      modefied_reg <= modefied_reg + 'b1;
  end

//--------generate Iache_StallReq signal--------
//assign Icache_StallReq = (( FSM_current_state == Idle ) || (( FSM_current_state2 == Idle ) && ( FSM_current_state == WriteCache )) )? 0:1;
//assign Icache_StallReq = (( FSM_current_state != Idle ) || miss )? 1:0;

assign Icache_StallReq = ((Core_CacheEn)&&(( FSM_current_state != Idle ) || miss ||  
                        (( FSM_current_state == Idle ) && ( FSM_next_state == WriteCache )) || 
                        (( FSM_current_state == Idle ) && ( FSM_next_state == WriteBus   ))  ))? 1:0;

//****************wt\rd data in cache to Bus\ core****************
//--------read cache, then output to core--------
always@(*) 
  begin
    //if     (hit1 && valid1[addr_set] && !dirty1[addr_set] && Core_CacheRd && ( FSM_current_state == Idle ))
    if     (hit1 && valid1[addr_set]  && Core_CacheRd && ( FSM_current_state == Idle ))
      sel_data_rd_line = data1[addr_set];
    //else if(hit2 && valid2[addr_set] && !dirty2[addr_set] && Core_CacheRd && ( FSM_current_state == Idle ))
    else if(hit2 && valid2[addr_set]  && Core_CacheRd && ( FSM_current_state == Idle ))
      sel_data_rd_line = data2[addr_set];
    else
      sel_data_rd_line = 0;
  end
reg  [127:0]sel_data_rd_line_tmp; 
always@(*)
begin
    if(Core_CacheAddr[1]==1)
        sel_data_rd_line_tmp = sel_data_rd_line>>'d16;
    else
        sel_data_rd_line_tmp = sel_data_rd_line;
end
 
assign sel_data_rd = sel_data_rd_line_tmp[sel_word_start+:'d32];    //choose word frome cache line 
//assign sel_data_rd = sel_data_rd_line[sel_word_start+:'d32];    //choose word frome cache line 
always@(*)                       //choose word/half_word/byte from word
  begin
    if(Core_CacheRd && Core_CacheEn)
      /*case(Core_CacheWidth)
      2'b00:     Cache_core_data_reg={{24{sel_data_rd[sel_byte+'d8]}},sel_data_rd[sel_byte+:'d8]};  
      2'b01:     Cache_core_data_reg={{16{sel_data_rd[sel_hw+'d16]}} ,sel_data_rd[sel_hw+:'d16]};
      2'b10:     Cache_core_data_reg=sel_data_rd;
      default:   Cache_core_data_reg=32'b0;
      endcase*/     
      case(Core_CacheWidth)
          2'b00:     
                  if(Core_CacheSign)
                      Cache_core_data_reg = {{24{sel_data_rd[sel_byte+'d7]}},sel_data_rd[sel_byte+:'d8]};  
                  else
                      Cache_core_data_reg = {24'b0,sel_data_rd[sel_byte+:'d8]};   
          2'b01:   
                  if(Core_CacheSign)  
                      Cache_core_data_reg = {{16{sel_data_rd[sel_hw+'d15]}} ,sel_data_rd[sel_hw+:'d16]};
                  else
                      Cache_core_data_reg = {16'b0,sel_data_rd[sel_hw+:'d16]};
          2'b10:      Cache_core_data_reg = sel_data_rd;
          default:    Cache_core_data_reg = 32'b0;
        endcase
    else
                 Cache_core_data_reg=32'b0;
  end   
assign Cache_DataRd = (Dcache_Dirty)? Dcache_DataRd : Cache_core_data_reg; 
assign Icache_PC = Core_CacheAddr;
//--------read cache, then write to Bus--------
always@(*) 
  begin
    //if((FSM_current_state2 == Idle) && ( FSM_current_state == WriteBus) )
    if(( FSM_current_state == WriteBus) )
      if((hit1 || (miss && !lru[addr_set])) && valid1[addr_set])
        RAM_DataWrt_reg = data1[addr_set];
      else if((hit2 || (miss && lru[addr_set])) && valid2[addr_set])
        RAM_DataWrt_reg = data2[addr_set];
      else
        RAM_DataWrt_reg = 0;
    else
        RAM_DataWrt_reg = 0;
  end
assign RAM_DataWrt = RAM_DataWrt_reg;

//--------write cache from Bus && core--------
//--valid--
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      for(i=0;i<=511;i=i+1)begin
        valid1[i] <= 0;
        valid2[i] <= 0;end
    else if(( FSM_current_state == ReadBus ) && ( FSM_current_state2 != FSM_current_state ))  //enable valid update
      if(hit1 || (miss && !lru[addr_set]))
        valid1[addr_set] <= 1;
      else if(hit2 || (miss && lru[addr_set]))
        valid2[addr_set] <= 1;
    else if(FSM_current_state == Idle)
      if((Dcache_Dirty == 1) && (hit1))
        valid1[addr_set] <= 0;
      else if((Dcache_Dirty == 1) && (hit2))
        valid2[addr_set] <= 0;
  end
//--dirty--
always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n)
      for(i=0;i<=511;i=i+1)begin
        dirty1[i] <= 0;
        dirty2[i] <= 0;end
    else if((FSM_current_state == ReadBus ) && ( FSM_current_state2 == WriteBus ))  //enable dirty update
      if((hit1 || (miss && !lru[addr_set])) && valid1[addr_set])  //clean dirty signal 
        dirty1[addr_set] <= 0;
      else if((hit2 || (miss && lru[addr_set])) && valid2[addr_set])
        dirty2[addr_set] <= 0;
      else  begin
        dirty1[addr_set] <= dirty1[addr_set];
        dirty2[addr_set] <= dirty2[addr_set]; end
    else if(( FSM_current_state == WriteCache ) && ( FSM_current_state2 == Idle ))    //WriteCache then enable dirty signal
        if(hit1 && valid1[addr_set])
          dirty1[addr_set] <= 1;
        else if(hit2 && valid2[addr_set])
          dirty2[addr_set] <= 1;
  end
//--lru--
always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n)
      for(i=0;i<=511;i=i+1)begin
      lru[i] <= 0;end
    else if(( FSM_current_state == Idle ) && ( FSM_current_state2 == WriteCache ) && !modefied && Core_CacheEn)  //enable lru update
      lru[addr_set] <= ~ lru[addr_set];
 end
//--tag--
always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n)
      for(i=0;i<=511;i=i+1)begin
        tag1[i] <= 0;
        tag2[i] <= 0;end
    else if( FSM_current_state == ReadBus )       //enable tag update
      if((hit1 || (miss && !lru[addr_set])) && valid1[addr_set])
        tag1[addr_set] <= addr_tag;
      else if((hit2 || (miss && lru[addr_set])) && valid2[addr_set])
        tag2[addr_set] <= addr_tag;
  end
//--data--
always @(posedge clk or negedge rst_n) 
  begin
    if(!rst_n)
        for(i=0;i<=511;i=i+1)begin
          data1[i] <= 128'b0;
          data2[i] <= 128'b0;end
  //  else if( FSM_current_state == WriteCache )    //write cache from core
  //      if((hit1 || (miss && !lru[addr_set])) && valid1[addr_set])
  //              case(Core_CacheWidth)
  //                2'b00:     data1[addr_set][sel_byte_start+:'d8]  <= Core_CacheData['d8-1:0];
  //                2'b01:     data1[addr_set][sel_byte_start+:'d16] <= Core_CacheData['d16-1:0];
  //                2'b10:     data1[addr_set][sel_byte_start+:'d32] <= Core_CacheData['d32-1:0];
  //                default:   data1[addr_set] <= data1[addr_set];
  //              endcase      
  //      else if((hit2 || (miss && lru[addr_set])) && valid2[addr_set])
  //              case(Core_CacheWidth)
  //                2'b00:     data2[addr_set][sel_byte_start+:'d8]  <= Core_CacheData['d8-1:0];
  //                2'b01:     data2[addr_set][sel_byte_start+:'d16] <= Core_CacheData['d16-1:0];
  //                2'b10:     data2[addr_set][sel_byte_start+:'d32] <= Core_CacheData['d32-1:0];
  //                default:   data2[addr_set] <= data2[addr_set];
  //              endcase
  //  else if( Transform_BusRdDone )                   //write cache from Bus
  //      if((hit1 || (miss && !lru[addr_set])) && valid1[addr_set])         data1[addr_set] <= Transform_BusDataRdBuff;
  //      else if((hit2 || (miss && lru[addr_set])) && valid2[addr_set])     data2[addr_set] <= Transform_BusDataRdBuff;
    else if(( FSM_current_state == WriteCache ) && ( FSM_current_state2 == ReadBus ))       //write cache from core
        if((hit1 || (miss && !lru[addr_set])) && valid1[addr_set])         data1[addr_set] <= Transform_BusDataRdBuff;
        else if((hit2 || (miss && lru[addr_set])) && valid2[addr_set])     data2[addr_set] <= Transform_BusDataRdBuff;        
        else  begin
            data1[addr_set] <= data1[addr_set];
            data2[addr_set] <= data2[addr_set]; end       
    else if(( FSM_current_state == WriteCache ) && ( FSM_current_state2 == Idle ))
        if((hit1 || (miss && !lru[addr_set])) && valid1[addr_set])
                case(Core_CacheWidth)
                  2'b00:     data1[addr_set][sel_byte_start+:'d8]  <= Core_CacheData['d8-1:0];
                  2'b01:     data1[addr_set][sel_byte_start+:'d16] <= Core_CacheData['d16-1:0];
                  2'b10:     data1[addr_set][sel_byte_start+:'d32] <= Core_CacheData['d32-1:0];
                  default:   data1[addr_set] <= data1[addr_set];
                endcase      
        else if((hit2 || (miss && lru[addr_set])) && valid2[addr_set])
                case(Core_CacheWidth)
                  2'b00:     data2[addr_set][sel_byte_start+:'d8]  <= Core_CacheData['d8-1:0];
                  2'b01:     data2[addr_set][sel_byte_start+:'d16] <= Core_CacheData['d16-1:0];
                  2'b10:     data2[addr_set][sel_byte_start+:'d32] <= Core_CacheData['d32-1:0];
                  default:   data2[addr_set] <= data2[addr_set];
                endcase
  end

endmodule
