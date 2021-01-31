//************************************************************************************************
//************************************************************************************************
//*****************This module is used to describe the main FSM***********************************
//************************************************************************************************
//************************************************************************************************
module L1I_FSM(
//----top module----    
    input  wire         clk                ,
    input  wire         rst_n              ,
    input  wire         Core_CacheRd       , //1/read 0/write
    input  wire         Core_CacheEn       ,
//----FSM module----                       
    input  wire         RAM_ID_WB_cond     ,
    input  wire         RAM_ID_RB_cond     ,
    input  wire         RAM_ID_WC_cond     ,
    input  wire         RAM_WB_RB_cond     ,  
    input  wire         RAM_RB_WC_cond     ,
    input  wire         modefied           ,
    output wire [1:0]   FSM_current_state  ,
    output wire [1:0]   FSM_current_state2 ,
    output wire [1:0]   FSM_next_state     ,
//----Transform module                     
    input  wire         Tran_BusRdDone_cnt ,
//----Bus_hand / RAM / Transform module    
    output wire         writebus_en        ,
    output wire         readbus_en         ,
    output wire         fsm_idle_en        ,
    output wire         fsm_writecache_en  
    );
//--------main FSM reg--------
reg [1:0]   current_state_reg;
reg [1:0]   current_state2_reg;
reg [1:0]   next_state_reg;
localparam  Idle       = 2'b00;
localparam  WriteBus   = 2'b01;
localparam  ReadBus    = 2'b10;
localparam  WriteCache = 2'b11;
//--------main FSM--------
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)             current_state_reg <= Idle;
    else if(!Core_CacheEn) current_state_reg <= Idle;
    else                   current_state_reg <= next_state_reg;
 end  
//--------state jump--------
always@(*)
  begin
    case(current_state_reg)
      Idle:
             if(RAM_ID_WB_cond &&  !Tran_BusRdDone_cnt && !modefied )         
                next_state_reg = WriteBus;      //hit1or2 && dirty || miss && lru1or2 && dirty1or2
             else if(RAM_ID_RB_cond )    
                next_state_reg = ReadBus;       //hit1or2 && !valid1or2 || miss && lru1or2 && !valid1or2 || miss && lru1or2 && clean1or2
             else if(RAM_ID_WC_cond && !Core_CacheRd)
                next_state_reg = WriteCache;    //write && hit1or2 & clean1or2
             else 
                next_state_reg = Idle;      
      WriteBus:
             if(RAM_WB_RB_cond)                         
                next_state_reg = ReadBus;       //write Bus done
             else                                      
                next_state_reg = WriteBus;      
      ReadBus:
             if(RAM_RB_WC_cond)                         
                next_state_reg = WriteCache;    //write Bus && write Bus done
             else                                       
                next_state_reg = ReadBus;
      WriteCache:                                       
                next_state_reg = Idle;          //next state isidle
      default:                                          
                next_state_reg = Idle;
    endcase
 end
 
//output 
assign      writebus_en        = (FSM_current_state==WriteBus) ?1:0;
assign      readbus_en         = ((Core_CacheEn)&&(FSM_current_state==ReadBus))  ?1:0;   
assign      fsm_idle_en        = (FSM_current_state==Idle)  ?1:0;   
assign      fsm_writecache_en  = (FSM_current_state==WriteCache)  ?1:0;   
 
//--------FSM_current_state2-------
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)    
      current_state2_reg <= Idle;
  else          
      current_state2_reg <= current_state_reg;
end
//--------output--------
assign FSM_current_state  = current_state_reg;
assign FSM_current_state2 = current_state2_reg;
assign FSM_next_state     = next_state_reg;

endmodule