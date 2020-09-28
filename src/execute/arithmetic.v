module arithmetic(
    input       [31:0] arithmetic_s1,
    input       [31:0] arithmetic_s2,
    input       [31:0] IDEX_NowPC,
    input       [2:0]  arithop_sp,       //if aluop == jalr, arithop_sp = 'b100, else if aluop == other branch,  arithop_sp = 'b001, else if aluop == sub, arithop_sp == 'b010
    input              IDEX_16BitFlag,
    output      [31:0] arithmetic_result,
    output      [31:0] branch_result
//    output  reg        valid;
);

reg             [31:0] mainadder_s1;
reg             [31:0] mainadder_s2;
reg             [31:0] viceadder_s1;
reg             [31:0] viceadder_s2;

//2 adders, one for arithmetic output, another for branch output
adder32 adder_main(.a(mainadder_s1), .b(mainadder_s2), .s(arithmetic_result));
adder32 adder_vice(.a(viceadder_s1), .b(viceadder_s2), .s(branch_result));

//if aluop == unconditional branch, arithmetic adder calculate PC + 4
always @(*) begin
    if (arithop_sp[0] && arithop_sp[2]) begin
        mainadder_s1 = arithmetic_s1;
        mainadder_s2 = 32'b1;
    end
    else if (arithop_sp[0]) begin
        case (IDEX_16BitFlag)
            'd1: begin 
                mainadder_s1 = arithmetic_s1;
                mainadder_s2 = 32'd2;
            end
            default: begin
                mainadder_s1 = arithmetic_s1;
                mainadder_s2 = 32'd4;
            end
        endcase
    end
    else if(arithop_sp[1]) begin
        mainadder_s1 = arithmetic_s1;
        mainadder_s2 = branch_result;
    end
    else if(arithop_sp[2]) begin
        case (IDEX_16BitFlag)
            'd1: begin 
                mainadder_s1 = IDEX_NowPC;
                mainadder_s2 = 32'd2;
            end
            default: begin
                mainadder_s1 = IDEX_NowPC;
                mainadder_s2 = 32'd4;
            end 
        endcase
    end
    else begin
        mainadder_s1 = arithmetic_s1;
        mainadder_s2 = arithmetic_s2;
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
    else if(arithop_sp[1]) begin
        viceadder_s1 = arithmetic_s2;
        viceadder_s2 = 32'b1;
    end
    else begin
        viceadder_s1 = 32'b0;
        viceadder_s2 = 32'b0;
    end
end

endmodule // arithmetic