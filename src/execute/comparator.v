module comparator(
    input       [31:0] comparator_s1,
    input       [31:0] comparator_s2,
    output reg  [2:0]  comparator_result,
    output      [2:0]  ucomparator_result
);

u_comparator sub_comp(.s1(comparator_s1), .s2(comparator_s2), .result(ucomparator_result));

always @(*) begin
    if(comparator_s1[31] != comparator_s2[31])   //comparator_s1, comparator_s2 have oppsite signs
        if(comparator_s1[31])                    //comparator_s1 is smaller
            comparator_result = 3'b001;
        else
            comparator_result = 3'b100;
    else                              //comparator_s1, comparator_s2 have same signs
        comparator_result = ucomparator_result;
end

endmodule // comparator