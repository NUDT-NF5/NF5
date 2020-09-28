module divider(
    input         [31:0] div_s1,
    input         [31:0] div_s2,

    output        [31:0] div_result
);

assign div_result = div_s1 / div_s2;
endmodule // divider