//************************************************************************************************
//************************************************************************************************
//*****************This module is used to transmit dara between Bus  and cache********************
//************************************************************************************************
//************************************************************************************************
module L1D_Transform(
//----top----
    input  wire         clk                     ,
    input  wire         rst_n                   ,
    input  wire [31:0]  Core_CacheAddr          ,  //addr from core to cache
    input  wire         Core_CacheEn            ,
    input  wire         Core_CacheRd            ,  //opcode 0/write 1/read 
//----FSM module----                            
    input  wire         writebus_en             ,
    input  wire         readbus_en              ,
    input  wire         fsm_idle_en             ,
    input  wire         fsm_writecache_en       ,
    output wire         Tran_BusRdDone_cnt      ,
//----RAM module----                            
    output wire [127:0] Tran_BusDataRd          ,  //cache<----Bus rd
    input  wire [127:0] RAM_DataWrt             ,  //core---->cache wt,data_reg between cache and Bus 
//----Bus_hand module----                       
    output wire [31:0]  writeaddress            ,  //the address of write or write data from cache to axi
    output wire [31:0]  readaddress             ,  //the address of write or read data from cache to axi
    output wire [31:0]  writedata               ,  //data write to axi from cache
    input  wire [31:0]  readdata                ,  //data from Bus to cache[read]
    input  wire         rd_last                 ,  //indicate the last read data
    input  wire         wrt_last                ,  //indicate the last write data
    input  wire         BHand_Rd_Cond           ,  //read data from Bus to cache condition
    input  wire         BHand_Wrt_Cond          ,  //write data from Bus to cache condition
    input  wire         wrt_addr_state             //flag of capture first data written to bus
    );

//--------data reg between cache and Bus--------         
reg [127:0] Cache_Bus_wrt_data_reg ; //cache---->Bus wt
reg [127:0] Cache_Bus_rd_data_reg  ; //cache---->Bus wt
reg         Tran_BusRdDone_cnt0    ;

//--------Read Data from Bus to cache (cache<-Bus)--------
//read readdata from Bus to Cache && shift left 32bits per clk****
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n) 
      Cache_Bus_rd_data_reg <= 127'b0;
   else if(( readbus_en ) && BHand_Rd_Cond ) 
      Cache_Bus_rd_data_reg <= {readdata,Cache_Bus_rd_data_reg[127:32]};  //capture data && shift left 32bits per clk
  end 
assign Tran_BusDataRd = Cache_Bus_rd_data_reg;
//this signal is used to control FSM Id->WB, if read Bus is done, FSM should not transform in once write or read
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      Tran_BusRdDone_cnt0 <= 'b0;
    else if(!Core_CacheEn)
      Tran_BusRdDone_cnt0 <= 'b0;
    else if(rd_last)
      Tran_BusRdDone_cnt0 <= Tran_BusRdDone_cnt0 + 'b1;
  end
assign  Tran_BusRdDone_cnt = Tran_BusRdDone_cnt0;

//--------Write Data from Cache to Bus (cache->Bus)--------
//generate write data (from caceh to bus)--read RAM_DataWrt from cache && shift left 32 bits per clk
    always @(posedge clk or negedge rst_n) 
      begin
        if(!rst_n)
          Cache_Bus_wrt_data_reg <= 32'b0; 
        else if(wrt_addr_state)                                        //delay 1 clk, then input RAM_DataWrt
          Cache_Bus_wrt_data_reg <= RAM_DataWrt;                       //capture data
        else if(BHand_Wrt_Cond)
          Cache_Bus_wrt_data_reg <= Cache_Bus_wrt_data_reg >> 'd32;    //shift right 32bits per clk
      end
//output data && done signal
// assign writedata   = BHand_Wrt_Cond ? Cache_Bus_wrt_data_reg[127:96] : 32'b0;
assign writedata   = BHand_Wrt_Cond ? Cache_Bus_wrt_data_reg[31:0] : 32'b0;

//--------generate output address to Bus-----
assign writeaddress = Core_CacheRd?0:{Core_CacheAddr[31:4],4'b0};  
//assign readaddress  = Core_CacheRd?{Core_CacheAddr[31:4],4'b0}:0;  
assign readaddress  = {Core_CacheAddr[31:4],4'b0};  

endmodule