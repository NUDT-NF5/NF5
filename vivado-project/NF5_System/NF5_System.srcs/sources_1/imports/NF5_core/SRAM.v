//************************************************************************************************
//************************************************************************************************
//*****************This module is used to describe the cache RAM**********************************
//************************************************************************************************
//************************************************************************************************
module SRAM
#(
  parameter  Depth       = 'hFFF,
  parameter  DataWidth   = 32   ,
  parameter  AddrWidth   = 32   ,
  parameter  AddrWidth2  = 13
)
(
  input  wire                   clk    ,
  input  wire                   rst_n  ,
  //----conneted with Dcache
  input  wire                   RW     ,//1write 0read
  input  wire                   EN     ,
  input  wire [AddrWidth-1:0]   ADDR   ,
  input  wire [DataWidth-1:0]   DIn    ,
  output wire [DataWidth-1:0]   DOut
);
reg     [DataWidth-1:0]    Dout_reg;
wire    [DataWidth-1:0]    dout_wire;
reg     [DataWidth-1:0]    memory [0:Depth];  
wire    [AddrWidth2-1:0]   D_addr;              //Dcache access SRAM address, use 14bits of them
assign  D_addr = ADDR[AddrWidth2+1:2];
integer i;
//----communicate with Dcache
//always@(posedge clk or negedge rst_n)
reg EN_reg;
wire EN_wrt;
always@(posedge clk)
  begin
    EN_reg <= EN;
  end
assign EN_wrt = EN && EN_reg;
reg [2:0] EN_cnt;
always @(posedge clk or negedge rst_n) begin
 if (!rst_n)
    EN_cnt <= 0;
 else if (EN_cnt=='d4)
    EN_cnt <= 0;
 else if (EN)
    EN_cnt <= EN_cnt+1;
end
always@(posedge clk)
  begin
    //if( !rst_n )
    //  for(i=0;i<=Depth;i=i+1) memory[i] <= 0;
    //else if( EN && RW )
//   if( EN_wrt && RW )
  //  if( EN && RW )
   if( (EN_cnt!='d4)&&EN && RW )
      memory[D_addr] <= DIn;
  end
assign dout_wire = ( EN && !RW )? memory[D_addr]:0;
always@(posedge clk or negedge rst_n)
  begin
    if(!rst_n)
      Dout_reg <=0;
    else
      Dout_reg <=dout_wire;
  end
//assign DOut = ( EN && !RW )? memory[D_addr]:0;
assign DOut = Dout_reg;
endmodule
