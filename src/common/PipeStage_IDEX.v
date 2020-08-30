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
	input		[STAGE_WIDTH - 1 : 0]	in,
	output reg	[STAGE_WIDTH - 1 : 0]	out,
    output                              IDEX_stall
);

    reg                                 indicator;

always @(posedge clk)
	if(~rst_n)begin
		out <= 0;
        indicator <= 0;
    end
	else if(Stall)
		out <= out;
	else if(Flush && issue_select)
		out <= 0;
	else if(STAGE_NUM == 1'b0 && Decode_Unicorn)
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
    else if(STAGE_NUM == 1'b1 && Decode_Unicorn)
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
    else
        out <= in;
		
    assign IDEX_stall = ~STAGE_NUM && Decode_Unicorn && ~indicator;

endmodule
