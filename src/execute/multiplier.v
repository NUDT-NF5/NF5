module multiplier(
    input         [31:0] mul_s1,
    input         [31:0] mul_s2,

    output        [63:0] mul_result
);

assign mul_result = mul_s1 * mul_s2;

endmodule // multiplier