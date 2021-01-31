//************************************************************************************************
//************************************************************************************************
///*****************This module is used to transmit dara between core and cache********************
//************************************************************************************************
//************************************************************************************************
module L1I_Bus_hand #
	(
		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
		parameter integer C_M00_AXI_BURST_LEN	    = 16,
		parameter integer C_M00_AXI_ID_WIDTH	    = 2,
		parameter integer C_M00_AXI_ADDR_WIDTH	    = 32,
		parameter integer C_M00_AXI_DATA_WIDTH	    = 32,
		parameter integer C_M00_AXI_AWUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_WUSER_WIDTH	    = 0,
		parameter integer C_M00_AXI_RUSER_WIDTH	    = 0,
		parameter integer C_M00_AXI_BUSER_WIDTH	    = 0,        
        //---------------AXI_burst configuration----------------
        parameter    awlen     = 8'b011  ,
        parameter    awsize    = 3'b010  ,
        parameter    awburst   = 2'b01   ,
        parameter    wstrb     = 4'b1111 , 
        parameter    arlen     = 8'b011  , 
        parameter    arsize    = 3'b010  , 
        parameter    arburst   = 2'b01           
   	)
	(
      //FSM-module
        input  wire                                  writebus_en        ,    //signal from FSM module 
        input  wire                                  readbus_en         ,    //signal from FSM module 
      //Transform module                                                     
        input  wire [C_M00_AXI_ADDR_WIDTH-1:0]       writeaddress       ,    //the address of write or write data from cache to axi
        input  wire [C_M00_AXI_ADDR_WIDTH-1:0]       readaddress        ,    //the address of write or read data from cache to axi
        input  wire [C_M00_AXI_DATA_WIDTH-1:0]       writedata          ,    //data write to axi from cache
        output wire [C_M00_AXI_DATA_WIDTH-1:0]       readdata           ,    //data from Bus to cache[read]
        output wire                                  BHand_Rd_Cond      ,    //read data from Bus to cache condition
        output wire                                  BHand_Wrt_Cond     ,    //write data from Bus to cache condition
        output wire                                  rd_last            ,    //indicate the last read  data, connect to m00_axi_rlast
        output wire                                  wrt_last           ,    //indicate the last write data, connect to m00_axi_reg_wlast
        output wire                                  wrt_addr_state     ,    //indicate the last write data, connect to m00_axi_reg_wlast
// Ports of Axi Master Bus Interface M00_AXI
      //input  wire                                  m00_axi_init_axi_txn,   //input 
      //output wire                                  m00_axi_txn_done,       //output 
      //output wire                                  m00_axi_error,          //output 
		input  wire                                  m00_axi_aclk       ,    //input 
		input  wire                                  m00_axi_aresetn    ,    //input 
        //----Address Write----                                          
		output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_awid       ,    //output
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]     m00_axi_awaddr     ,    //output
		output wire [7 : 0]                          m00_axi_awlen      ,    //output
		output wire [2 : 0]                          m00_axi_awsize     ,    //output
		output wire [1 : 0]                          m00_axi_awburst    ,    //output
		output wire                                  m00_axi_awlock     ,    //output
		output wire [3 : 0]                          m00_axi_awcache    ,    //output
		output wire [2 : 0]                          m00_axi_awprot     ,    //output
		output wire [3 : 0]                          m00_axi_awqos      ,    //output
		output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0]   m00_axi_awuser     ,    //output
		output wire                                  m00_axi_awvalid    ,    //output
		input  wire                                  m00_axi_awready    ,    //input 
        //----Write Data----  
    output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_wid        ,    //output                                              
		output wire [C_M00_AXI_DATA_WIDTH-1   : 0]   m00_axi_wdata      ,    //output
		output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0]   m00_axi_wstrb      ,    //output
		output wire                                  m00_axi_wlast      ,    //output
		output wire [C_M00_AXI_WUSER_WIDTH-1 : 0]    m00_axi_wuser      ,    //output
		output wire                                  m00_axi_wvalid     ,    //output
		input  wire                                  m00_axi_wready     ,    //input 
        //----Backup Response----                                           
		input  wire [C_M00_AXI_ID_WIDTH-1 : 0]       m00_axi_bid        ,    //input 
		input  wire [1 : 0]                          m00_axi_bresp      ,    //input 
		input  wire [C_M00_AXI_BUSER_WIDTH-1 : 0]    m00_axi_buser      ,    //input 
		input  wire                                  m00_axi_bvalid     ,    //input 
		output wire                                  m00_axi_bready     ,    //output
        //----Address Read----                                            
		output wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_arid       ,    //output 
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]     m00_axi_araddr     ,    //output 
		output wire [7 : 0]                          m00_axi_arlen      ,    //output 
		output wire [2 : 0]                          m00_axi_arsize     ,    //output 
		output wire [1 : 0]                          m00_axi_arburst    ,    //output 
		output wire                                  m00_axi_arlock     ,    //output 
		output wire [3 : 0]                          m00_axi_arcache    ,    //output 
		output wire [2 : 0]                          m00_axi_arprot     ,    //output 
		output wire [3 : 0]                          m00_axi_arqos      ,    //output 
		output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0]   m00_axi_aruser     ,    //output 
		output wire                                  m00_axi_arvalid    ,    //output 
		input  wire                                  m00_axi_arready    ,    //input 
        //----Read Data----                                               
		input  wire [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_rid        ,    //input 
		input  wire [C_M00_AXI_DATA_WIDTH-1 : 0]     m00_axi_rdata      ,    //input 
		input  wire [1 : 0]                          m00_axi_rresp      ,    //input 
		input  wire                                  m00_axi_rlast      ,    //input 
		input  wire [C_M00_AXI_RUSER_WIDTH-1 : 0]    m00_axi_ruser      ,    //input 
		input  wire                                  m00_axi_rvalid     ,    //input 
		output wire                                  m00_axi_rready          //output
	);
//--------------define reg signal-------------------------
    //Address Write                                             
    reg [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_reg_awid       ;    // 
    reg [C_M00_AXI_ADDR_WIDTH-1 : 0]     m00_axi_reg_awaddr     ;    // 
    reg [7 : 0]                          m00_axi_reg_awlen      ;    // 
    reg [2 : 0]                          m00_axi_reg_awsize     ;    // 
    reg [1 : 0]                          m00_axi_reg_awburst    ;    // 
    reg                                  m00_axi_reg_awlock     ;    // 
    reg [3 : 0]                          m00_axi_reg_awcache    ;    // 
    reg [2 : 0]                          m00_axi_reg_awprot     ;    // 
    reg [3 : 0]                          m00_axi_reg_awqos      ;    // 
    reg [C_M00_AXI_AWUSER_WIDTH-1 : 0]   m00_axi_reg_awuser     ;    // 
    reg                                  m00_axi_reg_awvalid    ;    //                                                     
    //Write Data  
    reg [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_reg_wid        ;    //                                                
    reg [C_M00_AXI_DATA_WIDTH-1   : 0]   m00_axi_reg_wdata      ;    // 
    reg [C_M00_AXI_DATA_WIDTH/8-1 : 0]   m00_axi_reg_wstrb      ;    // 
    reg                                  m00_axi_reg_wlast      ;    // 
    reg [C_M00_AXI_WUSER_WIDTH-1 : 0]    m00_axi_reg_wuser      ;    // 
    reg                                  m00_axi_reg_wvalid     ;    //                                             
    //Backup Response                                        
    reg                                  m00_axi_reg_bready     ;    // 
    //Address Read                                         
    reg [C_M00_AXI_ID_WIDTH-1   : 0]     m00_axi_reg_arid       ;    // 
    reg [C_M00_AXI_ADDR_WIDTH-1 : 0]     m00_axi_reg_araddr     ;    // 
    reg [7 : 0]                          m00_axi_reg_arlen      ;    // 
    reg [2 : 0]                          m00_axi_reg_arsize     ;    // 
    reg [1 : 0]                          m00_axi_reg_arburst    ;    // 
    reg                                  m00_axi_reg_arlock     ;    // 
    reg [3 : 0]                          m00_axi_reg_arcache    ;    // 
    reg [2 : 0]                          m00_axi_reg_arprot     ;    // 
    reg [3 : 0]                          m00_axi_reg_arqos      ;    // 
    reg [C_M00_AXI_ARUSER_WIDTH-1 : 0]   m00_axi_reg_aruser     ;    // 
    reg                                  m00_axi_reg_arvalid    ;    // 
    //Read Data                                             
    reg                                  m00_axi_reg_rready     ;    // 
    //read data to core
    reg [C_M00_AXI_DATA_WIDTH-1: 0]      readdata_reg ;       //read data from slave_axi_rdata

//------------connect (output signal) reg and wire--------------
    //Write Address                                  
    assign m00_axi_awid     = m00_axi_reg_awid    ;   // 
    assign m00_axi_awaddr   = m00_axi_reg_awaddr  ;   // 
    assign m00_axi_awlen    = m00_axi_reg_awlen   ;   // 
    assign m00_axi_awsize   = m00_axi_reg_awsize  ;   // 
    assign m00_axi_awburst  = m00_axi_reg_awburst ;   // 
    assign m00_axi_awlock   = m00_axi_reg_awlock  ;   // 
    assign m00_axi_awcache  = m00_axi_reg_awcache ;   // 
    assign m00_axi_awprot   = m00_axi_reg_awprot  ;   // 
    assign m00_axi_awqos    = m00_axi_reg_awqos   ;   // 
    assign m00_axi_awuser   = m00_axi_reg_awuser  ;   // 
    assign m00_axi_awvalid  = m00_axi_reg_awvalid ;   // 
    //Write Data
    assign m00_axi_wid      = m00_axi_reg_wid    ;   //                             
    assign m00_axi_wdata    = m00_axi_reg_wdata   ;   // 
    assign m00_axi_wstrb    = m00_axi_reg_wstrb   ;   // 
    assign m00_axi_wlast    = m00_axi_reg_wlast   ;   // 
    assign m00_axi_wuser    = m00_axi_reg_wuser   ;   // 
    assign m00_axi_wvalid   = m00_axi_reg_wvalid  ;   // 
    //Write Response                       
    assign m00_axi_bready   = m00_axi_reg_bready  ;   // 
    //Read Address                        
    assign m00_axi_arid     = m00_axi_reg_arid    ;   // 
    assign m00_axi_araddr   = m00_axi_reg_araddr  ;   // 
    assign m00_axi_arlen    = m00_axi_reg_arlen   ;   // 
    assign m00_axi_arsize   = m00_axi_reg_arsize  ;   // 
    assign m00_axi_arburst  = m00_axi_reg_arburst ;   // 
    assign m00_axi_arlock   = m00_axi_reg_arlock  ;   // 
    assign m00_axi_arcache  = m00_axi_reg_arcache ;   // 
    assign m00_axi_arprot   = m00_axi_reg_arprot  ;   // 
    assign m00_axi_arqos    = m00_axi_reg_arqos   ;   // 
    assign m00_axi_aruser   = m00_axi_reg_aruser  ;   // 
    assign m00_axi_arvalid  = m00_axi_reg_arvalid ;   // 
    //Read Data                            
    assign m00_axi_rready   = m00_axi_reg_rready  ;   //
//AXI master FSM
localparam  Idle_axi = 6'b000001; 
localparam  Wrt_Addr = 6'b000010; 
localparam  Wrt_Data = 6'b000100; 
localparam  Wrt_Rsp  = 6'b001000; 
localparam  Rd_Addr  = 6'b010000; 
localparam  Rd_Data  = 6'b100000; 
reg  [5:0]      current_state;
reg  [5:0]      next_state;
    
    //output
    assign readdata         = readdata_reg;
    assign BHand_Wrt_Cond   = (( current_state == Wrt_Data ) && m00_axi_wready && m00_axi_reg_wvalid ) ?1:0;
    assign BHand_Rd_Cond    = (( current_state == Rd_Data )  && m00_axi_rvalid && m00_axi_reg_rready ) ?1:0;
    assign wrt_addr_state   = ( current_state == Wrt_Addr )?1:0;
    assign rd_last          = m00_axi_rlast && m00_axi_rvalid ;
    assign wrt_last         = m00_axi_reg_wlast;
    
//AXI master counterwrt 
reg [7:0] counter_wrt;
always@(posedge m00_axi_aclk or negedge m00_axi_aresetn)
  begin
    if( !m00_axi_aresetn )
      counter_wrt <= 0;
    else if(( current_state == Wrt_Data ) && ( counter_wrt <= awlen ) && m00_axi_wready && m00_axi_reg_wvalid )  //bushand
      counter_wrt <= counter_wrt + 1;
    else
      counter_wrt <= 0;
  end

//FSM transform
always@(posedge m00_axi_aclk or negedge m00_axi_aresetn)
  begin
    if( !m00_axi_aresetn )
      current_state <= Idle_axi;
    else
      current_state <= next_state;
  end
always@(*)
  begin
    case( current_state )
      Idle_axi:    
        if( writebus_en )
                next_state = Wrt_Addr;
        else if( readbus_en  ) 
                next_state = Rd_Addr;
        else
                next_state = Idle_axi;
      Wrt_Addr:
        if( writebus_en && m00_axi_awready )
                next_state = Wrt_Data;
        else
                next_state = Wrt_Addr;
      Wrt_Data:
        if( counter_wrt == awlen )
                next_state = Wrt_Rsp;
        else
                next_state = Wrt_Data;
      Wrt_Rsp:
        /*if( readbus_en && m00_axi_bvalid )
                next_state = Rd_Addr;
        else if( writebus_en && m00_axi_bvalid )
                next_state = Wrt_Addr;*/
        if(m00_axi_bvalid && (m00_axi_bid==0)&&(m00_axi_bresp==0))  
                next_state = Idle_axi;      //m00_axi_bvalid == 1 indicate write has been finished
        else
                next_state = Wrt_Rsp;
      Rd_Addr:
        if( readbus_en && m00_axi_arready)
                next_state = Rd_Data;
        else
                next_state = Rd_Addr;
      Rd_Data:
        /*if( writebus_en && m00_axi_rlast )
                next_state = Wrt_Addr;
        else if( readbus_en && m00_axi_rlast )
                next_state = Rd_Addr;*/
        if( m00_axi_rlast&&( m00_axi_rid == 0) && m00_axi_rvalid )            //m00_axi_rlast == 1 indicate read has been finished
                next_state = Idle_axi;
        else
                next_state = Rd_Data;
       default: next_state = Idle_axi;
    endcase
  end
//Combinational operation
always@(*)
  begin
    case( current_state )
      Idle_axi:  
        begin
            //Write Address                            
            m00_axi_reg_awid     = 0;          // 
            m00_axi_reg_awaddr   = 0;          // 
            m00_axi_reg_awlen    = 0;          // 
            m00_axi_reg_awsize   = 0;          // 
            m00_axi_reg_awburst  = 0;          // 
            m00_axi_reg_awlock   = 0;          // 
            m00_axi_reg_awcache  = 1;          // 
            m00_axi_reg_awprot   = 0;          // 
            m00_axi_reg_awqos    = 0;          // 
            m00_axi_reg_awuser   = 0;          // 
            m00_axi_reg_awvalid  = 0;          // 
            //Write Data 
            m00_axi_reg_wid      = 0;          //                            
            m00_axi_reg_wdata    = 0;          // 
            m00_axi_reg_wstrb    = 0;          // 
            m00_axi_reg_wlast    = 0;          // 
            m00_axi_reg_wuser    = 0;          // 
            m00_axi_reg_wvalid   = 0;          // 
            //Write Response                            
            m00_axi_reg_bready   = 1;          // 
            //Read Address                        
            m00_axi_reg_arid     = 0;          // 
            m00_axi_reg_araddr   = 0;          // 
            m00_axi_reg_arlen    = 0;          // 
            m00_axi_reg_arsize   = 0;          // 
            m00_axi_reg_arburst  = 0;          // 
            m00_axi_reg_arlock   = 0;          // 
            m00_axi_reg_arcache  = 1;          // 
            m00_axi_reg_arprot   = 0;          // 
            m00_axi_reg_arqos    = 0;          // 
            m00_axi_reg_aruser   = 0;          // 
            m00_axi_reg_arvalid  = 0;          // 
            //Read Data                           
            m00_axi_reg_rready   = 0;          //  
        end
      Wrt_Addr:  
        begin
             m00_axi_reg_awid     = 0;         
            m00_axi_reg_awaddr   = writeaddress;  //address of data writing from cache to axi 
            m00_axi_reg_awlen    = awlen  ;       //burst transmit 3+1 times 
            m00_axi_reg_awsize   = awsize ;       //every burst transmit 2^2=4 bytes data 
            m00_axi_reg_awburst  = awburst;       //burst typr = increment 
             m00_axi_reg_awlock   = 0;         
             m00_axi_reg_awcache  = 1;         
             m00_axi_reg_awprot   = 0;         
             m00_axi_reg_awqos    = 0;         
             m00_axi_reg_awuser   = 0;
            m00_axi_reg_awvalid  = 1;          //enable write address 
        end
      Wrt_Data:
        begin
            m00_axi_reg_wid      = 0; 
            m00_axi_reg_awvalid  = 0;          //disable write address
            
            m00_axi_reg_wdata    = writedata;  //data writing to axi rom cache
            m00_axi_reg_wstrb    = wstrb;      //indicate that all 4 bytes will be wroten in one burst 
                if( counter_wrt == awlen )
                    m00_axi_reg_wlast = 1;  //the flag of transmit last byte data of 4 bytes 
                else
                    m00_axi_reg_wlast = 0;   
             m00_axi_reg_wuser    = 0;         
            m00_axi_reg_wvalid   = 1;          //enable write data
        end
      Wrt_Rsp:
        begin
            m00_axi_reg_wlast    = 0;          //disable flag of last byte 
            m00_axi_reg_wvalid   = 0;          //disable write data
            m00_axi_reg_bready   = 1;          //bready always is 1,so the master can receive write finish response signal             
        end
      Rd_Addr:
        begin
             m00_axi_reg_arid     = 0;         
            m00_axi_reg_araddr   = readaddress; //read data address
            m00_axi_reg_arlen    = arlen  ;     //burst transmit 3+1 times 
            m00_axi_reg_arsize   = arsize ;     //every burst transmit 2^2=4 bytes data
            m00_axi_reg_arburst  = arburst;     //burst typr = increment 
             m00_axi_reg_arlock   = 0;         
             m00_axi_reg_arcache  = 1;         
             m00_axi_reg_arprot   = 0;         
             m00_axi_reg_arqos    = 0;         
             m00_axi_reg_aruser   = 0;          
            m00_axi_reg_arvalid  = 1;          //enable read address 
        end      
      Rd_Data:
        begin
            m00_axi_reg_arvalid  = 0;          //disable read address //收到aready时才拉低
            m00_axi_reg_rready   = 1;          //ready to read data
            if( m00_axi_rvalid &&( m00_axi_rid == 0)&&(m00_axi_rresp==0))
                readdata_reg = m00_axi_rdata;
            else
                readdata_reg = 0;
        end         
      default:
        begin
            m00_axi_reg_bready   = 1;          //bready always is 1,so the master can receive write finish response signal
        end
    endcase
  end

endmodule