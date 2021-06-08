/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe: arithmetic module
 */
module arithmetic(
    input       [`SIMD_DATA_WIDTH - 1:0] arithmetic_s1,
    input       [`SIMD_DATA_WIDTH - 1:0] arithmetic_s2,
    input       [`ADDR_WIDTH - 1:0]      IDEX_NowPC,
    input       [2:0]                    arithop_sp,       //if aluop == jalr, arithop_sp = 'b100, else if aluop == other branch,  arithop_sp = 'b001, else if aluop == sub, arithop_sp == 'b010
    input                                IDEX_16BitFlag,
    input                                simd_ena,
    input       [`SIMD_WIDTH - 1:0]      simd_ctl,

    output      [`SIMD_DATA_WIDTH - 1:0] arithmetic_result,
    output      [`ADDR_WIDTH - 1:0]      branch_result
);

reg             [`SIMD_DATA_WIDTH - 1:0] mainadder_s1;
reg             [`SIMD_DATA_WIDTH - 1:0] mainadder_s2;
reg             [`SIMD_DATA_WIDTH - 1:0] viceadder_s1;
reg             [`SIMD_DATA_WIDTH - 1:0] viceadder_s2;

reg                   ci1;
wire                  ci2;
wire            [`SIMD_DATA_WIDTH - 1:0] branch_result64;

//2 adders, one for arithmetic output, another for branch output
adder_simd adder_main(.a(mainadder_s1), .b(mainadder_s2), .ci(ci1), .simd_ena(simd_ena), .simd_ctl(simd_ctl), .s(arithmetic_result));
adder_simd adder_vice(.a(viceadder_s1), .b(viceadder_s2), .ci(ci2), .simd_ena(simd_ena), .simd_ctl(simd_ctl), .s(branch_result64));

assign branch_result = branch_result64[0+:`ADDR_WIDTH];

//if aluop == unconditional branch, arithmetic adder calculate PC + 4
always @(*) begin
    if (arithop_sp[0] && arithop_sp[2]) begin
        mainadder_s1 = arithmetic_s1;
        mainadder_s2 = 32'b1;
        ci1          = 1'b0;
    end
    else if (arithop_sp[0]) begin
        case (IDEX_16BitFlag)
            'd1: begin 
                mainadder_s1 = arithmetic_s1;
                mainadder_s2 = 32'd2;
                ci1          = 1'b0;
            end
            default: begin
                mainadder_s1 = arithmetic_s1;
                mainadder_s2 = 32'd4;
                ci1          = 1'b0;
            end
        endcase
    end
    else if(arithop_sp[1]) begin
        mainadder_s1 = arithmetic_s1;
        mainadder_s2 = arithmetic_s2;
        ci1          = 1'b1;
    end
    else if(arithop_sp[2]) begin
        case (IDEX_16BitFlag)
            'd1: begin 
                mainadder_s1 = IDEX_NowPC;
                mainadder_s2 = 32'd2;
                ci1          = 1'b0;
            end
            default: begin
                mainadder_s1 = IDEX_NowPC;
                mainadder_s2 = 32'd4;
                ci1          = 1'b0;
            end 
        endcase
    end
    else begin
        mainadder_s1 = arithmetic_s1;
        mainadder_s2 = arithmetic_s2;
        ci1          = 1'b0;
    end
end

//if aluop == unconditional branch, branch adder get s1, s2 input
always @(*) begin
    if (arithop_sp[0] && arithop_sp[2]) begin
        viceadder_s1 = arithmetic_s2;
        viceadder_s2 = 32'b1;
    end
    else if (arithop_sp[0] || arithop_sp[2]) begin
        viceadder_s1 = arithmetic_s1;
        viceadder_s2 = arithmetic_s2;
    end
   /* else if(arithop_sp[1]) begin
        viceadder_s1 = arithmetic_s2;
        viceadder_s2 = 32'b1;
    end*/
    else begin
        viceadder_s1 = 32'b0;
        viceadder_s2 = 32'b0;
    end
end

assign ci2 = 0;

endmodule // arithmetic