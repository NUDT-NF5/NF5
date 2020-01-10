/*
 * @Author: J-zenk
 * @Date:   2019-10-28 15:51
 * @Last Modified by: J-zenk
 * @Last Modified time: 2019-11-08 09:33:48
 * @Describe:divider  module
 */
module divider(
    input         [31:0] div_s1,
    input         [31:0] div_s2,

    output        [31:0] div_result
);

assign div_result = div_s1 / div_s2;
endmodule // divider