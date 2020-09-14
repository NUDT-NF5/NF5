/*
 * @Author: Sue
 * @Date:   2019-10-28 9:48
 * @Last Modified by: Sue
 * @Last Modified time: 2019-10-28 9:48
 * @Describe: common pipeline module
 * @ModuleParamDescribe: STAGE_WIDTH is stage datawidth
 * @Example: instance a module for example
 */
`include "../src/common/Define.v"
module PipeStage_IDEX
#(
	parameter							STAGE_WIDTH=`INSTR_WIDTH,
    parameter                           STAGE_NUM=1'b0
)
(
	input								clk,
	input								rst_n,
	input								Stall,
	input								Flush,
	input 								issue_select,
    input                               Decode_Unicorn,
    input                               Idfence_MemReq,
	input		[STAGE_WIDTH - 1 : 0]	in,
	output reg	[STAGE_WIDTH - 1 : 0]	out,
    output                              IDEX_stall
);

    reg                                 indicator;
    reg                                 Idfence_MemReq_r;

generate 
    if(STAGE_NUM == 1'b0)begin
        always @(posedge clk)
	        if(~rst_n)begin
	        	out <= 0;
                indicator <= 0;
            end
	        else if(Flush && issue_select)
	        	out <= 0;
	        else if(Decode_Unicorn)
                case (indicator)
                    1'b1 : begin
                        out <= 0;
                        indicator <= ~indicator;
                    end
                    default : begin
                        out <= in;
                        indicator <= ~indicator;
                    end
                endcase
	        else if(Stall)
	        	out <= out;
            else
                out <= in;
    end
endgenerate

generate 
    if(STAGE_NUM == 1'b1)begin
        always @(posedge clk)
	        if(~rst_n)begin
	        	out <= 0;
                indicator <= 0;
            end
	        else if(Flush && issue_select)
	        	out <= 0;
	        else if(Decode_Unicorn)
                case (indicator)
                    1'b1 : begin
                        out <= in;
                        indicator <= ~indicator;
                    end
                    default : begin
                        out <= 0;
                        indicator <= ~indicator;
                    end
                endcase
	        else if(Stall)
	        	out <= out;
            else
                out <= in;
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        Idfence_MemReq_r <= 1'b0;
    else
        Idfence_MemReq_r <= Idfence_MemReq;
end
		
    assign IDEX_stall = ~STAGE_NUM && Decode_Unicorn && ~indicator && ~Idfence_MemReq_r;

endmodule
