`include "../src/common/Define.v"
module Csr(
    input  wire                               clk,
    input  wire                               rst_n,    
    input  wire   [4:0]                       Ctrl_Stall        ,
    input  wire   [2:0]                       Core_interrupt , //
    input  wire   [4:0]                       DBG_interrupt , //
    input  wire                               NMI,
    input  wire                               RESET, 
    input  wire   [`DATA_WIDTH-1:0]           EX_AluData     ,//jump ldst addr
    input  wire   [1:0]                       IDEX_StType   ,//EX detect the illegal addr  =Ex_Sttype  //change to:EX_StType
    input  wire   [2:0]                       IDEX_LdType   ,
    input  wire                               EX_BranchFlag  ,//actually = branch flag                                                        
    input  wire   [3:0]                       Decode_Flush   ,   //eret illegal  ebreak ecall      Decode_Flush[3]区分模式
 
    input  wire   [`ADDR_WIDTH-1:0]           IFID_NowPC, //IFID_NowPC 
    input  wire   [`ADDR_WIDTH-1:0]           IDEX_NowPC, //IDEX_NowPC in EX 
	
    input  wire   [`CSR_ADDR_WIDTH-1:0]       IDEX_CsrAddr   ,
    input  wire   [2:0]                       IDEX_CsrCmd    ,
    //input  wire   [`ADDR_WIDTH-1:0]           IDEX_PC        ,
    input  wire   [`DATA_WIDTH-1:0]           IDEX_Imm       ,
    input  wire   [`DATA_WIDTH-1:0]           IDEX_Rs1Data   ,
    input  wire   [2:0]                       IDEX_ImmSel   ,    
    output wire   [`DATA_WIDTH-1:0]           Csr_RdData     , //write back
                                               
    output wire   [`ADDR_WIDTH-1:0]           Csr_Evec       , //pcsel
    output wire                               Csr_ExcpFlag   , //flush IF ID  
    output wire                               Csr_Memflush ,    //flush EX-MEM Only 
    output wire                               Csr_WFIClrFlag,
  
    input  wire   [`DATA_WIDTH-1:0]           EXMem_AluData     ,//jump ldst addr
    input  wire   [1:0]                       EXMem_StType   ,//EX detect the illegal addr  =Ex_Sttype  //change to:EX_StType
    input  wire   [2:0]                       EXMem_LdType,
    input  wire   [`ADDR_WIDTH-1:0]           EX_BranchPC,//new	
    input  wire   [`ADDR_WIDTH-1:0]           EXMEM_NowPC	,
	input  wire			                      Decode_16BitFlag ,
    output wire                               Fetchaddr_Invalid,
    input  wire  [31:0]                       IFID_Instr		
    );
	
	//assign Csr_memflush
//////   exception detect    ///////////
//////   misalgn             ///////////
      reg Ldaddr_Invalid;
      reg Staddr_Invalid;

	  assign Fetchaddr_Invalid = EX_BranchFlag && EX_AluData[0];
      //assign Fetchaddr_Invalid = Decode_16BitFlag? (EX_BranchFlag && EX_AluData[0]):EX_BranchFlag && (EX_BranchPC[0]|EX_BranchPC[1]);//ifu_misalgn 0 16bitmisalign

      wire [`CSR_DATA_WIDTH-1:0]  csr_mcause_q;  
 
      wire[`CSR_DATA_WIDTH-1:0]csr_mie_q;
      wire[`CSR_DATA_WIDTH-1:0]csr_mstatus_q;

	  
      wire status_mie_q = csr_mstatus_q[3];
      wire ext_intena = status_mie_q &  csr_mie_q[3] & Core_interrupt[0];
      wire sft_intena = status_mie_q &  csr_mie_q[7] & Core_interrupt[1];    
      wire tmr_intena = status_mie_q &  csr_mie_q[11] & Core_interrupt[2];   

	  assign Csr_WFIClrFlag=(csr_mie_q[3] & Core_interrupt[0])
	                      |(csr_mie_q[7] & Core_interrupt[1])
						  |(csr_mie_q[11] & Core_interrupt[2]);//reserved for debug_entry
      
 
  always @(*)   
		case(EXMem_LdType)
         `LD_LW : Ldaddr_Invalid = EXMem_AluData[0]|EXMem_AluData[1];  //ld_misalgn 4
         `LD_LH : Ldaddr_Invalid = EXMem_AluData[0];
         `LD_LHU: Ldaddr_Invalid = EXMem_AluData[0];
        default:Ldaddr_Invalid=0;
    endcase
      
    always @ (*)  
		case(EXMem_StType) 
        `ST_SW : Staddr_Invalid = EXMem_AluData[0]|EXMem_AluData[1]; //st_misalgn 6
        `ST_SH : Staddr_Invalid = EXMem_AluData[0];
        default: Staddr_Invalid = 0;
    endcase
	
    reg[31:0] mcause_code; 
    reg[31:0] dcause_code; 
    wire[15:0]    flag_valid;	
    wire[15:0]    clear_valid;	

  /////////////// priority  /////////////////
  //Load access fault--5
  //Store/AMO access fault--7
  //Load page fault--13
  //Store/AMO page fault--15
  //Load address misaligned--4
  //Store/AMO address misaligned--6
  //Load/Store/AMO address breakpoint--3
  //Environment break--3
  //Environment call--8 9 11
  //Instruction address misaligned--0
  //Illegal instruction--2
  //Instruction access fault--1
  //Instruction page fault--12
  //Instruction address breakpoint--3

	assign	flag_valid = {
                    Ldaddr_Invalid,     //Load address misaligned--4
                    Staddr_Invalid,      //Store/AMO address misaligned--6
                    Decode_Flush[0],    //Environment call--8 9 11
                    Fetchaddr_Invalid,  //Instruction address misaligned--0
                    Decode_Flush[2],    //Illegal instruction--2
                    Decode_Flush[1],   //Instruction address breakpoint--3
                    tmr_intena,
                    sft_intena,
                    ext_intena,
                    DBG_interrupt,
                    RESET,                    
                    NMI
                    };
                
    assign    clear_valid = {    
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h4),
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h6),                    
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h0b),                    
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h0),
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h2),                    
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h3), 

                   
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h0b) &&(csr_mcause_q[31] ==1'b1),  
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h7)  &&(csr_mcause_q[31] ==1'b1),
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h3)  &&(csr_mcause_q[31] ==1'b1),
                    Decode_Flush[3]&& (dcause_code == 4'd2),
                    Decode_Flush[3]&& (dcause_code == 4'd1),
                    Decode_Flush[3]&& (dcause_code == 4'd3),
                    Decode_Flush[3]&& (dcause_code == 4'd4),
                    Decode_Flush[3]&& (dcause_code == 4'd5),                                          
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h1f),
                    Decode_Flush[3]&& (csr_mcause_q[4:0] == 5'h1f)                                 
                };    

     reg  [15:0] flag_reg_t;	
     wire  [15:0] flag_reg;	
     wire  flag_ena=Csr_ExcpFlag;
     wire [15:0] flag_data=(~clear_valid)&flag_reg;
 
      // sirv_gnrl_dfflr  flag_dfflr (flag_ena, flag_data, flag_reg, clk, rst_n);
always @(posedge clk)
	if(~rst_n)
		flag_reg_t <= 0;
	else if(Decode_Flush[3])
		flag_reg_t <=(~clear_valid)&flag_reg;
	else if(flag_valid!=0)
		flag_reg_t <= flag_reg|flag_valid;
	else 
		flag_reg_t <= flag_reg;
assign flag_reg=flag_reg_t;
   
    reg[15:0]  mask_tmp;		  
   always@(*) begin                     
      casex(flag_data|flag_valid) 
        16'bxxxx_xxxx_xxxx_xxx1 : begin mcause_code=5'h1f;  mask_tmp=16'b1111_1111_1111_1110;end
        16'bxxxx_xxxx_xxxx_xx10 : begin mcause_code=5'h1f;  mask_tmp=16'b1111_1111_1111_1100;end
        16'bxxxx_xxxx_xxxx_x100 : begin mcause_code=5'h1f;  mask_tmp=16'b1111_1111_1111_1000;end
        16'bxxxx_xxxx_xxxx_1000 : begin mcause_code=5'h1f;  mask_tmp=16'b1111_1111_1111_0000;end
        16'bxxxx_xxxx_xxx1_0000 : begin mcause_code=5'h1f;  mask_tmp=16'b1111_1111_1110_0000;end
        16'bxxxx_xxxx_xx10_0000 : begin mcause_code=5'h1f;  mask_tmp=16'b1111_1111_1100_0000;end
        16'bxxxx_xxxx_x100_0000 : begin mcause_code=5'h1f;  mask_tmp=16'b1111_1111_1000_0000;end
		
        16'bxxxx_xxxx_1000_0000 : begin mcause_code[31]=1'b1;mcause_code[30:0]=5'h3;    mask_tmp=16'b1111_1111_0000_0000;end
        16'bxxxx_xxx1_0000_0000 : begin mcause_code[31]=1'b1;mcause_code[30:0]=5'h7;    mask_tmp=16'b1111_1110_0000_0000;end
        16'bxxxx_xx10_0000_0000 : begin mcause_code[31]=1'b1;mcause_code[30:0]=5'h0b;   mask_tmp=16'b1111_1100_0000_0000;end // interrupts has priority	and the highest bit setting 1
		
        16'bxxxx_x100_0000_0000 : begin mcause_code=5'h3;   mask_tmp=16'b1111_1000_0000_0000;end //Instruction address misaligned		
        16'bxxxx_1000_0000_0000 : begin mcause_code=5'h2;   mask_tmp=16'b1111_0000_0000_0000;end //Instruction access fault
        16'bxxx1_0000_0000_0000 : begin mcause_code=5'h0;   mask_tmp=16'b1110_0000_0000_0000;end //Illegal instruction
        16'bxx10_0000_0000_0000 : begin mcause_code=5'h0b;   mask_tmp=16'b1100_0000_0000_0000;end  //load address misalign
        16'bx100_0000_0000_0000 : begin mcause_code=5'h6;   mask_tmp=16'b1000_0000_0000_0000;end  //Store/AMO address misalign
        16'b1000_0000_0000_0000 : begin mcause_code=5'h4;   mask_tmp=16'b0000_0000_0000_0000;end  //Environment call from M-mode   
						 default: begin mcause_code=5'h1f;  mask_tmp=16'b0;                  end   
      endcase
     end		

   always@(*) begin                     
      casex(flag_valid) 
        16'bxxxx_xxxx_xxxx_x100 : dcause_code=3'd0;  
        16'bxxxx_xxxx_xxxx_1000 : dcause_code=3'd0;  
        16'bxxxx_xxxx_xxx1_0000 : dcause_code=3'd0;  
        16'bxxxx_xxxx_xx10_0000 : dcause_code=3'd0;  
        16'bxxxx_xxxx_x100_0000 : dcause_code=3'd0;    
						 default: dcause_code=3'b0;  
      endcase
     end
//   reg[3:0]  dcause_code  ; reserved for debug_mode
  
	    wire   int_req_valid   =ext_intena|sft_intena|tmr_intena;
        wire [`CSR_DATA_WIDTH-1:0]csr_mtvec_q;
        wire [`CSR_DATA_WIDTH-1:0]csr_mepc_q;
       wire [`CSR_DATA_WIDTH-1:0]csr_mepc_d;
wire csr_mepc_wen;
        wire [15:0]flush_valid_tmp; 
        wire csr_flush;

        assign   flush_valid_tmp[15:0] = (flag_valid & (~mask_tmp[15:0]));//mask for 1 clk 
       // assign   csr_flush = (!Ctrl_Stall) & (|flush_valid_tmp[15:0]);//only flush when enter into exception
       assign   csr_flush = (|flush_valid_tmp[15:0]);//new
 assign   Csr_ExcpFlag = Decode_Flush[3]|csr_flush;//enter and eret

        wire   int_flush_req= Csr_ExcpFlag & (|flush_valid_tmp[9:7]);//interrupts flush
        wire   dbg_flush_req= Csr_ExcpFlag & (|flush_valid_tmp[6:2]);//dbg_flush_req 
        wire   tail_valid   = Decode_Flush[3] & (|flag_data);//中断咬尾 tail 抢占 per 嵌套 nest  	    
        assign Csr_Memflush = Csr_ExcpFlag & (flush_valid_tmp[15]|flush_valid_tmp[14]);//输出到control??位信号直接判断，不需要输出cause-code   change        

    // ------------------------------------
    //       mepc update logic
    // ------------------------------------	
         wire  [`CSR_DATA_WIDTH-1:0] csr_mepc_nxt;
         wire  csr_mepc_ena;         
         //assign Csr_Epc = Decode_Flush[3] ?csr_mepc_q:`ADDR_WIDTH'h0 ;
         assign csr_mepc_nxt= tail_valid ?csr_mepc_q: Csr_Memflush ? EXMEM_NowPC: IFID_NowPC;//IDEX_NowPC-4 :
         assign csr_mepc_ena =csr_flush; 

          
    // ------------------------------------
    //        mtvec update logic
    // ------------------------------------	 
        wire [`CSR_DATA_WIDTH-1:0]Csr_Evec_tmp;
        assign Csr_Evec_tmp = (dbg_flush_req) ?`ADDR_WIDTH'h800:
                              (int_flush_req) ? csr_mtvec_q * 4 :
                               csr_mtvec_q;

        assign Csr_Evec= tail_valid ? Csr_Evec_tmp:
                         (Decode_Flush[3]& csr_mepc_wen)?csr_mepc_d:
		            Decode_Flush[3] ?csr_mepc_q :Csr_Evec_tmp;


    // ------------------------------------
    //        mcause update logic
    // ------------------------------------	 
        //assign Csr_mcause = int_flush_req ? {1'b1,20'b0, mcause_code} :{1'b0,20'b0, mcause_code};
         wire  [`CSR_DATA_WIDTH-1:0]csr_mcause_nxt;  
         wire   csr_mcause_ena;   
         assign csr_mcause_nxt = tail_valid? mcause_code: Decode_Flush[3]? 32'h0: mcause_code;
         assign csr_mcause_ena = Csr_ExcpFlag;       
    
	// ------------------------------------
    //        mtval update logic
    // ------------------------------------	 
	// In Priv SPEC v1.10, the mbadaddr have been replaced to mtval.
    // The mtval register is an MXLEN-bit read-write register. (mtval=mbadaddr)
    //    * a hardware breakpoint is triggered,
    //    * an instruction-fetch, load, or store address-misaligned,  
    //    * access, or page-fault exceptionload  
    //   occurs, mtval is written with the  faulting virtual address (faulting address--mbadaddr). 
    //  and for other ways:
    //    * On an illegal instruction trap, mtval may be written with the first XLEN or ILEN bits of the faulting instruction。
    //    * For other exceptions, mtval is set to zero, but a future standard may redefine mtval's
    //        setting for other exceptions.
    //
         wire[31:0] faulting_virtual_address;//Reserve for mem
		 assign faulting_virtual_address=EXMem_AluData;
	     wire  [`CSR_DATA_WIDTH-1:0]csr_mtval_nxt;  
         wire   csr_mtval_ena;   
         assign csr_mtval_nxt = Csr_Memflush ? faulting_virtual_address://ldst misalign
                                flush_valid_tmp[12]? EX_BranchPC://ifetch misalign
		                   flush_valid_tmp[11]?IFID_Instr://new:illegal inst(id_inst)
					`CSR_DATA_WIDTH'b0;
         assign csr_mtval_ena = csr_mepc_ena;       
    
     ////    s-mode ////
     ////    d-mode ////  

     
    // ------------------------------------
    //        CSR config logic
    // ------------------------------------

         reg  [`CSR_DATA_WIDTH-1:0]csr_read_data;                      
         wire [`DATA_WIDTH-1:0] csr_op1 =( IDEX_ImmSel==`IMM_Z)? IDEX_Imm :IDEX_Rs1Data;
         wire [`DATA_WIDTH-1:0] csr_op2 =csr_read_data;   
         wire csr_rden  = IDEX_CsrCmd[0]| IDEX_CsrCmd[1];//read enable
         wire csr_wrten = (IDEX_CsrCmd == `CSR_S|IDEX_CsrCmd == `CSR_C)&csr_op1!=0 | IDEX_CsrCmd == `CSR_W;                                 
         wire  [`CSR_ADDR_WIDTH-1:0] csr_idx = IDEX_CsrAddr;
         wire  [`CSR_DATA_WIDTH-1:0] csr_wrt_data;
         assign  csr_wrt_data =  ({`DATA_WIDTH{IDEX_CsrCmd == `CSR_W}} & csr_op1)
                                 | ({`DATA_WIDTH{IDEX_CsrCmd == `CSR_S}} & (  csr_op1  | csr_op2))
                                 | ({`DATA_WIDTH{IDEX_CsrCmd == `CSR_C}} & ((~csr_op1) & csr_op2));
         assign Csr_RdData=csr_read_data;
     

    // ------------------------------------
    //        CSRs interface
    // ------------------------------------
          wire [`CSR_DATA_WIDTH-1:0] csr_debug_mode_q;  
          wire [`CSR_DATA_WIDTH-1:0] csr_dcsr_q      ;  
          wire [`CSR_DATA_WIDTH-1:0] csr_dpc_q       ;  
          wire [`CSR_DATA_WIDTH-1:0] csr_dscratch_q ;  
        
          // machine mode registers
          wire [`CSR_DATA_WIDTH-1:0]  csr_medeleg_q       ;
          wire [`CSR_DATA_WIDTH-1:0]  csr_mideleg_q       ;
          wire [`CSR_DATA_WIDTH-1:0]  csr_mip_q           ;
         // reg [`CSR_DATA_WIDTH-1:0]  csr_mcause_q        ;
          wire [`CSR_DATA_WIDTH-1:0]  csr_mscratch_q      ;
          wire [`CSR_DATA_WIDTH-1:0]  csr_mtval_q         ;   
          wire [`CSR_DATA_WIDTH-1:0]  csr_mhartid_q      ;     
          wire [`CSR_DATA_WIDTH-1:0]  csr_pmpcfg0_q      ;     
          wire [`CSR_DATA_WIDTH-1:0]  csr_pmpaddr0_q     ; 
          wire [`CSR_DATA_WIDTH-1:0]  csr_stvec_q        ;     
          wire [`CSR_DATA_WIDTH-1:0]  csr_satp_q         ;   
        
          reg csr_hartid=32'b0;//constant defined


    // ----------------------------------------
    // CSR Read logic
    // ----------------------------------------
    always@(*)begin : csr_read_process 
        csr_read_data = `CSR_DATA_WIDTH'b0 ;
     if (csr_rden ) begin
        case (IDEX_CsrAddr) 
         // debug registers
         `CSR_DCSR:               csr_read_data = csr_dcsr_q;
         `CSR_DPC:                csr_read_data = csr_dpc_q;
         `CSR_DSCRATCH:           csr_read_data = csr_dscratch_q;
          // machine mode registers
         `CSR_MSTATUS:            csr_read_data = csr_mstatus_q;
         `CSR_MISA:               csr_read_data = `ISA_CODE;
         `CSR_MEDELEG:            csr_read_data = csr_medeleg_q;
         `CSR_MIDELEG:            csr_read_data = csr_mideleg_q;
         `CSR_MIE:                csr_read_data = csr_mie_q;
         `CSR_MTVEC:              csr_read_data = csr_mtvec_q;
         //`CSR_MCOUNTEREN:         csr_read_data = `CSR_DATA_WIDTH'b0; // not implemented
         `CSR_MSCRATCH:           csr_read_data = csr_mscratch_q;
         `CSR_MEPC:               csr_read_data = csr_mepc_q;
         `CSR_MCAUSE:             csr_read_data = csr_mcause_q;
         `CSR_MTVAL:              csr_read_data = csr_mtval_q;
         `CSR_MIP:                csr_read_data = csr_mip_q;
        // `CSR_MVENDORID:          csr_read_data = `CSR_DATA_WIDTH'b0; // not implemented
        // `CSR_MARCHID:            csr_read_data = csr_marchid_q;
        // `CSR_MIMPID:             csr_read_data = `CSR_DATA_WIDTH'b0; // not implemented
         `CSR_MHARTID:            csr_read_data = csr_hartid;
        // `CSR_MCYCLE:             csr_read_data = csr_cycle_q;
        // `CSR_MINSTRET:           csr_read_data = csr_instret_q;
 
          `CSR_PMPCFG0:           csr_read_data=csr_pmpcfg0_q  ;
          `CSR_PMPADDR:           csr_read_data=csr_pmpaddr0_q ;  
          `CSR_STVEC:             csr_read_data=csr_stvec_q ;   
          `CSR_SATP:              csr_read_data=csr_satp_q  ;         
         
          default: csr_read_data = `CSR_DATA_WIDTH'b0;
         endcase
      end
    end   

    // ---------------------------
    // CSR Write ena
    // ---------------------------
      wire csr_dcsr_wen     = csr_wrten &(IDEX_CsrAddr==`CSR_DCSR    );
      wire csr_dpc_wen      = csr_wrten &(IDEX_CsrAddr==`CSR_DPC     );
      wire csr_dscratch_wen = csr_wrten &(IDEX_CsrAddr==`CSR_DSCRATCH);
      wire csr_mstatus_wen  = csr_wrten &(IDEX_CsrAddr==`CSR_MSTATUS)|csr_mepc_ena ;
      wire csr_mie_wen      = csr_wrten &(IDEX_CsrAddr==`CSR_MIE    ); 
      wire csr_mip_wen      = csr_wrten &(IDEX_CsrAddr==`CSR_MIP    ); 
     assign csr_mepc_wen     = (csr_wrten &(IDEX_CsrAddr==`CSR_MEPC))  |csr_mepc_ena; 
      wire csr_mcause_wen   = (csr_wrten &(IDEX_CsrAddr==`CSR_MCAUSE))|csr_mcause_ena;
      wire csr_mtval_wen    = csr_wrten &(IDEX_CsrAddr==`CSR_MTVAL   )|csr_mtval_ena; 
      wire csr_mtvec_wen    = csr_wrten &(IDEX_CsrAddr==`CSR_MTVEC   ); 
      wire csr_mscratch_wen = csr_wrten &(IDEX_CsrAddr==`CSR_MSCRATCH);
      wire csr_medeleg_wen  = csr_wrten &(IDEX_CsrAddr==`CSR_MEDELEG ); 
      wire csr_mideleg_wen  = csr_wrten &(IDEX_CsrAddr==`CSR_MIDELEG ); 
      wire csr_mhartid_wen  = csr_wrten &(IDEX_CsrAddr==`CSR_MHARTID );    
      wire csr_pmpcfg0_wen = csr_wrten &(IDEX_CsrAddr==`CSR_PMPCFG0 );	
      wire csr_pmpaddr0_wen= csr_wrten &(IDEX_CsrAddr==`CSR_PMPADDR ); 
      wire csr_stvec_wen = csr_wrten &(IDEX_CsrAddr==`CSR_STVEC   ); 
      wire csr_satp_wen  = csr_wrten &(IDEX_CsrAddr==`CSR_SATP    ); 
     
 

	 // ---------------------------
    // CSR  write_data logic
    // ---------------------------
  
    //------------------------------------------
    // The MPIE Feilds will be updates when: 
    // The CSR is written by CSR instructions      
    // The MRET instruction commited       
    // The Trap is taken 
    //------------------------------------------  
     //  wire status_mie_q= csr_mstatus_q[3];
       wire status_mpie_q= csr_mstatus_q[7];
	   
	   //wire csr_mstatus_wen  = csr_wrten &(IDEX_CsrAddr==`CSR_MSTATUS)|csr_mepc_ena ;
       wire status_mpie_d =csr_mepc_ena ?  status_mie_q    ://When the Trap is taken, the MPIE is updated with the current MIE value
                          (Decode_Flush[3]==1'b1)  ? 1'b1 ://When the MRET instruction commited, the MPIE is updated with 1
       				    csr_mstatus_wen? csr_wrt_data[7]: //CSR instructions  MPIE is in field 7 of mstatus 
       				   (rst_n==1)?1'b0:status_mpie_q;     // Unchanged  
       wire status_mie_d  = csr_mepc_ena ?1'b0  :  //When the Trap is taken, the MIE is updated with 0
                           (Decode_Flush[3] ==1)  ? status_mpie_q :// When the MRET instruction commited, the MIE is updated with MPIE
       		            csr_mstatus_wen ? csr_wrt_data[3]     :// When the CSR is written by CSR instructions  MIE is in field 3 of mstatus
       			        status_mie_q;                      // Unchanged 
       
      wire [`CSR_DATA_WIDTH-1:0] csr_dcsr_d     =csr_wrt_data;    
      wire [`CSR_DATA_WIDTH-1:0] csr_dpc_d      =csr_wrt_data;    
      wire [`CSR_DATA_WIDTH-1:0] csr_dscratch_d =csr_wrt_data;
      wire [`CSR_DATA_WIDTH-1:0] csr_mstatus_d  ={24'b0, status_mpie_d,3'b0, status_mie_d,3'b0};
      wire [`CSR_DATA_WIDTH-1:0] csr_mtvec_d    =csr_wrt_data;     
      wire [`CSR_DATA_WIDTH-1:0] csr_medeleg_d  =csr_wrt_data; 
      wire [`CSR_DATA_WIDTH-1:0] csr_mideleg_d  =csr_wrt_data; 
      wire [`CSR_DATA_WIDTH-1:0] csr_mip_d      ={20'b0,Core_interrupt[2], 3'b0,Core_interrupt[1],3'b0, Core_interrupt[0],3'b0};
      wire [`CSR_DATA_WIDTH-1:0] csr_mie_d      ={20'b0,csr_wrt_data[11] , 3'b0,csr_wrt_data[7],  3'b0, csr_wrt_data[ 3],3'b0}; 
   assign csr_mepc_d     =csr_mepc_ena ?csr_mepc_nxt[31:0] :csr_wrt_data[31:0];
      wire [`CSR_DATA_WIDTH-1:0] csr_mcause_d   =csr_mcause_ena?csr_mcause_nxt[31:0]:csr_wrt_data[31:0]; 
      wire [`CSR_DATA_WIDTH-1:0] csr_mscratch_d =csr_wrt_data;
      wire [`CSR_DATA_WIDTH-1:0] csr_mtval_d    =csr_mtval_ena ?csr_mtval_nxt[31:0]:csr_wrt_data;
      wire [`CSR_DATA_WIDTH-1:0] csr_mhartid_d  =csr_wrt_data;
      wire [`CSR_DATA_WIDTH-1:0] csr_pmpcfg0_d  =csr_wrt_data;
      wire [`CSR_DATA_WIDTH-1:0] csr_pmpaddr0_d =csr_wrt_data;
      wire [`CSR_DATA_WIDTH-1:0] csr_stvec_d    =csr_wrt_data;
      wire [`CSR_DATA_WIDTH-1:0] csr_satp_d     =csr_wrt_data;
   
 	 // ---------------------------
    // CSR  Updata logic
    // ---------------------------
       sirv_gnrl_dfflr  dcsr_dfflr (csr_dcsr_wen, csr_dcsr_d, csr_dcsr_q, clk, rst_n);
       sirv_gnrl_dfflr  dpc_dfflr (csr_dpc_wen, csr_dpc_d, csr_dpc_q, clk, rst_n);
       sirv_gnrl_dfflr  dscratch_dfflr (csr_dscratch_wen, csr_dscratch_d, csr_dscratch_q, clk, rst_n);
       sirv_gnrl_dfflr  mstatus_dfflr (csr_mstatus_wen, csr_mstatus_d, csr_mstatus_q, clk, rst_n);
       sirv_gnrl_dfflr  mtvec_dfflr (csr_mtvec_wen, csr_mtvec_d, csr_mtvec_q, clk, rst_n);
       sirv_gnrl_dfflr  medeleg_dfflr (csr_medeleg_wen, csr_medeleg_d, csr_medeleg_q, clk, rst_n);
       sirv_gnrl_dfflr  mideleg_dfflr (csr_mideleg_wen, csr_mideleg_d, csr_mideleg_q, clk, rst_n);
       sirv_gnrl_dfflr  mip_dfflr (csr_mip_wen, csr_mip_d, csr_mip_q, clk, rst_n);
       sirv_gnrl_dfflr  mie_dfflr (csr_mie_wen, csr_mie_d, csr_mie_q, clk, rst_n);
       sirv_gnrl_dfflr  mepc_dfflr (csr_mepc_wen, csr_mepc_d, csr_mepc_q, clk, rst_n);
       sirv_gnrl_dfflr  mcause_dfflr (csr_mcause_wen, csr_mcause_d, csr_mcause_q, clk, rst_n);
       sirv_gnrl_dfflr  mscratch_dfflr (csr_mscratch_wen, csr_mscratch_d, csr_mscratch_q, clk, rst_n);
       sirv_gnrl_dfflr  mtval_dfflr (csr_mtval_wen, csr_mtval_d, csr_mtval_q, clk, rst_n);
       sirv_gnrl_dfflr  mhartid_dfflr (csr_mhartid_wen, csr_mhartid_d, csr_mhartid_q, clk, rst_n);
       sirv_gnrl_dfflr  pmpcfg0_dfflr (csr_pmpcfg0_wen, csr_pmpcfg0_d, csr_pmpcfg0_q, clk, rst_n);
       sirv_gnrl_dfflr  pmpaddr0_dfflr (csr_pmpaddr0_wen, csr_pmpaddr0_d, csr_pmpaddr0_q, clk, rst_n);
       sirv_gnrl_dfflr  stvec_dfflr (csr_stvec_wen, csr_stvec_d, csr_stvec_q, clk, rst_n);
       sirv_gnrl_dfflr  satp_dfflr (csr_satp_wen, csr_satp_d, csr_satp_q, clk, rst_n);

endmodule


module sirv_gnrl_dfflr # (
  parameter DW = 32
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output reg    [DW-1:0] qout,

  input               clk,
  input               rst_n
);
//reg [DW-1:0] qout_r;
always @(posedge clk or negedge rst_n)
begin : DFFLR_PROC
  if (!rst_n)
    qout <= {DW{1'b0}};
  else if (lden == 1'b1)
    qout <=  dnxt;
end
//assign qout = qout_r;
endmodule

   
