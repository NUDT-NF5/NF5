//************************************************************************************************
//************************************************************************************************
//*****************This module is used to describe the cache RAM**********************************
//************************************************************************************************
//************************************************************************************************
//`include "L1I_Bus_hand.v"
//`include "L1I_Transform.v"
//`include "L1I_FSM.v"
//`include "L1I_RAM.v"
module L1D_Cache
#( 		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
		parameter integer C_M00_AXI_BURST_LEN	    = 16,
		parameter integer C_M00_AXI_ID_WIDTH	    = 2,
		parameter integer C_M00_AXI_ADDR_WIDTH	    = 32,
		parameter integer C_M00_AXI_DATA_WIDTH	    = 32,
		parameter integer C_M00_AXI_AWUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_WUSER_WIDTH	    = 0,
		parameter integer C_M00_AXI_RUSER_WIDTH	    = 0,
		parameter integer C_M00_AXI_BUSER_WIDTH	    = 0
)
(
//core
        input  wire                                  clk                ,
        input  wire                                  rst_n              ,
        input  wire                                  Core_CacheRd       ,    //1/read 0/write
        input  wire                                  Core_CacheEn       ,    
        input  wire                                  Core_CacheSign     ,    
        input  wire [31:0]                           Core_CacheAddr     ,    //addr from core to cache
        input  wire [31:0]                           Core_CacheData     ,    //input data from core to cache [write]
        input  wire [1:0]                            Core_CacheWidth    ,    //input access data width from core to cache 00/byte---01/half_word---10/word
        output wire [31:0]                           Cache_DataRd       ,    //output data to core
        output wire                                  Cache_StallReq     ,    //output signal to control unit
        //from Dcache to snoop              ,                                
        output wire [31:0]                           Dcache_DataRd      ,    
        output wire                                  Dcache_Dirty       ,    
        input  wire [31:0]                           Icache_PC          ,
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


wire [1:0]   FSM_current_state      ;
wire [1:0]   FSM_current_state2     ;
wire [1:0]   FSM_next_state         ;
wire [1:0]   writebus_en            ;
wire         readbus_en             ;
wire         fsm_idle_en            ;
wire         fsm_writecache_en      ;
wire [31:0]  writeaddress           ;
wire [31:0]  readaddress            ;
wire [31:0]  writedata              ;
wire [31:0]  readdata               ;
wire         BHand_Rd_Cond          ;
wire         BHand_Wrt_Cond         ;
wire         rd_last                ;
wire         wrt_last               ;
wire         wrt_addr_state         ;
wire [127:0] RAM_DataWrt            ;
wire [127:0] Tran_BusDataRd         ; 
wire         RAM_ID_WB_cond         ;
wire         RAM_ID_RB_cond         ;
wire         RAM_ID_WC_cond         ;
wire         RAM_WB_RB_cond         ;
wire         RAM_RB_WC_cond         ;
wire         modefied               ;
wire         Tran_BusRdDone_cnt     ;


L1D_Bus_hand i_L1D_Bus_hand(
    .writebus_en           (writebus_en      ),
    .readbus_en            (readbus_en       ),      
    .writeaddress          (writeaddress     ),
    .readaddress           (readaddress      ),
    .writedata             (writedata        ),
    .readdata              (readdata         ),
    .BHand_Rd_Cond         (BHand_Rd_Cond    ),
    .BHand_Wrt_Cond        (BHand_Wrt_Cond   ),
    .rd_last               (rd_last          ),
    .wrt_last              (wrt_last         ),
    .wrt_addr_state        (wrt_addr_state   ),
    .m00_axi_aclk          (m00_axi_aclk     ),
    .m00_axi_aresetn       (m00_axi_aresetn  ),         
    .m00_axi_awid          (m00_axi_awid     ),
    .m00_axi_awaddr        (m00_axi_awaddr   ),
    .m00_axi_awlen         (m00_axi_awlen    ),
    .m00_axi_awsize        (m00_axi_awsize   ),
    .m00_axi_awburst       (m00_axi_awburst  ),
    .m00_axi_awlock        (m00_axi_awlock   ),
    .m00_axi_awcache       (m00_axi_awcache  ),
    .m00_axi_awprot        (m00_axi_awprot   ),
    .m00_axi_awqos         (m00_axi_awqos    ),
    .m00_axi_awuser        (m00_axi_awuser   ),
    .m00_axi_awvalid       (m00_axi_awvalid  ),
    .m00_axi_awready       (m00_axi_awready  ),
    .m00_axi_wid           (m00_axi_wid      ),         
    .m00_axi_wdata         (m00_axi_wdata    ),
    .m00_axi_wstrb         (m00_axi_wstrb    ),
    .m00_axi_wlast         (m00_axi_wlast    ),
    .m00_axi_wuser         (m00_axi_wuser    ),
    .m00_axi_wvalid        (m00_axi_wvalid   ),
    .m00_axi_wready        (m00_axi_wready   ),         
    .m00_axi_bid           (m00_axi_bid      ),
    .m00_axi_bresp         (m00_axi_bresp    ),
    .m00_axi_buser         (m00_axi_buser    ),
    .m00_axi_bvalid        (m00_axi_bvalid   ),
    .m00_axi_bready        (m00_axi_bready   ),         
    .m00_axi_arid          (m00_axi_arid     ),
    .m00_axi_araddr        (m00_axi_araddr   ),
    .m00_axi_arlen         (m00_axi_arlen    ),
    .m00_axi_arsize        (m00_axi_arsize   ),
    .m00_axi_arburst       (m00_axi_arburst  ),
    .m00_axi_arlock        (m00_axi_arlock   ),
    .m00_axi_arcache       (m00_axi_arcache  ),
    .m00_axi_arprot        (m00_axi_arprot   ),
    .m00_axi_arqos         (m00_axi_arqos    ),
    .m00_axi_aruser        (m00_axi_aruser   ),
    .m00_axi_arvalid       (m00_axi_arvalid  ),
    .m00_axi_arready       (m00_axi_arready  ),         
    .m00_axi_rid           (m00_axi_rid      ),
    .m00_axi_rdata         (m00_axi_rdata    ),
    .m00_axi_rresp         (m00_axi_rresp    ),
    .m00_axi_rlast         (m00_axi_rlast    ),
    .m00_axi_ruser         (m00_axi_ruser    ),
    .m00_axi_rvalid        (m00_axi_rvalid   ),
    .m00_axi_rready        (m00_axi_rready   )
);

L1D_Transform i_L1D_Transform(
    .clk                   (clk               ), 
    .rst_n                 (rst_n             ), 
    .Core_CacheAddr        (Core_CacheAddr    ), 
    .Core_CacheEn          (Core_CacheEn      ), 
    .Core_CacheRd          (Core_CacheRd      ),                 
    .writebus_en           (writebus_en       ), 
    .readbus_en            (readbus_en        ), 
    .fsm_idle_en           (fsm_idle_en       ), 
    .fsm_writecache_en     (fsm_writecache_en ), 
    .Tran_BusRdDone_cnt    (Tran_BusRdDone_cnt),                
    .Tran_BusDataRd        (Tran_BusDataRd    ), 
    .RAM_DataWrt           (RAM_DataWrt       ),               
    .writeaddress          (writeaddress      ), 
    .readaddress           (readaddress       ), 
    .writedata             (writedata         ), 
    .readdata              (readdata          ), 
    .rd_last               (rd_last           ), 
    .wrt_last              (wrt_last          ), 
    .BHand_Rd_Cond         (BHand_Rd_Cond     ), 
    .BHand_Wrt_Cond        (BHand_Wrt_Cond    ), 
    .wrt_addr_state        (wrt_addr_state    )

);

L1D_FSM i_L1D_FSM(
    .clk                   (clk               ),
    .rst_n                 (rst_n             ),
    .Core_CacheRd          (Core_CacheRd      ),
    .Core_CacheEn          (Core_CacheEn      ),        
    .RAM_ID_WB_cond        (RAM_ID_WB_cond    ),
    .RAM_ID_RB_cond        (RAM_ID_RB_cond    ),
    .RAM_ID_WC_cond        (RAM_ID_WC_cond    ),
    .RAM_WB_RB_cond        (RAM_WB_RB_cond    ),
    .RAM_RB_WC_cond        (RAM_RB_WC_cond    ),
    .modefied              (modefied          ),
    .FSM_current_state     (FSM_current_state ),
    .FSM_current_state2    (FSM_current_state2),
    .FSM_next_state        (FSM_next_state    ),          
    .Tran_BusRdDone_cnt    (Tran_BusRdDone_cnt),
    .writebus_en           (writebus_en       ),
    .readbus_en            (readbus_en        ),
    .fsm_idle_en           (fsm_idle_en       ),
    .fsm_writecache_en     (fsm_writecache_en )
);
L1D_RAM i_L1D_RAM(
    .clk                   (clk               ),
    .rst_n                 (rst_n             ),
    .Core_CacheAddr        (Core_CacheAddr    ),
    .Core_CacheRd          (Core_CacheRd      ),
    .Core_CacheData        (Core_CacheData    ),
    .Core_CacheWidth       (Core_CacheWidth   ),
    .Core_CacheEn          (Core_CacheEn      ),
    .Core_CacheSign        (Core_CacheSign    ),
    .Cache_DataRd          (Cache_DataRd      ),
    .Cache_StallReq        (Cache_StallReq    ),
    .Dcache_DataRd         (Dcache_DataRd     ),
    .Dcache_Dirty          (Dcache_Dirty      ),
    .Icache_PC             (Icache_PC         ),         
    .writebus_en           (writebus_en       ),
    .readbus_en            (readbus_en        ),
    .fsm_idle_en           (fsm_idle_en       ),
    .fsm_writecache_en     (fsm_writecache_en ),
    .FSM_current_state     (FSM_current_state ),
    .FSM_current_state2    (FSM_current_state2),
    .FSM_next_state        (FSM_next_state    ),
    .RAM_ID_WB_cond        (RAM_ID_WB_cond    ),
    .RAM_ID_RB_cond        (RAM_ID_RB_cond    ),
    .RAM_ID_WC_cond        (RAM_ID_WC_cond    ),
    .RAM_WB_RB_cond        (RAM_WB_RB_cond    ),
    .RAM_RB_WC_cond        (RAM_RB_WC_cond    ),
    .modefied              (modefied          ),           
    .wrt_last              (wrt_last          ),
    .rd_last               (rd_last           ),
    .Tran_BusDataRd        (Tran_BusDataRd    ),
    .RAM_DataWrt           (RAM_DataWrt       )
);

endmodule