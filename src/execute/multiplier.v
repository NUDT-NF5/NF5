/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:  multiplier module
 */
module multiplier(
    input         [31:0] mul_s1,
    input         [31:0] mul_s2,

    output        [63:0] mul_result
);

assign mul_result = mul_s1 * mul_s2;

endmodule // multiplier