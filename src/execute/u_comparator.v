module u_comparator(
    input   [31:0] s1,
    input   [31:0] s2,
    output  [2:0]  result
);

assign result = (s1 >  s2) ? 3'b100 :
                (s1 == s2) ? 3'b010 :
                (s1 <  s2) ? 3'b001 :
                3'b0;

endmodule